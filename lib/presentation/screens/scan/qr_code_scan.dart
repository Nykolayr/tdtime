import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

/// Сканирование QR торговой точки: только QR, устойчивое чтение.
const List<BarcodeFormat> kTtQrScanFormats = [BarcodeFormat.qrCode];

const int kTtQrStableReadCount = 3;

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

class ScanScreen extends StatefulWidget {
  final Function(Barcode) onScan;

  /// Если задано — сканируются только эти форматы; иначе QR + DataMatrix.
  final List<BarcodeFormat>? formats;

  /// Требовать несколько одинаковых чтений подряд (для выбора ТТ).
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
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool _isTorchOn = false;
  bool _accepted = false;
  String? _lastStableValue;
  int _stableCount = 0;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: widget.formats ??
          const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: widget.requireStableRead ? 500 : 800,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  Future<void> _handleDetect(Barcode barcode) async {
    if (_accepted) return;

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
    await controller.stop();
    widget.onScan(barcode);
    if (context.mounted) {
      Navigator.pop(context, barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.requireStableRead
        ? 'Держите QR торговой точки в рамке'
        : 'Поднесите код к прозрачному окну';

    return Scaffold(
      appBar: AppBars(
        title: widget.title ?? 'Сканирование кода',
        isBack: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
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
                hint,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
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
                onPressed: () async {
                  await controller.toggleTorch();
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                },
              ),
            ),
          ),
        ],
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

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    formats: kTtQrScanFormats,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
  );

  bool _isTorchOn = false;
  bool _accepted = false;
  String? _lastStableValue;
  int _stableCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  Future<void> _handleDetect(Barcode barcode) async {
    if (_accepted) return;

    final raw = barcode.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    if (raw == _lastStableValue) {
      _stableCount++;
    } else {
      _lastStableValue = raw;
      _stableCount = 1;
    }
    if (_stableCount < kTtQrStableReadCount) return;

    _accepted = true;
    await controller.stop();
    if (context.mounted) {
      context.pop(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBars(title: 'Сканирование QR торговой точки', isBack: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final barcode = pickPreferredBarcode(capture.barcodes);
              if (barcode != null) {
                await _handleDetect(barcode);
              }
            },
          ),
          const QRScannerOverlay(),
          const Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Держите QR торговой точки в рамке',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
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
                onPressed: () async {
                  await controller.toggleTorch();
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
