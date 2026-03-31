import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tdtime/domain/models/port_matrix_device.dart';
import 'package:tdtime/domain/repository/port_matrix_repository.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/port_matrix_device_sheet.dart';

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
  bool _isConnectingPortMatrix = false;
  bool _isPortMatrixConnected = false;
  String error = '';
  String _portMatrixStatus = 'Не подключен';
  bool isLoading = false;
  /// Результат последнего скана с камеры (null, если закрыли экран без скана).
  Barcode? _cameraScanResult;
  final PortMatrixRepository _portMatrixRepository =
      Get.find<PortMatrixRepository>();
  StreamSubscription<String>? _portScanSubscription;
  StreamSubscription<bool>? _portConnectionSubscription;
  @override
  void initState() {
    super.initState();
    _portMatrixStatus = _portMatrixRepository.defaultDevice == null
        ? 'Устройство не выбрано'
        : 'Устройство выбрано: ${_portMatrixRepository.defaultDevice!.name}';
    _isPortMatrixConnected = _portMatrixRepository.isConnected;
    _portConnectionSubscription =
        _portMatrixRepository.connectionStream.listen((connected) {
      if (!mounted) return;
      setState(() {
        _isPortMatrixConnected = connected;
        if (connected) {
          final name =
              _portMatrixRepository.defaultDevice?.name ?? 'Port Matrix';
          _portMatrixStatus = 'Подключен: $name';
        } else if (_portMatrixRepository.defaultDevice != null) {
          _portMatrixStatus =
              'Отключен: ${_portMatrixRepository.defaultDevice!.name}';
        } else {
          _portMatrixStatus = 'Не подключен';
        }
      });
    });
    _portScanSubscription = _portMatrixRepository.scanCodeStream.listen((code) {
      final parsed = code.trim();
      if (parsed.isEmpty) return;
      bloc.add(AddMatrixEvent(id: parsed));
      _showPortScanToast(parsed);
    });
    _tryAutoConnectPortMatrix();
  }

  @override
  void dispose() {
    _portScanSubscription?.cancel();
    _portConnectionSubscription?.cancel();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _connectPortMatrix() async {
    if (_isConnectingPortMatrix) return;
    setState(() {
      _isConnectingPortMatrix = true;
      _portMatrixStatus = 'Подключение...';
    });

    final supported = await _portMatrixRepository.isBluetoothSupported();
    if (!supported) {
      if (!mounted) return;
      setState(() {
        _isConnectingPortMatrix = false;
        _portMatrixStatus = 'Bluetooth не поддерживается';
      });
      return;
    }

    final enabled = await _portMatrixRepository.isBluetoothEnabled();
    if (!enabled) {
      if (!mounted) return;
      setState(() {
        _isConnectingPortMatrix = false;
        _portMatrixStatus = 'Включите Bluetooth на устройстве';
      });
      return;
    }

    PortMatrixDevice? targetDevice = _portMatrixRepository.defaultDevice;
    if (targetDevice == null) {
      targetDevice = await showPortMatrixDeviceSheet(
        // ignore: use_build_context_synchronously
        context: context,
        repository: _portMatrixRepository,
      );
      if (targetDevice == null) {
        if (!mounted) return;
        setState(() {
          _isConnectingPortMatrix = false;
          _portMatrixStatus = 'Устройство не выбрано';
        });
        return;
      }
    }

    final connected = await _portMatrixRepository.connectAndSaveDefault(
      device: targetDevice,
    );

    if (!mounted) return;
    setState(() {
      _isConnectingPortMatrix = false;
      _isPortMatrixConnected = connected;
      _portMatrixStatus =
          connected ? 'Подключен: ${targetDevice!.name}' : 'Ошибка подключения';
    });
  }

  Future<void> _tryAutoConnectPortMatrix() async {
    if (_portMatrixRepository.defaultDevice == null ||
        _portMatrixRepository.isConnected) {
      return;
    }
    setState(() {
      _isConnectingPortMatrix = true;
      _portMatrixStatus = 'Автоподключение...';
    });
    final connected = await _portMatrixRepository.connectToDefaultDevice();
    if (!mounted) return;
    setState(() {
      _isConnectingPortMatrix = false;
      _isPortMatrixConnected = connected;
      _portMatrixStatus = connected
          ? 'Подключен: ${_portMatrixRepository.defaultDevice!.name}'
          : 'Не удалось автоподключиться';
    });
  }

  void _showPortScanToast(String code) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Port Matrix: отсканирован код $code'),
        backgroundColor: AppColor.blue,
        duration: const Duration(seconds: 3),
      ),
    );
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
    _cameraScanResult = null;
    isLoading = true;
    setState(() {});
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(
            formats: const [BarcodeFormat.dataMatrix],
            onScan: (Barcode scanResult) {
              _cameraScanResult = scanResult;
            },
          ),
        ),
      );

      final scan = _cameraScanResult;
      if (scan == null || scan.rawValue == null) {
        error = 'Ошибка сканирования';
        setState(() {});
      } else {
        Logger.i('result >>. ${scan.rawValue} === ${scan.format}');
        bloc.add(AddMatrixEvent(id: scan.rawValue!));
      }
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
    await Future.delayed(const Duration(seconds: 8));
    error = '';
    if (mounted) {
      setState(() {});
    }
  }

  /// Сканирование только PDF417.
  void startPdf417Scanning() async {
    _cameraScanResult = null;
    isLoading = true;
    setState(() {});
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(
            formats: const [BarcodeFormat.pdf417],
            onScan: (Barcode scanResult) {
              _cameraScanResult = scanResult;
            },
          ),
        ),
      );

      final scan = _cameraScanResult;
      if (scan == null || scan.rawValue == null) {
        error = 'Ошибка сканирования';
        setState(() {});
      } else {
        Logger.i('result PDF417 >>. ${scan.rawValue}');
        bloc.add(AddMatrixEvent(id: scan.rawValue!));
      }
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
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
                        : _ScannedPositionsList(
                            dataMatrix:
                                state.dayHystorySession.listSessions.last.dataMatrix,
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
                        const Gap(12),
                        ButtonWide(
                          text: _isConnectingPortMatrix
                              ? 'Подключение Port Matrix...'
                              : _isPortMatrixConnected
                                  ? 'Port Matrix подключен'
                                  : 'Портматрикс',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: _connectPortMatrix,
                        ),
                        const Gap(8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: Text(
                            _portMatrixStatus,
                            style:
                                AppText.text12.copyWith(color: AppColor.white),
                            textAlign: TextAlign.center,
                          ),
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
                  if (isLoading || _isClosingSession)
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

/// Список отсканированных позиций товара в ТТ — без построения сотен виджетов сразу.
class _ScannedPositionsList extends StatelessWidget {
  final List<String> dataMatrix;

  const _ScannedPositionsList({required this.dataMatrix});

  @override
  Widget build(BuildContext context) {
    final count = dataMatrix.length;
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: Gap(70)),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 320),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final code = dataMatrix[count - 1 - index];
                return ItemSession(
                  key: ValueKey(code),
                  title: code,
                );
              },
              childCount: count,
            ),
          ),
        ),
      ],
    );
  }
}
