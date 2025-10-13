part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

/// новый файл
class NewFileEvent extends MainEvent {
  final String fileName;
  final bool isFileExist;
  const NewFileEvent({required this.fileName, required this.isFileExist});
}

/// сброс ошибки
class ResetErrorEvent extends MainEvent {}

/// загрузка списка ТЦ
class LoadMarketCentersEvent extends MainEvent {
  final String fileName;
  const LoadMarketCentersEvent({required this.fileName});
}

/// показ ошибки
class ShowErrorEvent extends MainEvent {
  final String error;
  const ShowErrorEvent({required this.error});
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
  final String sessionId;
  final Position position;
  const BeginSessinonEvent({
    required this.id,
    required this.sessionId,
    required this.position,
  });

  @override
  List<Object> get props => [id, sessionId, position];
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

/// принудительная отправка всех сессий
class ForceUploadAllSessionsEvent extends MainEvent {}

/// загрузка неотправленных сессий
class LoadUnsentSessionsEvent extends MainEvent {}

/// отправка сессий для конкретного дня
class UploadSessionsForDayEvent extends MainEvent {
  final String dayKey;
  const UploadSessionsForDayEvent({required this.dayKey});
}

/// восстановление незавершенного дня
class RestoreUnfinishedDayEvent extends MainEvent {}

/// получение прогресса дня
class GetDayProgressEvent extends MainEvent {}

/// начало нового дня
class StartNewDayEvent extends MainEvent {}

/// проверка первого входа пользователя
class CheckFirstLoginEvent extends MainEvent {}

/// установка свободного режима
class SetFreeModeEvent extends MainEvent {
  final bool isFreeMode;
  const SetFreeModeEvent({required this.isFreeMode});
}
