import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/common/tt_id_parser.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/domain/repository/routers_repository.dart';
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

  Future<String?> _resolveNewId(BuildContext context, String raw) async {
    final parsed = TtIdParser.parse(raw);
    if (parsed == null) {
      await showErrorAlert(
        context,
        'Не удалось распознать номер ТТ.\nУкажите код в формате УТ-…',
      );
      return null;
    }

    final bloc = Get.find<MainBloc>();
    if (!bloc.state.isFree) {
      final catalog = Get.find<RoutersRepository>();
      final mc = TtIdParser.findInList(catalog.marketCenters, parsed);
      if (mc == null) {
        await showErrorAlert(
          context,
          'ТТ $parsed не найдена в справочнике.',
        );
        return null;
      }
    }

    final confirmed = await showTtStartConfirmation(
      context,
      ttId: parsed,
    );
    if (!confirmed) return null;

    return parsed;
  }

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
              final scanResult = await Navigator.push<Barcode>(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanScreen(
                    formats: kTtQrScanFormats,
                    requireStableRead: true,
                    title: 'Сканирование QR торговой точки',
                    onScan: (_) {},
                  ),
                ),
              );

              if (scanResult?.rawValue == null || !context.mounted) return;
              if (scanResult!.format == BarcodeFormat.dataMatrix) return;

              final newId =
                  await _resolveNewId(context, scanResult.rawValue!);
              if (newId == null || !context.mounted) return;

              Get.find<MainBloc>().add(UpdateSessionIdEvent(
                oldId: currentId,
                newId: newId,
              ));
              if (context.mounted) {
                Navigator.of(context).pop();
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
        completer.complete(false);
      },
      () {
        Get.find<MainBloc>().add(DeleteMatrixEvent(id: id));
        Navigator.of(context).pop();
        completer.complete(true);
      },
      butText: 'Удалить',
    );

    return completer.future;
  }
}
