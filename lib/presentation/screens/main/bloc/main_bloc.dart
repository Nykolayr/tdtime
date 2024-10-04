import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/repository/user_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<BeginSessinonEvent>(_onBeginSessinonEvent);
    on<AddMatrixEvent>(_onAddMatrixEvent);
    on<ClosedayEvent>(_onClosedayEvent);
    on<CloseSessionEvent>(_onCloseSessionEvent);
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
      emit(state.copyWith(
          dayHystorySession: repo.lastDay,
          curSession: repo.lastDay.listSessions.last));
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
    UserRepository repo = Get.find<UserRepository>();
    repo.closeSession();
    emit(state.copyWith(
        dayHystorySession: repo.lastDay,
        curSession: repo.lastDay.listSessions.last));
  }
}
