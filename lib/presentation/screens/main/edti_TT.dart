import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/text_field2.dart';

class EditIdModal extends StatelessWidget {
  final String currentId;
  final TextEditingController controller;

  const EditIdModal({
    Key? key,
    required this.currentId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColor.blueFon,
        borderRadius: AppDif.borderRadius10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BestFormField(
            iconPath: 'assets/svg/reader.svg',
            hint: 'ID торговой точки',
            controller: controller,
            validator: (value) => Utils.validateNotEmpty(value, 'Укажите ID'),
            keyboardType: TextInputType.text,
          ),
          const Gap(20),
          ButtonWide(
            text: 'Сканировать QR',
            iconPath: 'assets/svg/qr_code.svg',
            onPressed: () async {
              late Barcode result;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanScreen(
                    onScan: (Barcode scanResult) {
                      result = scanResult;
                    },
                  ),
                ),
              );
              if (result.code != null) {
                Get.find<MainBloc>().add(UpdateSessionIdEvent(
                  oldId: currentId,
                  newId: result.code!,
                ));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
