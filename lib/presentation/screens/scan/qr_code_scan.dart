import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

class ScanScreen extends StatefulWidget {
  final Function(Barcode) onScan;

  const ScanScreen({Key? key, required this.onScan}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBars(title: 'Сканирование QR-кода', isBack: true),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first;
            Logger.i('scanData === ${barcode.rawValue} == ${barcode.format}');
            widget.onScan(barcode);
            if (context.mounted) {
              Navigator.pop(context, barcode);
            }
          }
        },
      ),
    );
  }
}

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key? key}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBars(title: 'Сканирование QR-кода', isBack: true),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first;
            Logger.i('QR scan result: ${barcode.rawValue} (${barcode.format})');

            if (context.mounted) {
              // Возвращаем результат через GoRouter
              context.pop(barcode);
            }
          }
        },
      ),
    );
  }
}
