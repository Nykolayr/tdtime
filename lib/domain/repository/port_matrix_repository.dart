import 'dart:async';
import 'dart:convert';

import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdtime/domain/models/port_matrix_device.dart';

class PortMatrixRepository {
  static const String _devicePrefsKey = 'port_matrix_device';
  static const MethodChannel _channel = MethodChannel(
      'com.flutter_bluetooth_classic.plugin/flutter_bluetooth_classic');
  static const EventChannel _connectionChannel = EventChannel(
      'com.flutter_bluetooth_classic.plugin/flutter_bluetooth_classic_connection');
  static const EventChannel _dataChannel = EventChannel(
      'com.flutter_bluetooth_classic.plugin/flutter_bluetooth_classic_data');

  final StreamController<String> _scanCodeController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  StreamSubscription<dynamic>? _dataSubscription;
  StreamSubscription<dynamic>? _connectionSubscription;

  String _scanBuffer = '';
  PortMatrixDevice? _defaultDevice;
  bool _isConnected = false;
  bool _manualDisconnect = false;
  Timer? _reconnectTimer;
  String? _lastEmittedCode;
  DateTime? _lastEmittedAt;
  DateTime? _lastAnyEmitAt;
  static const int _minEmitIntervalMs = 300;

  Stream<String> get scanCodeStream => _scanCodeController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;
  PortMatrixDevice? get defaultDevice => _defaultDevice;

  Future<void> init() async {
    _defaultDevice = await loadDefaultDevice();
    _bindBluetoothStreams();
  }

  void _bindBluetoothStreams() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();

    _connectionSubscription =
        _connectionChannel.receiveBroadcastStream().listen((event) {
      final map = _normalizeMap(event);
      _isConnected = map['isConnected'] == true;
      _connectionController.add(_isConnected);
      if (!_isConnected) {
        _tryScheduleReconnect();
      } else {
        _reconnectTimer?.cancel();
      }
    }, onError: (e) {
      Logger.e('PortMatrix connection stream error: $e');
    });

    _dataSubscription = _dataChannel.receiveBroadcastStream().listen((event) {
      final map = _normalizeMap(event);
      final data = map['data'];
      if (data is! List) return;
      final bytes = data.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
      if (bytes.isEmpty) return;
      final raw = utf8.decode(bytes, allowMalformed: true);
      if (raw.isEmpty) return;
      _appendAndParse(raw);
    }, onError: (e) {
      Logger.e('PortMatrix data stream error: $e');
    });
  }

  void _appendAndParse(String raw) {
    _scanBuffer += raw;
    final parts = _scanBuffer.split(RegExp(r'[\r\n\t]+'));
    if (parts.isEmpty) return;

    for (var i = 0; i < parts.length - 1; i++) {
      final code = parts[i].trim();
      if (code.isNotEmpty) {
        _emitCodeWithDebounce(code);
      }
    }

    _scanBuffer = parts.last;
  }

  Future<bool> isBluetoothSupported() {
    return _channel.invokeMethod<bool>('isBluetoothSupported').then((v) => v ?? false);
  }

  Future<bool> isBluetoothEnabled() {
    return _channel.invokeMethod<bool>('isBluetoothEnabled').then((v) => v ?? false);
  }

  Future<List<PortMatrixDevice>> getPairedDevices() async {
    final devices = await _channel.invokeMethod<List<dynamic>>('getPairedDevices');
    if (devices == null) return [];
    return devices.map((item) {
      final map = _normalizeMap(item);
      return PortMatrixDevice(
        name: (map['name'] ?? 'Без имени').toString(),
        address: (map['address'] ?? '').toString(),
      );
    }).where((d) => d.address.isNotEmpty).toList();
  }

  Future<bool> connectAndSaveDefault({
    required PortMatrixDevice device,
  }) async {
    try {
      _manualDisconnect = false;
      _reconnectTimer?.cancel();
      final connected =
          await _channel.invokeMethod<bool>('connect', {'address': device.address}) ?? false;
      if (!connected) return false;
      _isConnected = true;
      _connectionController.add(true);
      await saveDefaultDevice(device);
      return true;
    } catch (e) {
      Logger.e('PortMatrix connect error: $e');
      return false;
    }
  }

  Future<bool> connectToDefaultDevice() async {
    final device = _defaultDevice ?? await loadDefaultDevice();
    if (device == null) return false;
    try {
      _manualDisconnect = false;
      _reconnectTimer?.cancel();
      final connected =
          await _channel.invokeMethod<bool>('connect', {'address': device.address}) ?? false;
      _isConnected = connected;
      _connectionController.add(_isConnected);
      if (!connected) {
        _tryScheduleReconnect();
      }
      return connected;
    } catch (e) {
      Logger.e('PortMatrix reconnect error: $e');
      _tryScheduleReconnect();
      return false;
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    try {
      await _channel.invokeMethod<bool>('disconnect');
    } catch (e) {
      Logger.e('PortMatrix disconnect error: $e');
    }
    _isConnected = false;
    _scanBuffer = '';
    _connectionController.add(false);
  }

  Future<void> disconnectAndClearDefault() async {
    await disconnect();
    await clearDefaultDevice();
  }

  Future<void> saveDefaultDevice(PortMatrixDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_devicePrefsKey, jsonEncode(device.toJson()));
    _defaultDevice = device;
  }

  Future<void> clearDefaultDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devicePrefsKey);
    _defaultDevice = null;
  }

  Future<PortMatrixDevice?> loadDefaultDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_devicePrefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final parsed = PortMatrixDevice.fromJson(map);
      if (parsed.address.isEmpty) return null;
      _defaultDevice = parsed;
      return parsed;
    } catch (e) {
      Logger.e('PortMatrix parse device error: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _scanCodeController.close();
    await _connectionController.close();
  }

  void _tryScheduleReconnect() {
    if (_manualDisconnect || _defaultDevice == null) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      try {
        await connectToDefaultDevice();
      } catch (e) {
        Logger.e('PortMatrix delayed reconnect error: $e');
      }
    });
  }

  Map<String, dynamic> _normalizeMap(dynamic event) {
    if (event is Map<String, dynamic>) return event;
    if (event is Map) {
      return event.map((key, value) => MapEntry('$key', value));
    }
    return {};
  }

  void _emitCodeWithDebounce(String code) {
    final now = DateTime.now();
    if (_lastAnyEmitAt != null &&
        now.difference(_lastAnyEmitAt!).inMilliseconds < _minEmitIntervalMs) {
      return;
    }
    if (_lastEmittedCode == code &&
        _lastEmittedAt != null &&
        now.difference(_lastEmittedAt!).inMilliseconds < 1200) {
      return;
    }
    _lastAnyEmitAt = now;
    _lastEmittedCode = code;
    _lastEmittedAt = now;
    _scanCodeController.add(code);
  }
}
