import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/common/camera_scan_diagnostics.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

/// Сканирование QR торговой точки: только QR, устойчивое чтение.
const List<BarcodeFormat> kTtQrScanFormats = [BarcodeFormat.qrCode];

const int kTtQrStableReadCount = 3;

/// Задержка перед start() на iOS — снижает чёрный/белый экран при повторном открытии.
const Duration kIosCameraStartDelay = Duration(milliseconds: 350);

bool get _isIos => !kIsWeb && Platform.isIOS;

Barcode? pickPreferredBarcode(List<Barcode> barcodes) {
  for (final barcode in barcodes) {
    if (barcode.format == BarcodeFormat.qrCode &&
        barcode.rawValue != null &&
        barcode.rawValue!.trim().isNotEmpty) {
      return barcode;
    }
  }
  for (final barcode in barcodes) {
    if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
      return barcode;
    }
  }
  return null;
}

MobileScannerController createScanController({
  required List<BarcodeFormat> formats,
  required bool requireStableRead,
}) {
  return MobileScannerController(
    autoStart: !_isIos,
    formats: formats,
    facing: CameraFacing.back,
    lensType: _isIos ? CameraLensType.normal : CameraLensType.any,
    initialZoom: _isIos ? 1.0 : null,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: requireStableRead ? 500 : 800,
  );
}

class ScanScreen extends StatelessWidget {
  final Function(Barcode) onScan;
  final List<BarcodeFormat>? formats;
  final bool requireStableRead;
  final int stableReadCount;
  final String? title;

  const ScanScreen({
    super.key,
    required this.onScan,
    this.formats,
    this.requireStableRead = false,
    this.stableReadCount = kTtQrStableReadCount,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return _ScanCameraScreen(
      title: title ?? 'Сканирование кода',
      formats: formats ??
          const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
      requireStableRead: requireStableRead,
      stableReadCount: stableReadCount,
      hint: requireStableRead
          ? 'Держите QR торговой точки в рамке'
          : 'Поднесите код к прозрачному окну',
      onScan: onScan,
    );
  }
}

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ScanCameraScreen(
      title: 'Сканирование QR торговой точки',
      formats: kTtQrScanFormats,
      requireStableRead: true,
      stableReadCount: kTtQrStableReadCount,
      hint: 'Держите QR торговой точки в рамке',
      onScan: (_) {},
      popWithGoRouter: true,
    );
  }
}

class _ScanCameraScreen extends StatefulWidget {
  final String title;
  final List<BarcodeFormat> formats;
  final bool requireStableRead;
  final int stableReadCount;
  final String hint;
  final Function(Barcode) onScan;
  final bool popWithGoRouter;

  const _ScanCameraScreen({
    required this.title,
    required this.formats,
    required this.requireStableRead,
    required this.stableReadCount,
    required this.hint,
    required this.onScan,
    this.popWithGoRouter = false,
  });

  @override
  State<_ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<_ScanCameraScreen> {
  late final MobileScannerController _controller;
  bool _isTorchOn = false;
  bool _accepted = false;
  bool _cameraReleased = false;
  bool _diagnosticsShown = false;
  bool _isClosing = false;
  String? _lastStableValue;
  int _stableCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = createScanController(
      formats: widget.formats,
      requireStableRead: widget.requireStableRead,
    );
    _controller.addListener(_onCameraStateChanged);
    if (_isIos) {
      _scheduleIosCameraStart();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onCameraStateChanged);
    unawaited(_stopCamera());
    _controller.dispose();
    super.dispose();
  }

  /// iOS: start после анимации перехода + пауза, чтобы предыдущая сессия успела stop().
  void _scheduleIosCameraStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _cameraReleased) return;

      Future<void> startDelayed() async {
        await Future<void>.delayed(kIosCameraStartDelay);
        if (!mounted || _cameraReleased) return;
        try {
          await _controller.start();
        } catch (e) {
          Logger.e('Camera start error: $e');
        }
      }

      final animation = ModalRoute.of(context)?.animation;
      if (animation == null ||
          animation.status == AnimationStatus.completed) {
        unawaited(startDelayed());
        return;
      }

      void handler(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          animation.removeStatusListener(handler);
          unawaited(startDelayed());
        }
      }

      animation.addStatusListener(handler);
    });
  }

  void _onCameraStateChanged() {
    if (_controller.value.error != null) {
      unawaited(_showDiagnosticsOnError());
    }
    if (mounted) setState(() {});
  }

  Future<void> _stopCamera() async {
    if (_cameraReleased) return;
    _cameraReleased = true;
    try {
      await _controller.stop();
    } catch (e) {
      Logger.e('Camera stop error: $e');
    }
  }

  Future<void> _closeScreen([Object? result]) async {
    if (_isClosing) return;
    _isClosing = true;
    await _stopCamera();
    if (!mounted) return;
    if (widget.popWithGoRouter) {
      context.pop(result);
    } else {
      Navigator.pop(context, result);
    }
  }

  Future<void> _showDiagnosticsOnError() async {
    final error = _controller.value.error;
    if (error == null || _diagnosticsShown || !mounted || _isClosing) {
      return;
    }
    _diagnosticsShown = true;

    final diagnostics = await collectCameraScanDiagnostics(
      controller: _controller,
      screenTitle: widget.title,
      formats: widget.formats,
    );

    if (!mounted || _isClosing) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.blueFon2,
        title: Text(
          'Ошибка камеры',
          style: AppText.medium16.copyWith(color: AppColor.white),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            diagnostics.toDisplayText(),
            style: AppText.text12.copyWith(
              color: AppColor.white,
              fontFamily: 'monospace',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Закрыть',
              style: AppText.medium14.copyWith(color: AppColor.cyan),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDetect(Barcode barcode) async {
    if (_accepted || _isClosing) return;

    final raw = barcode.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    if (widget.requireStableRead) {
      if (raw == _lastStableValue) {
        _stableCount++;
      } else {
        _lastStableValue = raw;
        _stableCount = 1;
      }
      if (_stableCount < widget.stableReadCount) return;
    }

    _accepted = true;
    widget.onScan(barcode);
    await _closeScreen(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _closeScreen(result);
      },
      child: Scaffold(
        appBar: AppBars(
          title: widget.title,
          isBack: true,
          onBackPressed: () => unawaited(_closeScreen()),
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              useAppLifecycleState: true,
              tapToFocus: _isIos,
              errorBuilder: (context, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(_showDiagnosticsOnError());
                });
                return ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error.errorCode.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              onDetect: (capture) async {
                final barcode = pickPreferredBarcode(capture.barcodes);
                if (barcode != null) {
                  await _handleDetect(barcode);
                }
              },
            ),
            const QRScannerOverlay(),
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.hint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: _isTorchOn ? Colors.yellow : Colors.white,
                    size: 40,
                  ),
                  tooltip: 'Включить/выключить фонарик',
                  onPressed: _cameraReleased
                      ? null
                      : () async {
                          await _controller.toggleTorch();
                          if (mounted) {
                            setState(() => _isTorchOn = !_isTorchOn);
                          }
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: CustomPaint(
        painter: QRScannerOverlayPainter(),
      ),
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  const QRScannerOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double windowWidth = 280;
    const double windowHeight = 280;
    const double cornerRadius = 22;
    const double strokeWidth = 4;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: windowWidth,
      height: windowHeight,
    );

    final Path overlay = Path()..addRect(Offset.zero & size);
    final Path hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
          scanRect, const Radius.circular(cornerRadius)));
    final Path mask = Path.combine(PathOperation.difference, overlay, hole);

    final Paint dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(mask, dimPaint);

    final Paint framePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(cornerRadius)),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
