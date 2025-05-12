part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final SessionScan curSession;
  final HystorySessions dayHystorySession;
  final List<MarketCenter> marketCenters;
  final List<MarketCenter> todayRouters;
  final WeekDay weekDay;
  final MarketCenter selectedMarketCenter;

  const MainState({
    required this.isLoading,
    required this.error,
    required this.curSession,
    required this.dayHystorySession,
    required this.marketCenters,
    required this.todayRouters,
    required this.weekDay,
    required this.selectedMarketCenter,
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
    SessionScan? curSession,
    HystorySessions? dayHystorySession,
    List<MarketCenter>? marketCenters,
    List<MarketCenter>? todayRouters,
    WeekDay? weekDay,
    MarketCenter? selectedMarketCenter,
  }) {
    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      curSession: curSession ?? this.curSession,
      dayHystorySession: dayHystorySession ?? this.dayHystorySession,
      marketCenters: marketCenters ?? this.marketCenters,
      todayRouters: todayRouters ?? this.todayRouters,
      weekDay: weekDay ?? this.weekDay,
      selectedMarketCenter: selectedMarketCenter ?? this.selectedMarketCenter,
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
        dayHystorySession:
            (Get.find<UserRepository>().hystorySessions.isNotEmpty)
                ? Get.find<UserRepository>().hystorySessions.last
                : HystorySessions.init(),
        marketCenters: Get.find<RoutersRepository>().marketCenters,
        todayRouters: Get.find<RoutersRepository>().todayRouters,
        weekDay: Get.find<RoutersRepository>().getCurrentDay(),
        selectedMarketCenter: MarketCenter.init(),
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        curSession,
        dayHystorySession,
        marketCenters,
        todayRouters,
      ];
}
