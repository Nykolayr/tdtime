import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/week_routers.dart';
import 'package:tdtime/domain/repository/routers_repository.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/get_position.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/alerts.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/universal_dropdown.dart';

class MainScanPage extends StatefulWidget {
  final void Function(int) onTabChange;
  const MainScanPage({Key? key, required this.onTabChange}) : super(key: key);

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
  WeekDay selectedDay = WeekDay.values[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    if (bloc.state.errorShowMessage.isNotEmpty) {
      if (bloc.state.errorShowMessage.contains('all_tt')) {
        showModalContent(
          context,
          'Внимание!',
          const Text(
              'У вас нет доступа к списку торговых точек, попробовать еще раз  загрузить?'),
          () {
            bloc.add(ResetErrorEvent());
            Get.find<RoutersRepository>().init();
            Navigator.of(context).pop();
          },
          () {
            Navigator.of(context).pop();
          },
        );
      } else {
        showModalContent(
          context,
          'Внимание!',
          Text(
              'Такого файла ${Get.find<RoutersRepository>().filePath} не существует, поменять файл в настройках?'),
          () {
            Navigator.of(context).pop();
            widget.onTabChange(1);
          },
          () {
            Navigator.of(context).pop();
            widget.onTabChange(1);
          },
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bloc.state.dayHystorySession.listSessions.isEmpty) return;
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

  void startSession() async {
    isLoading = true;
    setState(() {});
    Position position = Position.fromMap({
      'latitude': 0.0,
      'longitude': 0.0,
      'accuracy': 0.0,
      'altitude': 0.0,
      'altitudeAccuracy': 0.0,
      'heading': 0.0,
      'speed': 0.0,
      'speedAccuracy': 0.0,
      'timestamp': 0,
    });
    try {
      position = await determinePosition().timeout(const Duration(seconds: 3));
    } catch (e) {
      Logger.e('Ошибка при определения местоположения $e');
    } finally {
      isLoading = false;
      setState(() {});
    }

    bloc.add(BeginSessinonEvent(
        id: bloc.state.selectedMarketCenter.id, position: position));
    await Future.delayed(const Duration(milliseconds: 300));
    if (bloc.state.error.isEmpty && error.isEmpty) {
      if (mounted) {
        context.go('/main/matrix');
      }
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
                  bottom: 170,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.todayRouters.isEmpty &&
                          state.dayHystorySession.listSessions.isEmpty)
                        UniversalDropdown<WeekDay>(
                          items: WeekDay.values,
                          value: selectedDay,
                          onChanged: (day) {
                            if (day != null) {
                              setState(() => selectedDay = day);
                            }
                          },
                          label: 'Выберите день недели',
                          itemToString: (day) => day.title,
                        ),
                      if (state.todayRouters.isNotEmpty &&
                          state.selectedMarketCenter.name.isNotEmpty)
                        UniversalDropdown<MarketCenter>(
                          items: state.todayRouters,
                          value: state.selectedMarketCenter,
                          onChanged: (mc) {
                            if (mc != null) {
                              bloc.add(
                                  SelectMarketCenterEvent(marketCenter: mc));
                            }
                          },
                          label: 'Выберите торговую точку',
                          itemToString: (mc) => mc.name,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  child: Column(
                    children: [
                      if (state.todayRouters.isEmpty)
                        Text(
                          'На сегодняшний день, маршрут выполнен',
                          style: AppText.medium14.copyWith(
                            color: AppColor.white,
                          ),
                        ),
                      if (state.todayRouters.isNotEmpty)
                        ButtonWide(
                          text: 'Дальше',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () {
                            if (state.todayRouters.isEmpty) {
                              bloc.add(SelectDayEvent(day: selectedDay));
                            } else {
                              startSession();
                            }
                          },
                        ),
                      const Gap(5),
                      if (state.dayHystorySession.listSessions.isNotEmpty) ...[
                        const Gap(10),
                        ButtonWide(
                          text: 'Закрыть рабочий день',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () => bloc.add(ClosedayEvent()),
                        ),
                      ],
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 40,
                        child: (state.error.isNotEmpty || error.isNotEmpty)
                            ? Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      state.error.isNotEmpty
                                          ? state.error
                                          : error,
                                      style: AppText.medium14.copyWith(
                                        color: AppColor.redError,
                                      ),
                                      softWrap: true,
                                      maxLines: 4,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
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
