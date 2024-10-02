import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class AppDif {
  static const Divider divider = Divider(color: AppColor.grey, height: 1);
  static const Radius radius20 = Radius.circular(20);
  static const Radius radius10 = Radius.circular(10);
  static const Radius radius5 = Radius.circular(5);
  static const BorderRadius borderRadius20 = BorderRadius.all(radius20);
  static const BorderRadius borderRadius10 = BorderRadius.all(radius10);
  static const BorderRadius borderRadius5 = BorderRadius.all(radius5);
  static BoxShadow boxShadowMain = BoxShadow(
    color: AppColor.blackText.withOpacity(0.5), // Цвет тени
    spreadRadius: 0, // Радиус рассеивания
    blurRadius: 25, // Радиус размытия
    offset: const Offset(0, 4), // Смещение тени
  );
  static BoxShadow boxCard = BoxShadow(
    color: Colors.black.withOpacity(0.25), // 25% прозрачность
    blurRadius: 150, // Размытие
    offset: const Offset(0, 4), // Смещение по X и Y
  );
  static const LinearGradient gradientTextButtons = LinearGradient(
    colors: [
      AppColor.col1,
      AppColor.col2,
      AppColor.col3,
      AppColor.col4,
      AppColor.col5,
    ],
    stops: [0.06, 0.24, 0.55, 0.79, 1.0], // Расстояния между цветами
    begin: Alignment.topLeft, // Начальная точка градиента
    end: Alignment.bottomRight, // Конечная точка градиента
    transform: GradientRotation(
        54.41 * 3.1415926535 / 180), // Угол вращения в радианах (45 градусов)
  );

  static const LinearGradient gradientButtons = LinearGradient(
    colors: [
      AppColor.col1,
      AppColor.col2,
      AppColor.col3,
      AppColor.col4,
      AppColor.col5,
    ],
    stops: [0.06, 0.24, 0.55, 0.79, 1.0], // Расстояния между цветами
    begin: Alignment.topLeft, // Начальная точка градиента
    end: Alignment.bottomRight, // Конечная точка градиента
    transform: GradientRotation(
        54.41 * 3.1415926535 / 180), // Угол вращения в радианах (45 градусов)
  );
  static const LinearGradient gradientFon = LinearGradient(
    colors: [
      AppColor.col1,
      AppColor.col2,
      AppColor.col3,
      AppColor.col4,
      AppColor.col5,
    ],
    stops: [0.06, 0.24, 0.55, 0.79, 1.0], // Расстояния между цветами
    begin: Alignment.topLeft, // Начальная точка градиента
    end: Alignment.bottomRight, // Конечная точка градиента
    transform: GradientRotation(
        132.14 * 3.1415926535 / 180), // Угол вращения в радианах (45 градусов)
  );
  static LinearGradient gradientFonOpacity = LinearGradient(
    colors: [
      AppColor.col1.withOpacity(0.05),
      AppColor.col2.withOpacity(0.05),
      AppColor.col3.withOpacity(0.05),
      AppColor.col4.withOpacity(0.05),
      AppColor.col5.withOpacity(0.05),
    ],
    stops: const [0.06, 0.24, 0.55, 0.79, 1.0], // Расстояния между цветами
    begin: Alignment.topLeft, // Начальная точка градиента
    end: Alignment.bottomRight, // Конечная точка градиента
    transform: const GradientRotation(
        132.14 * 3.1415926535 / 180), // Угол вращения в радианах (45 градусов)
  );

  static gradientWithOpacity(double opacity) => LinearGradient(
        colors: [
          AppColor.col1.withOpacity(opacity),
          AppColor.col2.withOpacity(opacity),
          AppColor.col3.withOpacity(opacity),
          AppColor.col4.withOpacity(opacity),
          AppColor.col5.withOpacity(opacity),
        ],
        stops: const [0.06, 0.24, 0.55, 0.79, 1.0], // Расстояния между цветами
        begin: Alignment.topLeft, // Начальная точка градиента
        end: Alignment.bottomRight, // Конечная точка градиента
        transform: const GradientRotation(132.14 * 3.1415926535 / 180),
      );
  static LinearGradient gradientOnlyMain = const LinearGradient(
    stops: [0.65, 1.0],
    colors: [
      AppColor.darkBlueMain1,
      AppColor.darkBlueMain2,
    ],
    begin: Alignment.topCenter, // Начальная точка градиента
    end: Alignment.bottomCenter, // Конечная точка градиента
  );

  static const LinearGradient gradientFonMain = LinearGradient(
    stops: [0.65, 1.0],
    colors: [
      AppColor.darkBlue1,
      AppColor.darkBlue2,
    ],
    begin: Alignment.topLeft, // Начальная точка градиента
    end: Alignment.bottomRight, // Конечная точка градиента
    transform: GradientRotation(32.14 * 3.1415926535 / 180),
  );
  static LinearGradient gradientOpacity = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: const [0.05, 0.75],
    colors: [
      Colors.black.withOpacity(0.0),
      Colors.black.withOpacity(0.48),
    ],
  );
  static BoxBorder borderAll = Border.all(
    color: AppColor.white,
    width: 1,
  );
  static Decoration decotationBlueRadius = BoxDecoration(
    borderRadius: borderRadius20,
    color: AppColor.lightblue,
    border: Border.all(
      color: AppColor.white,
      width: 1,
    ),
  );

  /// общий для всех textField
  static InputDecoration getInputDecoration(
      {required String hint, bool isTitle = false}) {
    return InputDecoration(
      errorStyle: const TextStyle(fontSize: 10, height: 0.3),
      border: getOutlineBorder(),
      focusedBorder: getOutlineBorder(),
      enabledBorder: getOutlineBorder(),
      disabledBorder: getOutlineBorder(),
      errorBorder: getOutlineBorder(color: AppColor.redPro),
      focusedErrorBorder: getOutlineBorder(color: AppColor.redPro),
      filled: true,
      hintStyle: const TextStyle(color: AppColor.darkGrey),
      hintText: hint,
      fillColor: AppColor.lightblue,
      contentPadding: isTitle
          ? null
          : const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
    );
  }

  static OutlineInputBorder getOutlineBorder({Color color = AppColor.white}) {
    return OutlineInputBorder(
      borderRadius: AppDif.borderRadius20,
      borderSide: BorderSide(
        width: 1,
        style: BorderStyle.solid,
        color: color,
      ),
    );
  }
}
