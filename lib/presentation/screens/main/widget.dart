import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/presentation/theme/theme.dart';

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
            style: AppText.text14),
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
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/svg/reader.svg', width: 18),
          const Gap(7),
          Expanded(
            child: Text(
                (item != null)
                    ? 'Сессия от ${item!.getDate()} №${item!.id}'
                    : title,
                overflow: TextOverflow.ellipsis,
                style: AppText.text14b.copyWith(color: AppColor.white)),
          ),
        ],
      ),
    );
  }
}
