import 'dart:math';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';

import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/text_field2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String error = '';
  late Barcode result;
  final nameController = TextEditingController();
  final familyController = TextEditingController();
  final idController = TextEditingController();
  final patronController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AuthBloc bloc = Get.find<AuthBloc>();

  void startScanning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScanScreen(onScan: (Barcode scanResult) {
                result = scanResult;
              })),
    );
    setState(() {
      if (result.code == null) {
        error = 'Ошибка сканирования';
      } else {
        List<String> fio = result.code!.split(' ');

        if (fio.length != 3) {
          error = 'Отсканированные данные не соответсвуют формату';
        } else {
          Random random = Random();
          int randomNumber = random.nextInt(99901) + 1000;
          String id = 'ID-$randomNumber';
          Get.find<AuthBloc>().add(AuthUserEvent(
              family: fio[0], name: fio[1], patron: fio[2], id: id));

          if (context.mounted) context.go('/main');
        }
      }
    });

    await Future.delayed(const Duration(seconds: 8));
    setState(() {
      error = '';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    idController.dispose();
    patronController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const AppBars(title: 'Авторизация', isBack: false),
        resizeToAvoidBottomInset: false,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColor.blueFon,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Gap(60),
                  const Text('Будьте бдительны при заполнении данных!',
                      style: AppText.text18),
                  const Gap(20),
                  const Text(
                      'В случае, если у вас возникли проблемы при эксплуатации данного приложения —пожалуйста, уведомите об этом старшего сотрудника, для скорейшего устранения выявляенных проблем.',
                      style: AppText.text14),
                  const Gap(20),
                  BestFormField(
                    iconPath: 'assets/svg/account.svg',
                    hint: 'Фамилия',
                    controller: familyController,
                    validator: (value) =>
                        Utils.validateNotEmpty(value, 'Укажите Фамилию'),
                    keyboardType: TextInputType.name,
                  ),
                  BestFormField(
                    iconPath: 'assets/svg/account.svg',
                    hint: 'Имя',
                    controller: nameController,
                    validator: (value) =>
                        Utils.validateNotEmpty(value, 'Укажите имя'),
                    keyboardType: TextInputType.name,
                  ),
                  BestFormField(
                    iconPath: 'assets/svg/account.svg',
                    hint: 'Отчество',
                    controller: patronController,
                    validator: (value) =>
                        Utils.validateNotEmpty(value, 'Укажите отчество'),
                    keyboardType: TextInputType.name,
                  ),
                  BestFormField(
                    iconPath: 'assets/svg/account.svg',
                    hint: 'ID агента',
                    controller: idController,
                    validator: (value) =>
                        Utils.validateNotEmpty(value, 'Укажите ID агента'),
                    keyboardType: TextInputType.name,
                    isCapitalization: false,
                  ),
                  if (error.isNotEmpty)
                    Container(
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.topCenter,
                      child: Text(
                        error,
                        style: AppText.medium14.copyWith(
                          color: AppColor.redError,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    const Gap(45),
                  ButtonWide(
                      text: 'Войти в приложение',
                      iconPath: 'assets/svg/start.svg',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          bloc.add(AuthUserEvent(
                            name: nameController.text,
                            family: familyController.text,
                            patron: patronController.text,
                            id: idController.text,
                          ));
                          context.go('/main');
                        }
                      }),
                  const Gap(35),
                  ButtonWide(
                    text: 'Остканировать QR',
                    iconPath: 'assets/svg/qr_code.svg',
                    onPressed: startScanning,
                  ),
                  const Gap(35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RectCustomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) =>
      oldClipper != this;
}
