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
import 'package:tdtime/presentation/screens/main/get_position.dart';

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
  }

  /// выбор торговой точки в списке торговых точек
  Future<void> _onSelectMarketCenterEvent(
      SelectMarketCenterEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(selectedMarketCenter: event.marketCenter));
  }

  /// выбор дня недели
  Future<void> _onSelectDayEvent(
      SelectDayEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(weekDay: event.day));
    Get.find<RoutersRepository>().selectDay(event.day);

    emit(state.copyWith(
      todayRouters: Get.find<RoutersRepository>().todayRouters,
      selectedMarketCenter: Get.find<RoutersRepository>().todayRouters.first,
    ));
  }

  /// загрузка данных из RoutersRepository
  Future<void> _onLoadRoutersEvent(
      LoadRoutersEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(
      marketCenters: Get.find<RoutersRepository>().marketCenters,
      todayRouters: Get.find<RoutersRepository>().todayRouters,
    ));
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
    UserRepository repo = Get.find<UserRepository>();
    String answer =
        repo.addHystorySessions(id: event.id, position: event.position);
    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 6));
      emit(state.copyWith(error: ''));
    } else {
      Get.find<RoutersRepository>()
          .removeMarketCenter(state.selectedMarketCenter);
      emit(state.copyWith(
        dayHystorySession: repo.lastDay,
        curSession: repo.lastDay.listSessions.last,
        todayRouters: Get.find<RoutersRepository>().todayRouters,
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
    emit(state.copyWith(isLoading: true));
    String answer = await repo.closeDay();
    emit(state.copyWith(isLoading: false));
    if (answer.isNotEmpty) {
      emit(state.copyWith(error: answer));
      await Future.delayed(const Duration(seconds: 5));
      emit(state.copyWith(error: ''));
    } else {
      emit(state.copyWith(
        dayHystorySession: repo.lastDay,
        curSession: SessionScan.init(),
      ));
    }
  }

  /// закрытие сессии
  Future<void> _onCloseSessionEvent(
      CloseSessionEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();

    String answer = await repo.closeSession();
    emit(state.copyWith(isLoading: false));
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
}
