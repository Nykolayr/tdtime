import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
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


