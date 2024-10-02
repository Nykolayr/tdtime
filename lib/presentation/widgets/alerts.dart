import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// общий класс для алертов приложения
class AlertSelf extends StatelessWidget {
  final String text;
  final String subText;
  const AlertSelf({required this.text, required this.subText, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0), // скругление углов
      ),
      alignment: Alignment.center,
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      title: Center(
        child:
            Text(text, style: AppText.title18.copyWith(color: AppColor.redPro)),
      ),
      content: Text(subText, style: AppText.table12),
      actions: <Widget>[
        Buttons.alert(
          text: 'Отмена',
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        Buttons.alert(
          text: 'Подтвердить',
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

/// Для показа кастомного содержимого
Future<void> showModalContent(BuildContext context, String text, Widget child,
    Function() cansel, Function() save,
    {String butText = 'Сохранить'}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20),
        title: Text(text, textAlign: TextAlign.center, style: AppText.title18),
        content: child,
        actions: <Widget>[
          Buttons.alert(
            text: 'Отмена',
            onPressed: cansel,
          ),
          Buttons.alert(
            text: butText,
            onPressed: save,
          ),
        ],
      );
    },
  );
}

/// Алерт для выхода из профиля
Future<bool?> showExitProfileAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const AlertSelf(
          text: 'Внимание!',
          subText: 'Вы уверены, что хотите выйти из профиля?');
    },
  );
}

/// Алерт для ошибок api
void showErrorDialog(String errorMessage) async {
  if (Get.context != null) {
    await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка при работе с сервером',
              style: AppText.text14.copyWith(color: AppColor.redPro)),
          content: Text(errorMessage, style: AppText.textField12),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Алерт для сообщения
Future showInfo(context, String title, {required Widget content}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(title, style: AppText.text14),
        ),
        content: content,
      );
    },
  );
}
