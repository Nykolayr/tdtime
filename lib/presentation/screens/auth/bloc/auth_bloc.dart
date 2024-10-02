import 'package:tdtime/domain/models/user.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<AuthUserEvent>(_onAuthEvent);
  }

  /// авторизация по логину и паролю
  Future<void> _onAuthEvent(
      AuthUserEvent event, Emitter<AuthState> emit) async {
    User user = User(
        family: event.family,
        name: event.name,
        patron: event.patron,
        id: event.id);

    Get.find<UserRepository>().authUser(userIn: user);
    emit(state.copyWith(user: user));
  }
}
