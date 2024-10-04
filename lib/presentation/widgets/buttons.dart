import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// большая кнопка

class ButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String iconPath;
  final bool isNext;
  final bool isEnable;
  const ButtonWide(
      {required this.text,
      required this.onPressed,
      this.isNext = false,
      this.iconPath = '',
      this.isEnable = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.2),
              border: AppDif.borderAll,
              borderRadius: AppDif.borderRadius10,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconPath.isNotEmpty) SvgPicture.asset(iconPath, width: 20),
                if (iconPath.isNotEmpty) const Gap(10),
                Text(text,
                    textAlign: TextAlign.center,
                    style: AppText.button16.copyWith(color: AppColor.white),
                    overflow: TextOverflow.ellipsis),
                if (isNext) const Gap(5),
                if (isNext)
                  const Flexible(
                    child: Icon(Icons.chevron_right,
                        size: 25, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// общий класс для кнопок приложения
class ButtonSelf extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool isBlue;
  final bool isSmall;
  const ButtonSelf(
      {required this.text,
      required this.width,
      required this.height,
      required this.onPressed,
      this.isSmall = false,
      this.isBlue = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              gradient: AppDif.gradientButtons,
              borderRadius: AppDif.borderRadius20,
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: AppDif.borderRadius20,
            ),
            child: Center(
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: isSmall ? AppText.button12 : AppText.button18,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

/// класс с прессетами кнопок приложения
class Buttons {
  /// кнопка входа в приложение
  static ButtonSelf button180(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 180,
      height: 50,
    );
  }

  /// широка кнопка 280
  static ButtonSelf button280(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 280,
      height: 50,
    );
  }

  /// широка кнопка 220
  static ButtonSelf button220(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 220,
      height: 50,
    );
  }

  /// кнопка выхода из профиля
  static ButtonSelf alert(
      {required void Function() onPressed, required String text}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 120,
      height: 40,
      isSmall: true,
    );
  }

  /// кнопка выбора дальнейшего действия
  static ButtonSelf selfChooseBlue(
      {required void Function() onPressed,
      required String text,
      bool isBlue = true}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 156,
      height: 71,
      isBlue: isBlue,
    );
  }

  /// кнопка перехода на таблицы
  static ButtonSelf goTable(
      {required void Function() onPressed,
      required String text,
      bool isBlue = true}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 156,
      height: 71,
      isBlue: isBlue,
    );
  }
}
