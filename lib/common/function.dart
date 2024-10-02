import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

String formatPhoneNumber(String str) {
  const countryCode = '+7';
  if (str.length == 10) {
    final areaCode = str.substring(0, 3);
    final firstPart = str.substring(3, 6);
    final secondPart = str.substring(6, 8);
    final thirdPart = str.substring(8, 10);
    return '$countryCode ($areaCode) $firstPart-$secondPart-$thirdPart';
  } else if (str.length < 11) {
    return str; // Возвращаем исходную строку, если она не соответствует ожидаемому формату
  } else {
    final areaCode = str.substring(1, 4);
    final firstPart = str.substring(4, 7);
    final secondPart = str.substring(7, 9);
    final thirdPart = str.substring(9, 11);
    return '$countryCode ($areaCode) $firstPart-$secondPart-$thirdPart';
  }
}

String formatPhoneNumberToNumber(String str) {
  const countryCode = '+7';
  final phone = str.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '');
  return '$countryCode$phone';
}

/// функция которая возращает null, если нет вхождений
T? findFirstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

/// печать длинных строк
void prints(Object s1) {
  final s = s1.toString();
  final pattern = RegExp('.{1,800}');
  // ignore: avoid_print
  pattern.allMatches(s).forEach((match) => print(match.group(0)));
}

/// функция которая перемешивает список
void shuffle(List<dynamic> elements,
    {int start = 0, int? end, Random? random}) {
  random ??= Random();
  end ??= elements.length;
  var length = end - start;
  while (length > 1) {
    final pos = random.nextInt(length);
    length--;
    final tmp1 = elements[start + pos];
    elements[start + pos] = elements[start + length];
    elements[start + length] = tmp1;
  }
}

/// функция создает различные анимации для переходов по страницам
CustomTransitionPage<dynamic> buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required PageTransitionType type,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    name: state.name,
    child: child,
    transitionDuration: const Duration(
      milliseconds: 250,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        PageTransition(child: child, type: type)
            .buildTransitions(context, animation, secondaryAnimation, child),
  );
}
