import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/week_routers.dart';
import 'package:tdtime/domain/repository/routers_repository.dart';
import 'package:tdtime/domain/repository/user_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<BeginSessinonEvent>(_onBeginSessinonEvent);
    on<AddMatrixEvent>(_onAddMatrixEvent);
    on<ClosedayEvent>(_onClosedayEvent);
    on<CloseSessionEvent>(_onCloseSessionEvent);
    on<ExitUserEvent>(_onExitUserEvent);
    on<UpdateSessionIdEvent>(_onUpdateSessionIdEvent);
    on<UndoMatrixEvent>(_onUndoMatrixEvent);
    on<DeleteMatrixEvent>(_onDeleteMatrixEvent);
    on<LoadRoutersEvent>(_onLoadRoutersEvent);
    on<UpdateWeekRoutersEvent>(_onUpdateWeekRoutersEvent);
    on<SelectDayEvent>(_onSelectDayEvent);
    on<SelectMarketCenterEvent>(_onSelectMarketCenterEvent);
    on<ShowErrorEvent>(_onShowErrorEvent);
    on<LoadMarketCentersEvent>(_onLoadMarketCentersEvent);
    on<ResetErrorEvent>(_onResetErrorEvent);
    on<NewFileEvent>(_onNewFileEvent);
    on<ForceUploadAllSessionsEvent>(_onForceUploadAllSessionsEvent);
    on<LoadUnsentSessionsEvent>(_onLoadUnsentSessionsEvent);
    on<UploadSessionsForDayEvent>(_onUploadSessionsForDayEvent);
    on<RestoreUnfinishedDayEvent>(_onRestoreUnfinishedDayEvent);
    on<GetDayProgressEvent>(_onGetDayProgressEvent);
    on<StartNewDayEvent>(_onStartNewDayEvent);
    on<CheckFirstLoginEvent>(_onCheckFirstLoginEvent);
    on<SetFreeModeEvent>(_onSetFreeModeEvent);
  }

  /// новый файл
  Future<void> _onNewFileEvent(
      NewFileEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(
      isFileExist: event.isFileExist,
      filePath: event.fileName,
    ));
  }

  /// сброс ошибки
  Future<void> _onResetErrorEvent(
      ResetErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(errorShowMessage: ''));
  }

  /// загрузка списка ТЦ
  Future<void> _onLoadMarketCentersEvent(
      LoadMarketCentersEvent event, Emitter<MainState> emit) async {
    RoutersRepository repo = Get.find<RoutersRepository>();
    emit(state.copyWith(isLoading: true, isFileExist: false));
    String answer = await repo.loadFromFtpTT(event.fileName);
    emit(state.copyWith(isLoading: false));
    Logger.e('answer: $answer');
    if (answer.isEmpty) {
      emit(state.copyWith(
        isFileExist: repo.isFileExist,
        filePath: Get.find<UserRepository>().user.filePath,
        marketCenters: repo.marketCenters,
        todayRouters: repo.todayRouters,
        selectedMarketCenter: repo.todayRouters.isNotEmpty
            ? repo.todayRouters.first
            : MarketCenter.init(),
        errorShowMessage: '',
      ));
    } else {
      emit(state.copyWith(
        error: answer,
        isFileExist: false,
        filePath: event.fileName,
        errorShowMessage:
            'Такого файла ${event.fileName} не существует, спросите у администратора название файла и поменяйте его в настройках!',
      ));
      await Future.delayed(const Duration(seconds: 8));
      emit(state.copyWith(error: ''));
    }
  }

  /// показ ошибки
  Future<void> _onShowErrorEvent(
      ShowErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(errorShowMessage: event.error));
  }

  /// выбор торговой точки в списке торговых точек
  Future<void> _onSelectMarketCenterEvent(
      SelectMarketCenterEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(selectedMarketCenter: event.marketCenter));
  }

  /// выбор дня недели
  Future<void> _onSelectDayEvent(
      SelectDayEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(weekDay: event.day, isLoading: true));
    Get.find<RoutersRepository>().selectDay(event.day);

    // Сохраняем выбранный день как последний открытый
    await Get.find<RoutersRepository>().saveLastOpenedWeekDay(event.day);

    final todayRouters = Get.find<RoutersRepository>().todayRouters;
    Logger.i('todayRouters: ${todayRouters.length}');

    // Обновляем прогресс дня для нового маршрута
    RoutersRepository routersRepo = Get.find<RoutersRepository>();
    UserRepository userRepo = Get.find<UserRepository>();
    Map<String, dynamic> progress = routersRepo.getDayProgress();
    Map<String, dynamic> unsentSessions = userRepo.getAllUnsentSessions();

    // Рассчитываем новые значения прогресса
    int totalTT = todayRouters.length;
    int completedTT = userRepo.lastDay.listSessions.length;
    int unsentTT = unsentSessions['hasUnsent'] as bool
        ? (unsentSessions['unsentByDay'] as Map<String, List<SessionScan>>)
            .values
            .expand((list) => list)
            .length
        : 0;
    bool isTotalDay = completedTT >= totalTT;

    Logger.i(
        '_onSelectDayEvent: totalTT = $totalTT, completedTT = $completedTT, unsentTT = $unsentTT, isTotalDay = $isTotalDay');

    emit(state.copyWith(
      isLoading: false,
      todayRouters: todayRouters,
      selectedMarketCenter:
          todayRouters.isNotEmpty ? todayRouters.first : MarketCenter.init(),
      shouldShowDaySelection: false, // Скрываем выбор дня
      isFirstLogin: false, // Больше не первый вход
      dayProgress: progress,
      unsentSessions:
          unsentSessions['unsentByDay'] as Map<String, List<SessionScan>>,
      hasUnsentSessions: unsentSessions['hasUnsent'] as bool,
      totalTT: totalTT,
      completedTT: completedTT,
      unsentTT: unsentTT,
      isTotalDay: isTotalDay,
    ));
  }

  /// загрузка данных из RoutersRepository
  Future<void> _onLoadRoutersEvent(
      LoadRoutersEvent event, Emitter<MainState> emit) async {
    RoutersRepository repo = Get.find<RoutersRepository>();
    UserRepository userRepo = Get.find<UserRepository>();

    Logger.i(
        '_onLoadRoutersEvent: repo.todayRouters.length = ${repo.todayRouters.length}');
    Logger.i(
        '_onLoadRoutersEvent: userRepo.hystorySessions.length = ${userRepo.hystorySessions.length}');

    // Устанавливаем totalTT при загрузке маршрутов
    int totalTT = repo.todayRouters.length;

    // Рассчитываем completedTT из существующих сессий
    int completedTT = userRepo.hystorySessions.isNotEmpty
        ? userRepo.hystorySessions.last.listSessions.length
        : 0;

    // Рассчитываем unsentTT (сессии которые не отправились)
    int unsentTT = 0;
    if (userRepo.hystorySessions.isNotEmpty) {
      for (var session in userRepo.hystorySessions.last.listSessions) {
        if (!session.isUploaded) {
          unsentTT++;
        }
      }
    }

    // Проверяем, все ли ТТ обработаны
    bool isTotalDay = completedTT >= totalTT;

    Logger.i(
        '_onLoadRoutersEvent: totalTT = $totalTT, completedTT = $completedTT, unsentTT = $unsentTT, isTotalDay = $isTotalDay');

    emit(state.copyWith(
      marketCenters: repo.marketCenters,
      todayRouters: repo.todayRouters,
      selectedMarketCenter: repo.todayRouters.isNotEmpty
          ? repo.todayRouters.first
          : MarketCenter.init(),
      totalTT: totalTT,
      completedTT: completedTT,
      unsentTT: unsentTT,
      isTotalDay: isTotalDay,
      isFree: repo.todayRouters.isEmpty,
    ));

    // Проверяем первый вход после загрузки данных
    add(CheckFirstLoginEvent());
  }

  /// обновление списка маршрутов
  Future<void> _onUpdateWeekRoutersEvent(
      UpdateWeekRoutersEvent event, Emitter<MainState> emit) async {
    List<MarketCenter> todayRouters =
        Get.find<RoutersRepository>().getMarketCentersForDay(day: event.day);
    emit(state.copyWith(
      todayRouters: todayRouters,
    ));
  }

  /// удаление сессии
  Future<void> _onDeleteMatrixEvent(
      DeleteMatrixEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();
    repo.deleteMatrix(id: event.id);
    emit(state.copyWith(
      isLoading: false,
      dayHystorySession: repo.lastDay,
      curSession: repo.lastDay.listSessions.last,
    ));
  }

  /// отмена сканирования
  Future<void> _onUndoMatrixEvent(
      UndoMatrixEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    repo.undoMatrix();
    emit(state.copyWith(
      dayHystorySession: repo.lastDay,
      curSession: repo.lastDay.listSessions.last,
    ));
  }

  /// обновление ID сессии
  Future<void> _onUpdateSessionIdEvent(
      UpdateSessionIdEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    String answer =
        repo.updateSessionId(oldId: event.oldId, newId: event.newId);
    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 6));
      emit(state.copyWith(error: ''));
    } else {
      await Future.delayed(const Duration(milliseconds: 300));

      // Находим индекс сессии, которую обновляем
      final sessionIndex = repo.lastDay.listSessions
          .indexWhere((session) => session.id == event.newId);

      if (sessionIndex != -1) {
        // Создаем новый список сессий с обновленной сессией
        final updatedSessions =
            List<SessionScan>.from(repo.lastDay.listSessions);

        emit(state.copyWith(
          dayHystorySession: HystorySessions(
            listSessions: updatedSessions,
            time: repo.lastDay.time,
            state: repo.lastDay.state,
          ),
          curSession: updatedSessions[sessionIndex],
        ));
      }
    }
  }

  /// выход из приложения
  Future<void> _onExitUserEvent(
      ExitUserEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    await repo.clearUser();
    emit(state.copyWith(
        dayHystorySession: repo.lastDay, curSession: SessionScan.init()));
  }

  /// начало сессии
  Future<void> _onBeginSessinonEvent(
      BeginSessinonEvent event, Emitter<MainState> emit) async {
    Logger.i(
        '_onBeginSessinonEvent: id=${event.id}, sessionId=${event.sessionId}');
    UserRepository repoUser = Get.find<UserRepository>();
    RoutersRepository repoRouters = Get.find<RoutersRepository>();
    String answer = repoUser.addHystorySessions(
        id: event.id, sessionId: event.sessionId, position: event.position);
    if (answer.isNotEmpty) {
      // Показываем ошибку FTP только в режиме маршрутов, не в свободном режиме
      if (!state.isFree) {
        emit(state.copyWith(error: answer));
        await Future.delayed(const Duration(seconds: 6));
        emit(state.copyWith(error: ''));
      }
    } else {
      // Убираем выбранную ТЦ из списка
      repoRouters.removeMarketCenter(state.selectedMarketCenter);

      emit(state.copyWith(
        todayRouters: repoRouters.todayRouters,
        curSession: repoUser.lastDay.listSessions.last,
        shouldShowDaySelection: false, // Скрываем выбор дня после начала сессии
      ));
    }
  }

  /// добавление dataMatrix
  Future<void> _onAddMatrixEvent(
      AddMatrixEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    String answer = repo.addMatrix(id: event.id);
    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 5));
      emit(state.copyWith(error: ''));
    } else {
      emit(state.copyWith(
          dayHystorySession: repo.lastDay,
          curSession: repo.lastDay.listSessions.last));
    }
  }

  /// закрытие дня
  Future<void> _onClosedayEvent(
      ClosedayEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();

    Logger.i('_onClosedayEvent: начинаем закрытие дня');
    emit(state.copyWith(isLoading: true));
    String answer = await repo.closeDay();
    Logger.i('_onClosedayEvent: repo.closeDay() вернул: "$answer"');
    emit(state.copyWith(isLoading: false));

    if (answer.isNotEmpty) {
      Logger.e('_onClosedayEvent: ошибка при закрытии дня: $answer');
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 5));
      emit(state.copyWith(error: ''));
    } else {
      // ПОЛНЫЙ РЕСТАРТ после закрытия дня - как при первом заходе
      Logger.i('_onClosedayEvent: ПОЛНЫЙ РЕСТАРТ - очищаем все');

      // Создаем новый день
      repo.hystorySessions.add(HystorySessions.init());

      // ВАЖНО: Сохраняем изменения в локальное хранилище
      await repo.saveHystorySessionsToLocal();
      Logger.i('_onClosedayEvent: Сохранено в локальное хранилище');

      // Загружаем роутеры для нового дня
      RoutersRepository routersRepo = Get.find<RoutersRepository>();
      List<MarketCenter> todayRouters = routersRepo.todayRouters;
      Map<String, dynamic> progress = routersRepo.getDayProgress();
      Map<String, dynamic> unsentSessions = repo.getAllUnsentSessions();

      // Полностью очищаем состояние - как при первом заходе
      emit(state.copyWith(
        dayHystorySession: repo.lastDay,
        curSession: SessionScan.init(),
        todayRouters: todayRouters,
        dayProgress: progress,
        unsentSessions:
            unsentSessions['unsentByDay'] as Map<String, List<SessionScan>>,
        hasUnsentSessions: unsentSessions['hasUnsent'] as bool,
        shouldShowDaySelection: true, // Показываем выбор дня
        totalTT: todayRouters.length,
        completedTT: 0,
        unsentTT: 0,
        isTotalDay: false,
        error: '',
        isLoading: false,
      ));
    }
  }

  /// закрытие сессии
  Future<void> _onCloseSessionEvent(
      CloseSessionEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    RoutersRepository routersRepo = Get.find<RoutersRepository>();

    // В свободном режиме сессия должна быть добавлена при начале, не при закрытии

    // Удаляем обработанную торговую точку из списка (только в обычном режиме)
    if (state.selectedMarketCenter.id.isNotEmpty && !state.isFree) {
      routersRepo.removeMarketCenter(state.selectedMarketCenter);
    }

    // Увеличиваем счетчики
    int newCompletedTT = state.completedTT + 1;

    // Проверяем, отправилась ли последняя сессия
    bool isLastSessionUploaded = false;
    if (repo.lastDay.listSessions.isNotEmpty) {
      isLastSessionUploaded = repo.lastDay.listSessions.last.isUploaded;
    }
    int newUnsentTT = state.unsentTT + (isLastSessionUploaded ? 0 : 1);

    // Проверяем, все ли ТТ обработаны
    bool isTotalDay = newCompletedTT >= state.totalTT;

    Logger.i(
        '_onCloseSessionEvent: completedTT = $newCompletedTT, unsentTT = $newUnsentTT, isTotalDay = $isTotalDay');
    Logger.i(
        '_onCloseSessionEvent: repo.lastDay.listSessions.length = ${repo.lastDay.listSessions.length}');
    Logger.i(
        '_onCloseSessionEvent: state.dayHystorySession.listSessions.length = ${state.dayHystorySession.listSessions.length}');

    emit(state.copyWith(
      dayHystorySession: repo.lastDay,
      curSession: repo.lastDay.listSessions.isNotEmpty
          ? repo.lastDay.listSessions.last
          : state.curSession,
      todayRouters: routersRepo.todayRouters,
      completedTT: newCompletedTT,
      unsentTT: newUnsentTT,
      isTotalDay: isTotalDay,
      shouldShowDaySelection: false, // Скрываем выбор дня после первой ТТ
      // Если все ТТ завершены, показываем сообщение о завершении (только в режиме роутеров)
      error:
          (isTotalDay && !state.isFree) ? 'Все торговые точки обработаны!' : '',
    ));
  }

  /// принудительная отправка всех сессий
  Future<void> _onForceUploadAllSessionsEvent(
      ForceUploadAllSessionsEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();

    String answer = await repo.forceUploadAllSessions();
    emit(state.copyWith(isLoading: false));

    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 5));
      emit(state.copyWith(error: ''));
    } else {
      // После успешной отправки обновляем состояние
      Map<String, dynamic> unsentSessions = repo.getAllUnsentSessions();
      RoutersRepository routersRepo = Get.find<RoutersRepository>();
      Map<String, dynamic> progress = routersRepo.getDayProgress();

      // Обновляем новые поля прогресса
      int totalTT = routersRepo.todayRouters.length;
      int completedTT = repo.lastDay.listSessions.length;
      int unsentTT = 0; // После успешной отправки неотправленных нет
      bool isTotalDay = completedTT == totalTT;
      bool hasUnsentSessions =
          false; // После успешной отправки неотправленных нет

      Logger.i(
          '_onForceUploadAllSessionsEvent: после отправки hasUnsentSessions = $hasUnsentSessions, unsentTT = $unsentTT');

      emit(state.copyWith(
        dayHystorySession: repo.lastDay,
        curSession: repo.lastDay.listSessions.isNotEmpty
            ? repo.lastDay.listSessions.last
            : SessionScan.init(),
        unsentSessions:
            unsentSessions['unsentByDay'] as Map<String, List<SessionScan>>,
        hasUnsentSessions:
            hasUnsentSessions, // Принудительно устанавливаем false
        dayProgress: progress,
        // Обновляем новые поля прогресса
        totalTT: totalTT,
        completedTT: completedTT,
        unsentTT: unsentTT,
        isTotalDay: isTotalDay,
      ));
    }
  }

  /// загрузка неотправленных сессий
  Future<void> _onLoadUnsentSessionsEvent(
      LoadUnsentSessionsEvent event, Emitter<MainState> emit) async {
    UserRepository repo = Get.find<UserRepository>();
    Map<String, dynamic> unsentData = repo.getAllUnsentSessions();

    emit(state.copyWith(
      unsentSessions:
          unsentData['unsentByDay'] as Map<String, List<SessionScan>>,
      hasUnsentSessions: unsentData['hasUnsent'] as bool,
    ));
  }

  /// отправка сессий для конкретного дня
  Future<void> _onUploadSessionsForDayEvent(
      UploadSessionsForDayEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();

    String answer = await repo.uploadSessionsForDay(event.dayKey);
    emit(state.copyWith(isLoading: false));

    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 5));
      emit(state.copyWith(error: ''));
    } else {
      // Обновляем список неотправленных сессий
      Map<String, dynamic> unsentData = repo.getAllUnsentSessions();
      emit(state.copyWith(
        unsentSessions:
            unsentData['unsentByDay'] as Map<String, List<SessionScan>>,
        hasUnsentSessions: unsentData['hasUnsent'] as bool,
      ));
    }
  }

  /// восстановление незавершенного дня
  Future<void> _onRestoreUnfinishedDayEvent(
      RestoreUnfinishedDayEvent event, Emitter<MainState> emit) async {
    RoutersRepository repo = Get.find<RoutersRepository>();
    await repo.restoreUnfinishedDay();

    emit(state.copyWith(
      todayRouters: repo.todayRouters,
      selectedMarketCenter: repo.todayRouters.isNotEmpty
          ? repo.todayRouters.first
          : MarketCenter.init(),
    ));
  }

  /// получение прогресса дня
  Future<void> _onGetDayProgressEvent(
      GetDayProgressEvent event, Emitter<MainState> emit) async {
    RoutersRepository routersRepo = Get.find<RoutersRepository>();
    UserRepository userRepo = Get.find<UserRepository>();

    Map<String, dynamic> progress = routersRepo.getDayProgress();
    Map<String, dynamic> unsentSessions = userRepo.getAllUnsentSessions();

    emit(state.copyWith(
      dayProgress: progress,
      dayHystorySession: userRepo.lastDay,
      unsentSessions:
          unsentSessions['unsentByDay'] as Map<String, List<SessionScan>>,
      hasUnsentSessions: unsentSessions['hasUnsent'] as bool,
    ));
  }

  /// начало нового дня
  Future<void> _onStartNewDayEvent(
      StartNewDayEvent event, Emitter<MainState> emit) async {
    UserRepository userRepo = Get.find<UserRepository>();
    RoutersRepository routersRepo = Get.find<RoutersRepository>();

    // Закрываем текущий день
    await userRepo.closeDay();

    // Начинаем новый день
    routersRepo.todayRouters =
        routersRepo.getMarketCentersForDay(day: routersRepo.getCurrentDay());
    await routersRepo.saveTodayRouters();

    emit(state.copyWith(
      dayHystorySession: userRepo.lastDay,
      curSession: SessionScan.init(),
      todayRouters: routersRepo.todayRouters,
      selectedMarketCenter: routersRepo.todayRouters.isNotEmpty
          ? routersRepo.todayRouters.first
          : MarketCenter.init(),
    ));
  }

  /// проверка первого входа пользователя
  Future<void> _onCheckFirstLoginEvent(
      CheckFirstLoginEvent event, Emitter<MainState> emit) async {
    final routersRepo = Get.find<RoutersRepository>();
    final userRepo = Get.find<UserRepository>();

    // Проверяем, есть ли сохраненные данные о последнем открытом дне
    final lastOpened = await routersRepo.loadLastOpenedWeekDay();

    // Проверяем, есть ли загруженные маршруты для дней недели
    final hasWeekRouters = routersRepo.weekRouters.isNotEmpty;

    // Проверяем, есть ли сессии в текущем дне
    final hasSessions = userRepo.lastDay.listSessions.isNotEmpty;

    Logger.i(
        '_onCheckFirstLoginEvent: lastOpened = $lastOpened, hasWeekRouters = $hasWeekRouters, hasSessions = $hasSessions');
    Logger.i(
        '_onCheckFirstLoginEvent: userRepo.lastDay.state = ${userRepo.lastDay.state}');
    Logger.i(
        '_onCheckFirstLoginEvent: userRepo.hystorySessions.length = ${userRepo.hystorySessions.length}');
    Logger.i(
        '_onCheckFirstLoginEvent: state.shouldShowDaySelection = ${state.shouldShowDaySelection}');

    if (lastOpened == null && hasWeekRouters) {
      // Это первый заход И есть данные о днях недели - показываем выбор дня
      Logger.i('Первый заход с данными о днях недели, показываем выбор дня');
      emit(state.copyWith(
        isFirstLogin: true,
        shouldShowDaySelection: true,
      ));
    } else if (!hasWeekRouters) {
      // ТЕСТ: Временно не блокируем работу для тестирования свободного режима
      Logger.w(
          'ТЕСТ: Нет данных о днях недели - будет включен свободный режим');
      emit(state.copyWith(
        isFirstLogin: false,
        shouldShowDaySelection: false,
        // error: 'Нет данных о маршрутах. Обратитесь к администратору.',
      ));
    } else if (lastOpened != null && !hasSessions) {
      // День выбран, но сессий нет - показываем выбор дня снова
      Logger.i(
          'День выбран ($lastOpened), но сессий нет - показываем выбор дня');
      emit(state.copyWith(
        isFirstLogin: false,
        shouldShowDaySelection: true,
      ));
    } else {
      // Пользователь уже работал ранее и есть сессии
      Logger.i(
          'Пользователь уже работал ранее, последний день: $lastOpened, сессий: ${userRepo.lastDay.listSessions.length}');
      emit(state.copyWith(
        isFirstLogin: false,
        shouldShowDaySelection: false,
      ));
    }

    Logger.i(
        '_onCheckFirstLoginEvent: ФИНАЛЬНОЕ СОСТОЯНИЕ - shouldShowDaySelection = ${state.shouldShowDaySelection}');
  }

  /// установка свободного режима
  Future<void> _onSetFreeModeEvent(
      SetFreeModeEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isFreeMode: event.isFreeMode));
  }
}
