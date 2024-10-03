part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final SessionScan curSession;
  final HystorySessions curHystorySession;

  const MainState({
    required this.isLoading,
    required this.error,
    required this.curSession,
    required this.curHystorySession,
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
    SessionScan? curSession,
    HystorySessions? curHystorySession,
  }) {
    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      curSession: curSession ?? this.curSession,
      curHystorySession: curHystorySession ?? this.curHystorySession,
    );
  }

  factory MainState.initial() => MainState(
        isLoading: false,
        error: '',
        curSession: (Get.find<UserRepository>().hystorySessions.isNotEmpty &&
                Get.find<UserRepository>()
                    .hystorySessions
                    .last
                    .listSessions
                    .isNotEmpty)
            ? Get.find<UserRepository>().hystorySessions.last.listSessions.last
            : SessionScan.init(),
        curHystorySession:
            (Get.find<UserRepository>().hystorySessions.isNotEmpty)
                ? Get.find<UserRepository>().hystorySessions.last
                : HystorySessions.init(),
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        curSession,
        curHystorySession,
      ];
}
