import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
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
  MobileScannerController? controller;
  bool _isClosingSession = false;
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

  /// Закрытие сессии с лоадером
  void _closeSession() {
    _closeSessionAsync();
  }

  /// Асинхронное закрытие сессии
  void _closeSessionAsync() async {
    setState(() {
      _isClosingSession = true;
    });

    try {
      // Сначала закрываем сессию в UserRepository
      UserRepository userRepo = Get.find<UserRepository>();
      await userRepo.closeSession();

      // Потом обновляем состояние в MainBloc
      bloc.add(CloseSessionEvent());

      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        GoRouter.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClosingSession = false;
        });
      }
    }
  }

  /// начало сканирования дата матрикс
  void startScanning() async {
    isLoading = true;
    setState(() {});
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScanScreen(onScan: (Barcode scanResult) {
                result = scanResult;
              })),
    );

    if (result.rawValue == null) {
      error = 'Ошибка сканирования';
      setState(() {});
    } else {
      if (result.format != BarcodeFormat.dataMatrix) {
        error = 'Это не  DataMatrix формат!';
        setState(() {});
      } else {
        Logger.i('result >>. ${result.rawValue} === ${result.format}');

        bloc.add(AddMatrixEvent(id: result.rawValue!));
        if (bloc.state.error.isEmpty && error.isEmpty) {}
      }
    }
    isLoading = false;
    setState(() {});
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    if (mounted) {
      setState(() {});
    }
  }

  /// отмена сканирования
  void exitScanning() {
    bloc.add(UndoMatrixEvent());

    if (context.mounted) {
      GoRouter.of(context).pop();
    }
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
      child: BlocBuilder<MainBloc, MainState>(
          bloc: bloc,
          buildWhen: (previous, current) {
            return true;
          },
          builder: (context, state) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBars(
                title: 'ТТ ${state.curSession.id}',
                isBack: false,
                isLeft: true,
              ),
              body: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    color: AppColor.blueFon,
                    child: (state.dayHystorySession.listSessions.isEmpty)
                        ? const EmptySession()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                const Gap(70),
                                ...state.dayHystorySession.listSessions.last
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
                        const Gap(20),
                        ButtonWide(
                          text: _isClosingSession
                              ? 'Отправка данных...'
                              : 'Закончить сканирование в ТТ',
                          iconPath: 'assets/svg/exit.svg',
                          onPressed: _isClosingSession ? () {} : _closeSession,
                        ),
                        const Gap(20),
                        ButtonWide(
                          text: 'Отменить сканирование ТТ',
                          iconPath: 'assets/svg/undo.svg',
                          onPressed: exitScanning,
                        ),
                        const Gap(10),
                        // Убираем показ ошибок на странице ТТ
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
          }),
    );
  }
}
