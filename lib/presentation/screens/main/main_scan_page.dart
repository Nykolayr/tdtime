import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/get_position.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
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
  MainBloc bloc = Get.find<MainBloc>();
  QRViewController? controller;
  String error = '';
  bool isLoading = false;
  late Barcode result;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SessionScan session = bloc.state.dayHystorySession.listSessions.last;
    Logger.i('statesession ${session.toJson()}');
    if (session.state != StateSession.close) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/main/matrix');
      });
    }
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

    if (result.code == null) {
      error = 'Ошибка сканирования';
    } else {
      isLoading = true;
      setState(() {});
      Position position = await determinePosition();
      isLoading = false;
      setState(() {});
      Logger.i('result >>. ${result.code} === ${position.toJson()}');
      bloc.add(BeginSessinonEvent(id: result.code!, position: position));
      await Future.delayed(const Duration(milliseconds: 300));
      if (bloc.state.error.isEmpty && error.isEmpty) {
        if (mounted) {
          context.go('/main/matrix');
        }
      }

      await Future.delayed(const Duration(seconds: 6));
      error = '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          return true;
        },
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBars(
              title: state.dayHystorySession.listSessions.isEmpty
                  ? 'Сканирование'
                  : 'История посещений ТТ',
              isBack: false,
              isLeft: true,
            ),
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  color: AppColor.blueFon,
                  child: (state.dayHystorySession.listSessions.isEmpty)
                      ? const EmptySession()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const Gap(70),
                              ...state.dayHystorySession.listSessions.reversed
                                  .map(
                                (e) => ItemSession(item: e),
                              )
                            ],
                          ),
                        ),
                ),
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: Column(
                    children: [
                      ButtonWide(
                        text: 'Добавить торговую точку',
                        iconPath: 'assets/svg/reader.svg',
                        onPressed: startScanning,
                      ),
                      const Gap(5),
                      if (state.dayHystorySession.listSessions.isNotEmpty) ...[
                        const Gap(30),
                        ButtonWide(
                          text: 'Закрыть рабочий день',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () => bloc.add(ClosedayEvent()),
                        ),
                      ],
                      SizedBox(
                        height: 20,
                        child: (state.error.isNotEmpty || error.isNotEmpty)
                            ? Text(
                                state.error.isNotEmpty ? state.error : error,
                                style: AppText.medium14.copyWith(
                                  color: AppColor.redError,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                if (state.isLoading || isLoading)
                  const Center(
                      child: CircularProgressIndicator.adaptive(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColor.white))),
              ],
            ),
          );
        });
  }
}
