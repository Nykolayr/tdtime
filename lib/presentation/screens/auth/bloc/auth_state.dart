part of 'auth_bloc.dart';

class AuthState {
  final bool isSucsess;
  final bool isLoading;
  final User user;
  final String error;

  const AuthState({
    required this.isLoading,
    required this.isSucsess,
    required this.user,
    required this.error,
  });

  factory AuthState.initial() => AuthState(
        isLoading: false,
        isSucsess: false,
        user: User.initial(),
        error: '',
      );
  AuthState copyWith({
    bool? isSucsess,
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSucsess: isSucsess ?? this.isSucsess,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
