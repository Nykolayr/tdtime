import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

class MainScanPage extends StatefulWidget {
  const MainScanPage({Key? key}) : super(key: key);
  @override
  State<MainScanPage> createState() => MainScanPageState();
}

class MainScanPageState extends State<MainScanPage> {
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
        await Future.delayed(const Duration(milliseconds: 300));
        // if (mounted) {
        //   context.go('/main');
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: Get.find<MainBloc>(),
        buildWhen: (previous, current) {
          return true;
        },
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: const AppBars(
              title: 'Сканирование',
              isBack: false,
              isLeft: true,
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: AppColor.blueFon,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(20),
                        const Text(
                            'Будьте бдительны при заполнении данных! В случае, если у вас возникли проблемы при эксплуатации данного приложения —пожалуйста, уведомите об этом старшего сотрудника, для скорейшего устранения выявляенных проблем.',
                            style: AppText.text14),
                        const Gap(50),
                        Center(
                            child: SvgPicture.asset('assets/svg/scan_icon.svg',
                                width:
                                    MediaQuery.of(context).size.width - 200)),
                        const Gap(120),
                        ButtonWide(
                          text: 'Начать новую сессию',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: startScanning,
                        ),
                        const Gap(35),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
