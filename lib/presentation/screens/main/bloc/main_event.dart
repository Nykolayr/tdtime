part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
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
