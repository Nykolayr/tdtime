import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/alerts.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/text_field2.dart';

class EditIdModal extends StatelessWidget {
  final String currentId;
  final TextEditingController controller;

  const EditIdModal({
    super.key,
    required this.currentId,
    required this.controller,
  });

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

              if (result.rawValue != null) {
                if (result.format != BarcodeFormat.dataMatrix) {
                  Get.find<MainBloc>().add(UpdateSessionIdEvent(
                    oldId: currentId,
                    newId: result.rawValue!,
                  ));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
          ),
          const Gap(20),
          ButtonWide(
            text: 'Удалить ТТ',
            iconPath: 'assets/svg/trash.svg',
            onPressed: () async {
              bool? result =
                  await showDeleteConfirmationModal(context, currentId);
              if (result == true) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  // Новый метод для отображения диалогового окна подтверждения
  Future<bool?> showDeleteConfirmationModal(BuildContext context, String id) {
    final Completer<bool?> completer = Completer<bool?>();

    showModalContent(
      context,
      'Подтверждение удаления',
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Вы уверены, что хотите удалить сессию ТТ?'),
        ],
      ),
      () {
        Navigator.of(context).pop();
        // Действие при отмене
        completer.complete(false); // Возвращаем false
      },
      () {
        Get.find<MainBloc>().add(DeleteMatrixEvent(id: id));
        Navigator.of(context).pop();
        completer.complete(true); // Возвращаем true
      },
      butText: 'Удалить',
    );

    return completer.future; // Возвращаем Future
  }
}
