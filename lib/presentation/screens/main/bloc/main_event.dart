part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

/// выбор торговой точки
class SelectMarketCenterEvent extends MainEvent {
  final MarketCenter marketCenter;
  const SelectMarketCenterEvent({required this.marketCenter});
}

/// загрузка данных из RoutersRepository
class LoadRoutersEvent extends MainEvent {}

/// обновление списка маршрутов по дню недели
class UpdateWeekRoutersEvent extends MainEvent {
  final WeekDay day;
  const UpdateWeekRoutersEvent({required this.day});
}

/// выбор дня недели
class SelectDayEvent extends MainEvent {
  final WeekDay day;
  const SelectDayEvent({required this.day});
}

/// начало сессии
class BeginSessinonEvent extends MainEvent {
  final String id;
  final Position position;
  const BeginSessinonEvent({
    required this.id,
    required this.position,
  });
}

/// добавление dataMatrix
class AddMatrixEvent extends MainEvent {
  final String id;
  const AddMatrixEvent({required this.id});
}

/// закрытие дня
class ClosedayEvent extends MainEvent {}

/// закрытие сессии
class CloseSessionEvent extends MainEvent {}

/// выход пользователя
class ExitUserEvent extends MainEvent {}

/// обновление ID сессии
class UpdateSessionIdEvent extends MainEvent {
  final String oldId;
  final String newId;
  const UpdateSessionIdEvent({
    required this.oldId,
    required this.newId,
  });
}

/// удаление сессии
class DeleteMatrixEvent extends MainEvent {
  final String id;
  const DeleteMatrixEvent({required this.id});
}

/// отмена сканирования
class UndoMatrixEvent extends MainEvent {}
