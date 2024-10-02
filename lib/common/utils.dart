import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  /// высчитываем разницу между двумя датами вплоть до миллисекунд
  static Duration getDurationDifferent(
    DateTime date1,
    DateTime date2,
  ) {
    int diffInMilliseconds = date2.difference(date1).inMilliseconds;

    int hours = (diffInMilliseconds ~/ (1000 * 60 * 60)) % 24;
    int minutes = (diffInMilliseconds ~/ (1000 * 60)) % 60;
    int seconds = (diffInMilliseconds ~/ 1000) % 60;
    int milliseconds = diffInMilliseconds % 1000;
    return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds);
  }

  static String getFormatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static String getDateYear(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy', 'ru');
    return formatter.format(date);
  }

  static String getDateMonth(DateTime date) {
    final DateFormat formatter = DateFormat('MMMM', 'ru');
    return formatter.format(date);
  }

  static String getDateDay(DateTime date) {
    final DateFormat formatter = DateFormat('dd', 'ru');
    return formatter.format(date);
  }

  static String getFormatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy', 'ru');
    return formatter.format(date);
  }

  static String getFormatDateHour(DateTime date) {
    final DateFormat formatter = DateFormat('H:mm:ss', 'ru');
    return formatter.format(date);
  }

  static String getFormatDateHourWithMilliseconds(DateTime date) {
    String milliseconds = date.millisecond.toString().padLeft(3, '0');
    DateFormat dateFormat = DateFormat('H:mm:ss', 'ru');
    return '${dateFormat.format(date)},$milliseconds';
  }

  static String getFormatDurationWithMilliseconds(Duration duration) {
    int milliseconds = duration.inMilliseconds % 1000;
    return '${duration.inHours.toString().padLeft(1, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')},${milliseconds.toString().padLeft(3, '0')}';
  }

  // static String hashPassword(String password) {
  //   var bin = utf8.encode(password);
  //   return sha256.convert(bin).toString();
  // }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Поле не может быть пустым';
    }

    final errors = <String>[];

    if (!RegExp('^(?=.*?[a-z])').hasMatch(password)) {
      errors.add('Хотя бы 1 строчная буква');
    }

    if (!RegExp('^(?=.*?[A-Z])').hasMatch(password)) {
      errors.add('Хотя бы 1 заглавная буква');
    }

    if (!RegExp('^(?=.*?[0-9])').hasMatch(password)) {
      errors.add('Хотя бы 1 цифра');
    }

    if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(password)) {
      errors.add('Хотя бы 1 символ');
    }

    if (!RegExp(r'^.{8,}$').hasMatch(password)) {
      errors.add('Минимум 8 символов');
    }

    if (errors.isNotEmpty) return 'Требования к паролю:\n${errors.join('\n')}';

    return null;
  }

  static String normalizePhone(String phone) {
    return phone
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('+', '');
  }

  static String? validateNotEmpty(String? value, String message) {
    return (value == null || value.isEmpty) ? message : null;
  }

  static String? validatePhone(String? value, String message) {
    return (value == null || value.isEmpty || value.length != 15)
        ? message
        : null;
  }

  static String? validateEmail(String? value, String message) {
    final re = RegExp(r'.+@.+\..+');
    return (value == null || value.isEmpty || !re.hasMatch(value))
        ? message
        : null;
  }

  static String? validateCompareValues(
      String? value1, String? value2, String message) {
    return (value1 == null ||
            value1.isEmpty ||
            value2 == null ||
            value2.isEmpty ||
            value1 != value2)
        ? message
        : null;
  }

  static Widget circularProgressIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}
