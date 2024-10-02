import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Кнопка с иконкой Svg для вертикальной панели ФРД
class ButtonsIconSvgFrd extends StatelessWidget {
  final ButtonIconSvg buttonIcon;
  final Function() onPressed;

  const ButtonsIconSvgFrd(
      {required this.buttonIcon, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        padding: const EdgeInsets.all(6),
        height: 42,
        width: 42,
        child: SvgPicture.asset(buttonIcon.pathIcon),
      ),
    );
  }
}

/// Кнопка с иконкой Svg для вертикальной панели ФРД
class ButtonsIconSvgFhn extends StatelessWidget {
  final ButtonIconSvg buttonIcon;
  final bool isSmall;
  final Function() onPressed;

  const ButtonsIconSvgFhn(
      {required this.buttonIcon,
      required this.onPressed,
      this.isSmall = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    double size = isSmall ? 42 : 47;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        padding: const EdgeInsets.all(6),
        height: size,
        width: size,
        child: SvgPicture.asset(buttonIcon.pathIcon),
      ),
    );
  }
}

/// Кнопка с иконкой
class ButtonsIcon extends StatelessWidget {
  final ButtonIcon buttonIcon;
  final Function() onPressed;

  const ButtonsIcon(
      {required this.buttonIcon, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: buttonIcon.getIcon,
      ),
    );
  }
}

enum ButtonIcon {
  micOn,
  micOff;

  Icon get getIcon {
    switch (this) {
      case ButtonIcon.micOn:
        return const Icon(Icons.mic, color: AppColor.yellow, size: 45);
      case ButtonIcon.micOff:
        return const Icon(Icons.mic_off, color: AppColor.yellow, size: 45);
    }
  }
}

enum ButtonIconSvg {
  share,
  save,
  block,
  redo,
  voice,
  offVoice,
  alarm,
  delete,
  saveAlt,
  info,
  plus;

  String get pathIcon => 'assets/svg/$name.svg';
}
