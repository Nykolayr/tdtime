import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

class ScanScreen extends StatelessWidget {
  final Function(Barcode) onScan;

  const ScanScreen({Key? key, required this.onScan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.blueFon.withOpacity(0.1),
      appBar: const AppBars(title: 'Сканирование QR-кода', isBack: true),
      body: QRView(
        overlay: QrScannerOverlayShape(
          borderWidth: 10,
          borderRadius: 15,
        ),
        key: GlobalKey(),
        onQRViewCreated: (controller) {
          controller.scannedDataStream.listen((scanData) async {
            Logger.i('scanData === ${scanData.code} == ${scanData.format}  ');
            controller.dispose();
            onScan(scanData);
            if (context.mounted) {
              Navigator.pop(context, scanData);
            }
          });
        },
      ),
    );
  }
}
