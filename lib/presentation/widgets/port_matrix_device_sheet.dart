import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tdtime/domain/models/port_matrix_device.dart';
import 'package:tdtime/domain/repository/port_matrix_repository.dart';
import 'package:tdtime/presentation/theme/theme.dart';

Future<PortMatrixDevice?> showPortMatrixDeviceSheet({
  required BuildContext context,
  required PortMatrixRepository repository,
}) async {
  List<PortMatrixDevice> devices = [];
  String? loadingError;

  try {
    devices = await repository.getPairedDevices();
    devices.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aPriority = (aName.contains('port') || aName.contains('matrix')) ? 0 : 1;
      final bPriority = (bName.contains('port') || bName.contains('matrix')) ? 0 : 1;
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return aName.compareTo(bName);
    });
  } catch (e) {
    loadingError = 'Не удалось получить список устройств: $e';
  }

  if (!context.mounted) return null;

  return showModalBottomSheet<PortMatrixDevice>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColor.blueFon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Выберите устройство Port Matrix',
                style: AppText.medium16.copyWith(color: AppColor.white),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Сначала выполните стандартное Bluetooth-сопряжение в настройках телефона.',
                style: AppText.text12.copyWith(color: AppColor.white),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              if (loadingError != null)
                Text(
                  loadingError,
                  style: AppText.text12.copyWith(color: AppColor.redError),
                )
              else if (devices.isEmpty)
                Text(
                  'Сопряженные устройства не найдены.',
                  style: AppText.text12.copyWith(color: AppColor.white),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, index) {
                      final item = devices[index];
                      return Material(
                        color: AppColor.darkBlueMain2,
                        borderRadius: BorderRadius.circular(10),
                        child: ListTile(
                          title: Text(
                            item.name.isEmpty ? 'Без имени' : item.name,
                            style:
                                AppText.medium14.copyWith(color: AppColor.white),
                          ),
                          subtitle: Text(
                            item.address,
                            style:
                                AppText.text12.copyWith(color: AppColor.white),
                          ),
                          onTap: () {
                            Navigator.of(sheetContext).pop(
                              item,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
