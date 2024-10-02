part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// авторизация по логину и паролю
class AuthUserEvent extends AuthEvent {
  final String family;
  final String name;
  final String patron;
  final String id;
  const AuthUserEvent({
    required this.family,
    required this.name,
    required this.patron,
    required this.id,
  });
}
