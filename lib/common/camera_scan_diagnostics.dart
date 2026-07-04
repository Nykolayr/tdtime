import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Снимок состояния камеры и устройства для поддержки.
class CameraScanDiagnostics {
  final DateTime collectedAt;
  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String deviceModel;
  final String deviceBrand;
  final String? userLogin;
  final bool cameraInitialized;
  final bool cameraRunning;
  final bool cameraStarting;
  final bool hasCameraPermission;
  final String? errorCode;
  final String? errorMessage;
  final String? errorDetails;
  final int? availableCameras;
  final String cameraFacing;
  final String previewSize;
  final String torchState;
  final String scanFormats;
  final String screenTitle;
  final String initStatus;

  const CameraScanDiagnostics({
    required this.collectedAt,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.deviceBrand,
    this.userLogin,
    required this.cameraInitialized,
    required this.cameraRunning,
    required this.cameraStarting,
    required this.hasCameraPermission,
    this.errorCode,
    this.errorMessage,
    this.errorDetails,
    this.availableCameras,
    required this.cameraFacing,
    required this.previewSize,
    required this.torchState,
    required this.scanFormats,
    required this.screenTitle,
    required this.initStatus,
  });

  bool get isOk =>
      cameraInitialized &&
      cameraRunning &&
      hasCameraPermission &&
      errorCode == null;

  String toDisplayText() {
    final buffer = StringBuffer()
      ..writeln('Статус: $initStatus')
      ..writeln('Время: ${_formatDateTime(collectedAt)}')
      ..writeln()
      ..writeln('Приложение: $appVersion ($buildNumber)')
      ..writeln('Платформа: $platform')
      ..writeln('ОС: $osVersion')
      ..writeln('Устройство: $deviceBrand $deviceModel')
      ..writeln('Пользователь: ${userLogin ?? '—'}')
      ..writeln()
      ..writeln('Экран: $screenTitle')
      ..writeln('Форматы: $scanFormats')
      ..writeln()
      ..writeln('mobile_scanner:')
      ..writeln('  initialized: $cameraInitialized')
      ..writeln('  running: $cameraRunning')
      ..writeln('  starting: $cameraStarting')
      ..writeln('  permission: $hasCameraPermission')
      ..writeln('  cameras: ${availableCameras ?? '—'}')
      ..writeln('  facing: $cameraFacing')
      ..writeln('  preview: $previewSize')
      ..writeln('  torch: $torchState');

    if (errorCode != null) {
      buffer
        ..writeln()
        ..writeln('Ошибка: $errorCode')
        ..writeln('Сообщение: ${errorMessage ?? '—'}');
      if (errorDetails != null && errorDetails!.isNotEmpty) {
        buffer.writeln('Детали: $errorDetails');
      }
    }

    buffer.writeln();
    buffer.writeln(
      'Сделайте скриншот и отправьте в поддержку.',
    );
    return buffer.toString();
  }

  static String _formatDateTime(DateTime dt) {
  return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} '
      '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

Future<CameraScanDiagnostics> collectCameraScanDiagnostics({
  required MobileScannerController controller,
  required String screenTitle,
  required List<BarcodeFormat> formats,
  String? userLogin,
  String? initStatusOverride,
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfo = DeviceInfoPlugin();

  var platform = 'unknown';
  var osVersion = 'unknown';
  var deviceModel = 'unknown';
  var deviceBrand = '';

  if (kIsWeb) {
    platform = 'web';
  } else if (Platform.isAndroid) {
    platform = 'android';
    final info = await deviceInfo.androidInfo;
    osVersion =
        'Android ${info.version.release} (SDK ${info.version.sdkInt})';
    deviceModel = info.model;
    deviceBrand = info.manufacturer;
  } else if (Platform.isIOS) {
    platform = 'ios';
    final info = await deviceInfo.iosInfo;
    osVersion = '${info.systemName} ${info.systemVersion}';
    deviceModel = info.utsname.machine;
    deviceBrand = 'Apple';
  }

  final state = controller.value;
  final error = state.error;

  String initStatus;
  if (initStatusOverride != null) {
    initStatus = initStatusOverride;
  } else if (error != null) {
    initStatus = 'ОШИБКА';
  } else if (state.isStarting) {
    initStatus = 'ЗАПУСК…';
  } else if (state.isInitialized && state.isRunning) {
    initStatus = 'OK (камера запущена)';
  } else if (state.isInitialized) {
    initStatus = 'ИНИЦИАЛИЗИРОВАНА, не running';
  } else {
    initStatus = 'НЕ ИНИЦИАЛИЗИРОВАНА';
  }

  final diagnostics = CameraScanDiagnostics(
    collectedAt: DateTime.now(),
    appVersion: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    platform: platform,
    osVersion: osVersion,
    deviceModel: deviceModel,
    deviceBrand: deviceBrand,
    userLogin: userLogin,
    cameraInitialized: state.isInitialized,
    cameraRunning: state.isRunning,
    cameraStarting: state.isStarting,
    hasCameraPermission: state.hasCameraPermission,
    errorCode: error?.errorCode.name,
    errorMessage: error?.errorCode.message,
    errorDetails: error?.errorDetails?.message ?? error?.errorDetails?.code,
    availableCameras: state.availableCameras,
    cameraFacing: state.cameraDirection.name,
    previewSize: '${state.size.width.toInt()}x${state.size.height.toInt()}',
    torchState: state.torchState.name,
    scanFormats: formats.map((f) => f.name).join(', '),
    screenTitle: screenTitle,
    initStatus: initStatus,
  );

  Logger.i('[CameraDiag]\n${diagnostics.toDisplayText()}');
  return diagnostics;
}
