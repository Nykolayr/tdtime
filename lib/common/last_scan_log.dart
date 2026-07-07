import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'last_scan_log_v1';

/// Тип сканирования для лога.
enum ScanKind {
  ttQr('QR торговой точки'),
  dataMatrix('DataMatrix'),
  pdf417('PDF417');

  const ScanKind(this.label);
  final String label;
}

/// Результат последнего сканирования.
enum ScanLogResult {
  success('OK'),
  cancelled('отмена'),
  error('ошибка');

  const ScanLogResult(this.label);
  final String label;
}

/// Сервис: один перезаписываемый лог последнего сканирования.
class LastScanLog {
  LastScanLog._();

  static String _cached = '';

  static String get text => _cached;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getString(_prefsKey) ?? '';
  }

  static Future<void> save(String text) async {
    _cached = text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, text);
    Logger.i('[LastScanLog]\n$text');
  }

  static Future<void> recordScan({
    required ScanKind scanKind,
    required DateTime openedAt,
    required DateTime closedAt,
    required ScanLogResult result,
    required MobileScannerController controller,
    required List<BarcodeFormat> formats,
    required String screenTitle,
    String? ttId,
    String? scannedCode,
    String? barcodeFormat,
    String? errorMessage,
    required String cameraSnapshotOpen,
    required String cameraSnapshot2s,
    required String cameraSnapshotClose,
  }) async {
    final device = await _collectDeviceInfo();
    final packageInfo = await PackageInfo.fromPlatform();
    final duration = closedAt.difference(openedAt);

    final closeState = controller.value;
    final whiteScreenHint = _whiteScreenHint(
      closeState,
      result,
      scannedCode,
    );

    final buffer = StringBuffer()
      ..writeln('=== Лог последнего сканирования ===')
      ..writeln()
      ..writeln('Открыт:  ${_fmt(openedAt)}')
      ..writeln('Закрыт:   ${_fmt(closedAt)}')
      ..writeln('Длительность: ${duration.inSeconds} сек')
      ..writeln()
      ..writeln('--- Устройство ---')
      ..writeln('Устройство: ${device.deviceLabel}')
      ..writeln('Система: ${device.osLabel}');
    if (device.machineId != null) {
      buffer.writeln('Модель (внутр.): ${device.machineId}');
    }
    buffer
      ..writeln('Приложение: ${packageInfo.version} (${packageInfo.buildNumber})')
      ..writeln()
      ..writeln('--- Скан ---')
      ..writeln('Тип: ${scanKind.label}')
      ..writeln('Экран: $screenTitle')
      ..writeln('Форматы: ${formats.map((f) => f.name).join(', ')}')
      ..writeln('ТТ: ${ttId ?? '—'}')
      ..writeln()
      ..writeln('--- Результат ---')
      ..writeln('Статус: ${result.label}')
      ..writeln('Код: ${scannedCode ?? '—'}')
      ..writeln('Формат кода: ${barcodeFormat ?? '—'}');
    if (errorMessage != null && errorMessage.isNotEmpty) {
      buffer.writeln('Ошибка: $errorMessage');
    }
    if (whiteScreenHint != null) {
      buffer
        ..writeln()
        ..writeln('⚠ $whiteScreenHint');
    }
    buffer
      ..writeln()
      ..writeln('--- Камера (открытие) ---')
      ..writeln(cameraSnapshotOpen)
      ..writeln()
      ..writeln('--- Камера (+2 сек) ---')
      ..writeln(cameraSnapshot2s)
      ..writeln()
      ..writeln('--- Камера (закрытие) ---')
      ..writeln(cameraSnapshotClose);

    await save(buffer.toString());
  }

  static String? _whiteScreenHint(
    MobileScannerState state,
    ScanLogResult result,
    String? code,
  ) {
    if (result != ScanLogResult.cancelled && code != null) return null;
    if (state.error != null) return null;
    if (state.isInitialized &&
        state.isRunning &&
        state.hasCameraPermission &&
        code == null) {
      return 'превью без ошибки плагина (возможен белый экран)';
    }
    if (!state.isInitialized && state.error == null) {
      return 'камера не инициализировалась, ошибка плагина не зафиксирована';
    }
    return null;
  }

  static String snapshotCamera(
    MobileScannerController controller,
    String moment,
  ) {
    final s = controller.value;
    final err = s.error;
    return '''
момент: $moment
initialized: ${s.isInitialized}
running: ${s.isRunning}
starting: ${s.isStarting}
permission: ${s.hasCameraPermission}
cameras: ${s.availableCameras ?? '—'}
facing: ${s.cameraDirection.name}
preview: ${s.size.width.toInt()}x${s.size.height.toInt()}
torch: ${s.torchState.name}
error: ${err?.errorCode.name ?? '—'}
errorMsg: ${err?.errorDetails?.message ?? err?.errorCode.message ?? '—'}'''
        .trim();
  }

  static Future<_DeviceInfo> _collectDeviceInfo() async {
    if (kIsWeb) {
      return const _DeviceInfo(
        deviceLabel: 'Web',
        osLabel: 'web',
      );
    }
    final plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      final name = info.modelName.trim();
      final machine = info.utsname.machine.trim();
      final deviceLabel = name.isNotEmpty
          ? name
          : (machine.isNotEmpty ? 'Apple $machine' : 'Apple iPhone');
      return _DeviceInfo(
        deviceLabel: deviceLabel,
        osLabel: '${info.systemName} ${info.systemVersion}',
        machineId: machine.isNotEmpty ? machine : null,
      );
    }
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      final brand = info.manufacturer.trim();
      final model = info.model.trim();
      return _DeviceInfo(
        deviceLabel: [brand, model].where((s) => s.isNotEmpty).join(' '),
        osLabel:
            'Android ${info.version.release} (SDK ${info.version.sdkInt})',
        machineId: info.device.trim().isNotEmpty ? info.device : null,
      );
    }
    return const _DeviceInfo(deviceLabel: 'unknown', osLabel: 'unknown');
  }

  static String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}

class _DeviceInfo {
  final String deviceLabel;
  final String osLabel;
  final String? machineId;

  const _DeviceInfo({
    required this.deviceLabel,
    required this.osLabel,
    this.machineId,
  });
}
