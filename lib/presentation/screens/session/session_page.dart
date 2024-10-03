import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

class DataMatrixScanPage extends StatefulWidget {
  const DataMatrixScanPage({Key? key}) : super(key: key);
  @override
  State<DataMatrixScanPage> createState() => DataMatrixScanPageState();
}

class DataMatrixScanPageState extends State<DataMatrixScanPage> {
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
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// закрытие сессии
  void closeSession() {}

  /// начало сканирования дата матрикс
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
      setState(() {});
    } else {
      if (result.format != BarcodeFormat.dataMatrix) {
        error = 'Это не  DataMatrix формат!';
        setState(() {});
      } else {
        Logger.i('result >>. ${result.code} === ${result.format}');

        bloc.add(AddMatrixEvent(id: result.code!));
        await Future.delayed(const Duration(milliseconds: 300));
        if (bloc.state.error.isEmpty && error.isEmpty) {}
      }
    }
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    setState(() {});
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
              title: 'Сессия №${state.curSession.id}',
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
                  child: (state.curHystorySession.listSessions.isEmpty)
                      ? const EmptySession()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const Gap(70),
                              ...state.curHystorySession.listSessions.last
                                  .dataMatrix.reversed
                                  .map(
                                (e) => ItemSession(title: e),
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
                        text: 'Сканировать DataMatrix',
                        iconPath: 'assets/svg/reader.svg',
                        onPressed: startScanning,
                      ),
                      if (state.curHystorySession.listSessions.isNotEmpty &&
                          state.curHystorySession.listSessions.last.dataMatrix
                              .isNotEmpty) ...[
                        const Gap(15),
                        ButtonWide(
                          text: 'Закрыть сессию',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: closeSession,
                        ),
                      ],
                      const Gap(10),
                      SizedBox(
                        height: 30,
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
