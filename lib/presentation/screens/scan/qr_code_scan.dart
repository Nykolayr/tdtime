import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

class ScanScreen extends StatefulWidget {
  final Function(Barcode) onScan;

  /// Если задано — сканируются только эти форматы; иначе QR + DataMatrix.
  final List<BarcodeFormat>? formats;

  const ScanScreen({
    super.key,
    required this.onScan,
    this.formats,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: widget.formats ??
          const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 800,
    );
    // для отслеживания changeLifecycle
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBars(title: 'Сканирование кода', isBack: true),
      body: Stack(
        children: [
          // Камера и сканер
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                await controller.stop();
                widget.onScan(barcode);
                if (context.mounted) {
                  Navigator.pop(context, barcode);
                }
              }
            },
          ),
          // Overlay с одной прозрачной областью
          const QRScannerOverlay(),
          // Подсказка
          const Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Поднесите код к прозрачному окну',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Кнопка фонарика
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
    // Параметры окна сканирования
    const double windowWidth = 280;
    const double windowHeight = 280;
    const double cornerRadius = 22;
    const double strokeWidth = 4;

    // Прямоугольник сканирования по центру экрана
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: windowWidth,
      height: windowHeight,
    );

    // Затемняем всё, кроме окна (прозрачный «вырез»)
    final Path overlay = Path()..addRect(Offset.zero & size);
    final Path hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
          scanRect, const Radius.circular(cornerRadius)));
    final Path mask = Path.combine(PathOperation.difference, overlay, hole);

    final Paint dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(mask, dimPaint);

    // Рисуем одну рамку (скруглённый прямоугольник)
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
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 800,
  );

  bool _isTorchOn = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBars(title: 'Сканирование кода', isBack: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                await controller.stop();
                if (context.mounted) {
                  context.pop(barcode);
                }
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
                'Поднесите QR-код ближе к центру окна',
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
