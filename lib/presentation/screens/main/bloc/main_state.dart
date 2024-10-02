part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;

  const MainState({
    required this.isLoading,
    required this.error,
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory MainState.initial() => const MainState(isLoading: false, error: '');

  @override
  List<Object?> get props => [
        isLoading,
        error,
      ];
}
