import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String error = '';
  late Barcode result;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void startScanning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScanScreen(onScan: (Barcode scanResult) {
                result = scanResult;
              })),
    );
    if (!mounted) return;
    setState(() {});
    if (result.code == null) {
      error = 'Ошибка сканирования';
    } else {
      List<String> fio = result.code!.split(' ');
      Logger.i('fio ${fio.length} = $fio');
      if (fio.length != 3) {
        error = 'Отсканированные данные не соответсвуют формату';
      } else {
        Random random = Random();
        int randomNumber = random.nextInt(99901) + 1000;
        String id = 'ID-$randomNumber';
        Get.find<AuthBloc>().add(AuthUserEvent(
            family: fio[0], name: fio[1], patron: fio[2], id: id));
        controller?.dispose();
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.go('/main');
        }
      }
    }

    await Future.delayed(const Duration(seconds: 8));
    setState(() {
      error = '';
    });
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColor.blueFon,
          child: Stack(
            fit: StackFit.expand,
            alignment: AlignmentDirectional.topCenter,
            children: [
              Column(
                children: [
                  const Gap(60),
                  const Text('Сканируйте', style: AppText.bold30),
                  const Text('Сохраняйте', style: AppText.medium22),
                  const Text('Отправляйте', style: AppText.field16),
                  const Gap(20),
                  const Text('Данные о посещениях \nв торговых точках',
                      style: AppText.medium22, textAlign: TextAlign.center),
                  const Gap(20),
                  Stack(
                    children: [
                      Image.asset('assets/run.gif'), // Ваш GIF
                      Positioned.fill(
                        child: Container(
                          color: AppColor.blueFon
                              .withOpacity(0.7), // Прозрачность 50%
                        ),
                      ),
                    ],
                  ),
                  const Gap(30),
                ],
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        text: 'Авторизация',
                        iconPath: 'assets/svg/start.svg',
                        onPressed: () {
                          context.goNamed('авторизация');
                        }),
                    const Gap(35),
                    ButtonWide(
                      text: 'Авторизация по QR',
                      iconPath: 'assets/svg/qr_code.svg',
                      onPressed: startScanning,
                    ),
                    const Gap(20),
                    Center(
                        child: Text('Версия ${Get.find<PackageInfo>().version}',
                            style: AppText.text14.copyWith(
                              fontWeight: FontWeight.w400,
                            ))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
