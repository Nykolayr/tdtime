import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/presentation/screens/main/edti_tt.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/alerts.dart';

import 'bloc/main_bloc.dart';

class ButtonTab extends StatelessWidget {
  final int current;
  final int index;
  final Function onTap;

  const ButtonTab(
      {Key? key,
      required this.current,
      required this.index,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isActive = index == current;

    Color color = isActive ? AppColor.blueFon : AppColor.white;
    Color colorText = !isActive ? AppColor.blueFon : AppColor.white;
    String readerImage =
        isActive ? 'assets/svg/reader.svg' : 'assets/svg/reader_wb.svg';
    String settingImage =
        isActive ? 'assets/svg/settings.svg' : 'assets/svg/settings_wb.svg';
    String iconPath = index == 0 ? readerImage : settingImage;
    String text = index == 0 ? 'Сканирование' : 'Настройки';
    return GestureDetector(
      onTap: () => onTap(index), // Изменено для передачи index
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 30,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(35)),
          border: Border.all(color: AppColor.blueFon, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 16),
            const Gap(7),
            Text(text, style: AppText.medium12.copyWith(color: colorText)),
          ],
        ),
      ),
    );
  }
}

/// Виджет статистики отправки сессий
class UploadStatusWidget extends StatelessWidget {
  final List<SessionScan> sessions;

  const UploadStatusWidget({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    int totalClosed =
        sessions.where((s) => s.state == StateSession.close).length;
    int uploaded = sessions
        .where((s) => s.state == StateSession.close && s.isUploaded)
        .length;
    int pending = totalClosed - uploaded;

    if (totalClosed == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
        border: Border.all(color: AppColor.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_upload,
            color: AppColor.white,
            size: 16,
          ),
          const Gap(8),
          Text(
            'Сессий: $totalClosed',
            style: AppText.text12.copyWith(color: AppColor.white),
          ),
          const Gap(16),
          if (uploaded > 0) ...[
            const Icon(Icons.check_circle, color: AppColor.green, size: 16),
            const Gap(4),
            Text(
              '$uploaded отправлено',
              style: AppText.text12.copyWith(color: AppColor.green),
            ),
            const Gap(16),
          ],
          if (pending > 0) ...[
            const Icon(Icons.schedule, color: AppColor.yellow, size: 16),
            const Gap(4),
            Text(
              '$pending ожидает',
              style: AppText.text12.copyWith(color: AppColor.yellow),
            ),
          ],
        ],
      ),
    );
  }
}

/// пустая страница, когда нет еще ни одной сессии
class EmptySession extends StatelessWidget {
  const EmptySession({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(70),
        const Text(
            'Будьте бдительны при заполнении данных! В случае, если у вас возникли проблемы при эксплуатации данного приложения —пожалуйста, уведомите об этом старшего сотрудника, для скорейшего устранения выявляенных проблем.',
            style: AppText.text10),
        const Gap(50),
        Center(
            child: SvgPicture.asset('assets/svg/scan_icon.svg',
                width: MediaQuery.of(context).size.width - 200)),
        const Gap(120),
      ],
    );
  }
}

/// виджет сессии
class ItemSession extends StatelessWidget {
  final SessionScan? item;
  final String title;
  const ItemSession({
    Key? key,
    this.item,
    this.title = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Определяем статус отправки
    bool isUploaded = item?.isUploaded ?? false;
    bool isClosed = item?.state == StateSession.close;

    return Container(
      width: MediaQuery.of(context).size.width - 50,
      height: isClosed ? 65 : 50,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isClosed
            ? (isUploaded
                ? AppColor.green.withValues(alpha: 0.3)
                : AppColor.yellow.withValues(alpha: 0.3))
            : AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
        border: isClosed
            ? Border.all(
                color: isUploaded ? AppColor.green : AppColor.yellow, width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Иконка статуса
          if (isClosed)
            Icon(
              isUploaded ? Icons.cloud_done : Icons.cloud_upload,
              color: isUploaded ? AppColor.green : AppColor.yellow,
              size: 18,
            )
          else
            SvgPicture.asset('assets/svg/reader.svg', width: 18),
          const Gap(7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text((item != null) ? 'Торговая точка №${item!.id}' : title,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.text14b.copyWith(color: AppColor.white)),
                if (isClosed)
                  Text(
                    isUploaded ? 'Отправлено на сервер' : 'Ожидает отправки',
                    style: AppText.text10.copyWith(
                      color: isUploaded ? AppColor.green : AppColor.yellow,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final controller = TextEditingController(text: item?.id ?? '');
              showModalContent(
                context,
                'Редактирование ID торговой точки',
                EditIdModal(
                  currentId: item!.id,
                  controller: controller,
                ),
                () => Navigator.pop(context),
                () {
                  final newId = controller.text;
                  if (newId.isNotEmpty && newId != item?.id) {
                    Get.find<MainBloc>().add(UpdateSessionIdEvent(
                      oldId: item!.id,
                      newId: newId,
                    ));
                  }
                  Navigator.pop(context);
                },
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
