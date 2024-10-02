part of 'auth_bloc.dart';

class AuthState {
  final bool isSucsess;
  final bool isLoading;
  final User user;

  const AuthState({
    required this.isLoading,
    required this.isSucsess,
    required this.user,
  });

  factory AuthState.initial() => AuthState(
        isLoading: false,
        isSucsess: false,
        user: User.initial(),
      );
  AuthState copyWith({
    bool? isSucsess,
    bool? isLoading,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSucsess: isSucsess ?? this.isSucsess,
      user: user ?? this.user,
    );
  }
}
