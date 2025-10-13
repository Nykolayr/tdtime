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
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/get_position.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/alerts.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/text_field2.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkError();
      // Проверяем неотправленные сессии при инициализации
      bloc.add(LoadUnsentSessionsEvent());
      // Восстанавливаем незавершенный день
      bloc.add(RestoreUnfinishedDayEvent());
      // Получаем прогресс дня
      bloc.add(GetDayProgressEvent());
      // Обновляем состояние при возврате на главную страницу
      _updateStateFromRepositories();
      // Проверяем свободный режим
      _checkFreeMode();
      // Проверяем, нужно ли перейти на страницу истории
      // _checkAndNavigateToHistory(); // Убираем автоматический переход
    });

    // Слушаем изменения роутера для автоматического закрытия сессии в свободном режиме
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    controller?.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    final currentLocation = GoRouterState.of(context).uri.toString();

    // Если вернулись на главную страницу из сканирования в свободном режиме
    if (currentLocation == '/main' && !bloc.state.isRouters) {
      // Закрываем сессию автоматически
      bloc.add(CloseSessionEvent());
    }
  }

  /// Проверка свободного режима
  void _checkFreeMode() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      final routersRepo = Get.find<RoutersRepository>();

      // Если нет маршрутов вообще, включаем свободный режим
      if (routersRepo.weekRouters.isEmpty) {
        Logger.i('Включаем свободный режим: weekRouters пустой');
        bloc.add(const SetFreeModeEvent(isFreeMode: true));
        await showFreeModeDialog();
      }
    }
  }

  /// Обновление состояния из репозиториев
  void _updateStateFromRepositories() {
    bloc.add(GetDayProgressEvent());
  }

  /// Диалог о включении свободного режима
  Future<void> showFreeModeDialog() async {
    final user = Get.find<UserRepository>().user;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Свободный режим'),
        content: Text(
          'В файле ${user.filePath} нет маршрутов для сегодняшнего дня. Включен свободный режим работы.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  /// Проверка и навигация на страницу истории при наличии неотправленных сессий
  void _checkAndNavigateToHistory() async {
    // Ждем немного, чтобы состояние обновилось
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      final state = bloc.state;
      final userRepo = Get.find<UserRepository>();

      // Проверяем, есть ли неотправленные сессии
      bool hasUnsentSessions = state.hasUnsentSessions;

      // Проверяем, завершен ли день
      bool isDayCompleted = userRepo.lastDay.state == StateSession.close;

      // Если есть неотправленные сессии (даже если день закрыт), переходим на страницу истории
      if (hasUnsentSessions) {
        Logger.i(
            'Обнаружены неотправленные сессии, переходим на страницу истории');
        context.go('/main/history');
      }
      // Если день завершен и все отправлено, переходим к новому дню
      else if (isDayCompleted && !hasUnsentSessions) {
        Logger.i('День завершен и все отправлено, начинаем новый день');
        bloc.add(StartNewDayEvent());
      }
    }
  }

  void checkError() async {
    // Проверяем, есть ли данные о маршрутах - если есть, то ошибки нет
    final routersRepo = Get.find<RoutersRepository>();
    Logger.i(
        'checkError: weekRouters.length = ${routersRepo.weekRouters.length}');
    Logger.i('checkError: errorMessage = "${routersRepo.errorMessage}"');
    Logger.i('checkError: errorShowMessage = "${bloc.state.errorShowMessage}"');

    if (routersRepo.weekRouters.isNotEmpty) {
      // Данные загружены успешно, не показываем ошибку
      Logger.i('checkError: Данные загружены успешно, пропускаем показ ошибки');
      return;
    }

    // Если включен свободный режим, не показываем ошибку о маршрутах
    if (bloc.state.isFreeMode) {
      Logger.i(
          'checkError: Свободный режим активен, пропускаем показ ошибки о маршрутах');
      return;
    }

    if (bloc.state.errorShowMessage.isNotEmpty ||
        routersRepo.errorMessage.isNotEmpty) {
      if (bloc.state.errorShowMessage.contains('all_tt')) {
        // Если нет доступа к интернету, показываем ошибку, но продолжаем работу
        await showErrorAlert(
          context,
          'Нет доступа к интернету. Данные загружены из локального хранилища. Работа продолжается.',
          onOk: () {
            bloc.add(ResetErrorEvent());
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            // Просто закрываем диалог и продолжаем работу
          },
        );
      } else {
        bloc.add(NewFileEvent(
          fileName: Get.find<UserRepository>().user.filePath,
          isFileExist: routersRepo.isFileExist,
        ));
        await showErrorAlert(
          context,
          'Такого файла ${Get.find<UserRepository>().user.filePath} не существует, спросите у администратора название файла и поменяйте его в настройках!',
          onOk: () {
            if (mounted) {
              widget.onTabChange(1);
            }
          },
        );
      }
    }
  }

  /// Начало сессии в свободном режиме
  void _startFreeModeSession() {
    // Показываем диалог выбора ТТ
    _showTTSearchDialog();
  }

  /// Диалог поиска ТТ в свободном режиме
  void _showTTSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.blueFon,
        title: Text(
          'Ввод торговой точки',
          style: AppText.medium16.copyWith(color: AppColor.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Введите название торговой точки:',
              style: AppText.text14.copyWith(color: AppColor.white),
            ),
            const SizedBox(height: 16),
            BestFormField(
              iconPath: 'assets/svg/account.svg',
              hint: 'Название торговой точки',
              controller: controller,
              validator: (value) =>
                  value?.isNotEmpty == true ? null : 'Введите название ТТ',
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ButtonWide(
                  text: 'Отмена',
                  iconPath: 'assets/svg/exit.svg',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ButtonWide(
                  text: 'ОК',
                  iconPath: 'assets/svg/start.svg',
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      _processTTSelection(controller.text);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Обработка выбранной ТТ
  void _processTTSelection(String ttInfo) async {
    // Создаем временную ТЦ для свободного режима
    final tempMarketCenter = MarketCenter(
      id: 'free_${DateTime.now().millisecondsSinceEpoch}',
      name: ttInfo,
      address: 'Свободный режим',
      phone: '',
    );

    // Устанавливаем выбранную ТЦ
    bloc.add(SelectMarketCenterEvent(marketCenter: tempMarketCenter));

    // Начинаем сессию с переданным названием ТТ
    startSession(ttName: ttInfo);
  }

  void startSession({String? ttName}) async {
    // Проверяем, есть ли активная сессия
    if (bloc.state.dayHystorySession.listSessions.isNotEmpty) {
      SessionScan lastSession = bloc.state.dayHystorySession.listSessions.last;
      if (lastSession.state != StateSession.close) {
        // Есть активная сессия - переходим к сканированию DataMatrix
        if (mounted) {
          context.go('/main/matrix');
        }
        return;
      }
    }

    // Убираем проверку на маршруты - она не нужна

    // Обычный режим - начинаем сессию с выбранной ТЦ
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
      position = await determinePosition().timeout(const Duration(seconds: 10));
    } catch (e) {
      Logger.e('Ошибка при определения местоположения $e');
      // Используем координаты по умолчанию если геолокация не работает
      position = Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        isMocked: false,
        floor: null,
      );
    }

    // В свободном режиме используем переданное название ТТ, в обычном - ID из маршрута
    String ttId = bloc.state.isRouters
        ? bloc.state.selectedMarketCenter.id
        : (ttName ?? bloc.state.selectedMarketCenter.name);

    Logger.i('startSession: isRouters = ${bloc.state.isRouters}');
    Logger.i(
        'startSession: selectedMarketCenter.id = ${bloc.state.selectedMarketCenter.id}');
    Logger.i(
        'startSession: selectedMarketCenter.name = ${bloc.state.selectedMarketCenter.name}');
    Logger.i('startSession: ttName = $ttName');
    Logger.i('startSession: ttId = $ttId');

    bloc.add(BeginSessinonEvent(id: ttId, position: position));

    isLoading = false;
    setState(() {});

    // Ждем немного для обработки события и переходим
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.go('/main/matrix');
    }
  }

  /// Виджет прогресса для свободного режима
  Widget _buildFreeModeProgressWidget(MainState state, int completed) {
    Logger.i(
        '_buildFreeModeProgressWidget: completed = $completed, hasUnsentSessions = ${state.hasUnsentSessions}');
    Logger.i(
        '_buildFreeModeProgressWidget: unsentSessions = ${state.unsentSessions}');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
        border: Border.all(color: AppColor.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed > 0 ? Icons.check_circle : Icons.schedule,
                color: completed > 0 ? AppColor.green : AppColor.yellow,
                size: 16,
              ),
              const Gap(8),
              Text(
                'Прогресс дня',
                style: AppText.medium12.copyWith(color: AppColor.white),
              ),
            ],
          ),
          const Gap(8),
          Text(
            completed > 0
                ? 'Обработано $completed точек'
                : 'Обработано 0 точек',
            style: AppText.text12.copyWith(color: AppColor.white),
          ),
          const Gap(8),
          // Счетчик неотправленных сессий
          _buildUnsentCounter(state),
          const Gap(12),
          // Кнопка просмотра истории
          SizedBox(
            width: double.infinity,
            child: ButtonWide(
              text: 'Просмотр посещений',
              iconPath: 'assets/svg/reader.svg',
              onPressed: () {
                context.go('/main/history');
              },
            ),
          ),
          const Gap(12),
          // Кнопка отправки неотправленных сессий (если есть)
          _buildUploadAllButton(state),
        ],
      ),
    );
  }

  /// Виджет прогресса дня
  Widget _buildDayProgressWidget(MainState state) {
    if (state.dayProgress.isEmpty) return const SizedBox.shrink();

    int total = state.dayProgress['total'] as int? ?? 0;
    int completed = state.dayProgress['completed'] as int? ?? 0;
    int remaining = state.dayProgress['remaining'] as int? ?? 0;
    bool isCompleted = state.dayProgress['isCompleted'] as bool? ?? false;
    double progress = state.dayProgress['progress'] as double? ?? 0.0;

    // СВОБОДНЫЙ РЕЖИМ - упрощенный виджет без прогресс-бара
    if (!state.isRouters) {
      // В свободном режиме берем длину списка посещений вместо completed
      int actualCompleted = state.dayHystorySession.listSessions.length;
      return _buildFreeModeProgressWidget(state, actualCompleted);
    }

    // Проверяем, это свободный график (нет данных о днях недели)
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
        border: Border.all(color: AppColor.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                color: isCompleted ? AppColor.green : AppColor.yellow,
                size: 16,
              ),
              const Gap(8),
              Text(
                isCompleted ? 'День завершен' : 'Прогресс дня',
                style: AppText.medium12.copyWith(color: AppColor.white),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Обработано: $completed из $total торговых точек',
            style: AppText.text12.copyWith(color: AppColor.white),
          ),
          if (remaining > 0) ...[
            const Gap(4),
            Text(
              'Осталось: $remaining',
              style: AppText.text12.copyWith(color: AppColor.yellow),
            ),
          ],
          const Gap(8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColor.grey,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? AppColor.green : AppColor.blue,
            ),
          ),
          const Gap(8),
          // Счетчик неотправленных сессий
          _buildUnsentCounter(state),
          const Gap(12),
          // Кнопка просмотра истории
          SizedBox(
            width: double.infinity,
            child: ButtonWide(
              text: 'Просмотр посещений',
              iconPath: 'assets/svg/reader.svg',
              onPressed: () {
                context.go('/main/history');
              },
            ),
          ),
          const Gap(12),
          // Кнопка отправки неотправленных сессий (если есть)
          _buildUploadAllButton(state),
        ],
      ),
    );
  }

  /// Виджет статуса отправки сессий
  Widget _buildUploadStatusWidget(MainState state) {
    UserRepository repo = Get.find<UserRepository>();
    Map<String, dynamic> status = repo.getTodayUploadStatus();

    int totalClosed = status['totalClosed'] as int;
    int pending = status['pending'] as int;
    bool allUploaded = status['allUploaded'] as bool;

    // Проверяем общее количество неотправленных сессий
    bool hasAnyUnsent = state.hasUnsentSessions;

    if (totalClosed == 0 && !hasAnyUnsent) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статус отправки для сегодняшнего дня
        if (totalClosed > 0) ...[
          Text(
            allUploaded ? 'Все сессии отправлены' : 'Не все сессии отправлены',
            style: AppText.medium12.copyWith(
              color: allUploaded ? AppColor.green : AppColor.redError,
            ),
          ),
          const Gap(8),
        ],

        // Информация о неотправленных сессиях из других дней
        if (hasAnyUnsent) ...[
          Text(
            'Есть неотправленные сессии из предыдущих дней',
            style: AppText.medium12.copyWith(
              color: AppColor.redError,
            ),
          ),
          const Gap(8),
          ButtonWide(
            text: 'Просмотреть неотправленные сессии',
            iconPath: 'assets/svg/reader.svg',
            onPressed: () {
              _showUnsentSessionsDialog(state);
            },
          ),
          const Gap(8),
        ],

        // Кнопка принудительной отправки для сегодняшнего дня
        if (pending > 0)
          ButtonWide(
            text: 'Отправить все сессии ($pending)',
            iconPath: 'assets/svg/reader.svg',
            onPressed: () {
              bloc.add(ForceUploadAllSessionsEvent());
            },
          ),
      ],
    );
  }

  /// Диалог с неотправленными сессиями
  void _showUnsentSessionsDialog(MainState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Неотправленные сессии'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.unsentSessions.length,
            itemBuilder: (context, index) {
              String dayKey = state.unsentSessions.keys.elementAt(index);
              List<SessionScan> sessions = state.unsentSessions[dayKey]!;

              return Card(
                child: ListTile(
                  title: Text('День: $dayKey'),
                  subtitle: Text('Неотправленных сессий: ${sessions.length}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      bloc.add(UploadSessionsForDayEvent(dayKey: dayKey));
                    },
                    child: const Text('Отправить'),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          // Обновляем UI при изменении прогресса дня или неотправленных сессий
          bool shouldUpdate = previous.dayProgress != current.dayProgress ||
              previous.hasUnsentSessions != current.hasUnsentSessions ||
              previous.dayHystorySession != current.dayHystorySession;

          if (shouldUpdate) {
            Logger.i(
                'buildWhen: обновляем UI - dayProgress: ${previous.dayProgress} -> ${current.dayProgress}');
            Logger.i(
                'buildWhen: обновляем UI - hasUnsentSessions: ${previous.hasUnsentSessions} -> ${current.hasUnsentSessions}');
            Logger.i(
                'buildWhen: обновляем UI - dayHystorySession.length: ${previous.dayHystorySession.listSessions.length} -> ${current.dayHystorySession.listSessions.length}');
          }

          return shouldUpdate;
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Gap(70),
                        // Прогресс дня
                        _buildDayProgressWidget(state),
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
                      if (state.shouldShowDaySelection)
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
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  child: Column(
                    children: [
                      if (state.shouldShowDaySelection) ...[
                        // Показываем статус только если есть выполненные сессии
                        if (state
                            .dayHystorySession.listSessions.isNotEmpty) ...[
                          Text(
                            'На сегодняшний день, маршрут выполнен',
                            style: AppText.medium14.copyWith(
                              color: AppColor.white,
                            ),
                          ),
                          const Gap(8),
                          _buildUploadStatusWidget(state),
                        ],
                      ],
                      if (state.shouldShowDaySelection) ...[
                        // Всегда показываем кнопку для выбора дня (свободный график)
                        ButtonWide(
                          text: 'Начать работу',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () {
                            bloc.add(SelectDayEvent(day: selectedDay));
                          },
                        ),
                      ] else if (!state.isRouters) ...[
                        // СВОБОДНЫЙ РЕЖИМ - кнопка "Дальше"
                        ButtonWide(
                          text: 'Дальше',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () {
                            _startFreeModeSession();
                          },
                        ),
                      ] else if (state.todayRouters.isNotEmpty) ...[
                        ButtonWide(
                          text: 'Дальше',
                          iconPath: 'assets/svg/reader.svg',
                          onPressed: () {
                            startSession();
                          },
                        ),
                      ],
                      const Gap(5),
                      if (state.dayHystorySession.listSessions.isNotEmpty) ...[
                        const Gap(10),
                        _buildCloseDayButton(state),
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

  /// Счетчик неотправленных сессий
  Widget _buildUnsentCounter(MainState state) {
    UserRepository repo = Get.find<UserRepository>();
    Map<String, dynamic> status = repo.getTodayUploadStatus();
    int pending = status['pending'] as int;

    if (pending == 0) return const SizedBox.shrink();

    return Text(
      'Неотправленных: $pending',
      style: AppText.text12.copyWith(color: AppColor.redError),
    );
  }

  /// Кнопка закрытия рабочего дня
  Widget _buildCloseDayButton(MainState state) {
    UserRepository repo = Get.find<UserRepository>();
    Map<String, dynamic> status = repo.getTodayUploadStatus();
    int pending = status['pending'] as int;
    bool hasUnsentSessions = pending > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWide(
          text: 'Закрыть рабочий день',
          iconPath: 'assets/svg/reader.svg',
          onPressed:
              hasUnsentSessions ? () {} : () => bloc.add(ClosedayEvent()),
          isEnable:
              !hasUnsentSessions, // Делаем кнопку недоступной если есть неотправленные
        ),
        if (hasUnsentSessions) ...[
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Закрыть рабочий день нельзя\nиз-за неотправленных посещений',
              style: AppText.text12.copyWith(color: AppColor.redError),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ],
    );
  }

  /// Пустое состояние - показываем кнопку сканирования

  /// Кнопка отправки всех неотправленных сессий
  Widget _buildUploadAllButton(MainState state) {
    UserRepository repo = Get.find<UserRepository>();
    Map<String, dynamic> status = repo.getTodayUploadStatus();
    int pending = status['pending'] as int;

    // Показываем кнопку только если есть неотправленные сессии
    if (pending == 0) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ButtonWide(
        text: 'Отправить все',
        iconPath: 'assets/svg/start.svg',
        onPressed: () async {
          try {
            bloc.add(ForceUploadAllSessionsEvent());
            // Показываем сообщение о начале отправки
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Отправка сессий...'),
                backgroundColor: AppColor.blue,
              ),
            );
          } catch (e) {
            if (mounted) {
              await showErrorAlert(
                context,
                'Ошибка отправки: $e',
                onOk: () {
                  // Просто закрываем диалог, не делаем дополнительных действий
                },
              );
            }
          }
        },
      ),
    );
  }
}
