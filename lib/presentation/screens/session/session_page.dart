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

  /// Начало сканирования DataMatrix (только этот формат).
  void startScanning() async {
    isLoading = true;
    setState(() {});
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(
          formats: const [BarcodeFormat.dataMatrix],
          onScan: (Barcode scanResult) {
            result = scanResult;
          },
        ),
      ),
    );

    if (result.rawValue == null) {
      error = 'Ошибка сканирования';
      setState(() {});
    } else {
      Logger.i('result >>. ${result.rawValue} === ${result.format}');
      bloc.add(AddMatrixEvent(id: result.rawValue!));
    }
    isLoading = false;
    setState(() {});
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    if (mounted) {
      setState(() {});
    }
  }

  /// Сканирование только PDF417.
  void startPdf417Scanning() async {
    isLoading = true;
    setState(() {});
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(
          formats: const [BarcodeFormat.pdf417],
          onScan: (Barcode scanResult) {
            result = scanResult;
          },
        ),
      ),
    );

    if (result.rawValue == null) {
      error = 'Ошибка сканирования';
      setState(() {});
    } else {
      Logger.i('result PDF417 >>. ${result.rawValue}');
      bloc.add(AddMatrixEvent(id: result.rawValue!));
    }
    isLoading = false;
    setState(() {});
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    if (mounted) {
      setState(() {});
    }
  }

  /// Форматы, которые уже вынесены в отдельные кнопки — не показываем в «Другие».
  static const _existingFormats = [
    BarcodeFormat.dataMatrix,
    BarcodeFormat.pdf417,
  ];

  /// Форматы, применяемые в РФ — в шторке показываем только их (UPC, Codabar, Aztec и т.п. убраны).
  static const _formatsUsedInRF = [
    BarcodeFormat.qrCode,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.itf,
  ];

  /// Название и описание формата для шторки (название (описание)).
  static String _formatLabel(BarcodeFormat f) {
    switch (f) {
      case BarcodeFormat.qrCode:
        return 'QR-код (двумерный, ссылки и текст)';
      case BarcodeFormat.code128:
        return 'Code 128 (логистика, этикетки, документы)';
      case BarcodeFormat.code39:
        return 'Code 39 (промышленность, медицина)';
      case BarcodeFormat.ean13:
        return 'EAN-13 (товары в магазинах)';
      case BarcodeFormat.ean8:
        return 'EAN-8 (короткий товарный код)';
      case BarcodeFormat.itf:
        return 'ITF (коробки, паллеты)';
      default:
        return f.name;
    }
  }

  /// Показать шторку выбора «другого» типа штрихкода.
  void _showOtherFormatsSheet() {
    final otherFormats = BarcodeFormat.values
        .where((f) =>
            !_existingFormats.contains(f) &&
            _formatsUsedInRF.contains(f) &&
            f != BarcodeFormat.unknown &&
            f != BarcodeFormat.all)
        .toList();

    if (otherFormats.isEmpty) return;

    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: screenHeight * 0.75,
        decoration: const BoxDecoration(
          color: AppColor.blueFon,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Выберите тип штрихкода',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < otherFormats.length; i++) ...[
                        if (i > 0) const Gap(14),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              startOtherFormatScanning(otherFormats[i]);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.darkBlueMain2,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatLabel(otherFormats[i]),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Сканирование одного выбранного формата из «Другие типы».
  Future<void> startOtherFormatScanning(BarcodeFormat format) async {
    if (!mounted) return;
    isLoading = true;
    setState(() {});
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(
          formats: [format],
          onScan: (Barcode scanResult) {
            result = scanResult;
          },
        ),
      ),
    );

    if (result.rawValue == null) {
      error = 'Ошибка сканирования';
      setState(() {});
    } else {
      Logger.i('result ${format.name} >>. ${result.rawValue}');
      bloc.add(AddMatrixEvent(id: result.rawValue!));
    }
    isLoading = false;
    setState(() {});
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    if (mounted) setState(() {});
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
                        const Gap(12),
                        ButtonWide(
                          text: 'Сканировать PDF417',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: startPdf417Scanning,
                        ),
                        // const Gap(12),
                        // ButtonWide(
                        //   text: 'Другие типы',
                        //   iconPath: 'assets/svg/reader.svg',
                        //   onPressed: _showOtherFormatsSheet,
                        // ),
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
