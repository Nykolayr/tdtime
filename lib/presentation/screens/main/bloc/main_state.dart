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
  final String filePath;
  final bool isFileExist;
  final String errorShowMessage;
  final Map<String, List<SessionScan>> unsentSessions;
  final bool hasUnsentSessions;
  final Map<String, dynamic> dayProgress;
  final bool shouldShowDaySelection;
  final bool isFirstLogin;
  final bool isFreeMode;
  final bool isFree; // Свободный режим на основе загруженных роутеров

  // Новые поля для простого подсчета
  final int totalTT; // Общее количество ТТ на день
  final int completedTT; // Обработанные ТТ
  final int unsentTT; // Неотправленные ТТ
  final bool isTotalDay; // Все ТТ обработаны

  const MainState({
    required this.isLoading,
    required this.error,
    required this.curSession,
    required this.dayHystorySession,
    required this.marketCenters,
    required this.todayRouters,
    required this.weekDay,
    required this.selectedMarketCenter,
    required this.filePath,
    required this.isFileExist,
    required this.errorShowMessage,
    required this.unsentSessions,
    required this.hasUnsentSessions,
    required this.dayProgress,
    required this.shouldShowDaySelection,
    required this.isFirstLogin,
    required this.isFreeMode,
    required this.isFree,
    required this.totalTT,
    required this.completedTT,
    required this.unsentTT,
    required this.isTotalDay,
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
    String? filePath,
    bool? isFileExist,
    String? errorShowMessage,
    Map<String, List<SessionScan>>? unsentSessions,
    bool? hasUnsentSessions,
    Map<String, dynamic>? dayProgress,
    bool? shouldShowDaySelection,
    bool? isFirstLogin,
    bool? isFreeMode,
    bool? isFree,
    int? totalTT,
    int? completedTT,
    int? unsentTT,
    bool? isTotalDay,
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
      filePath: filePath ?? this.filePath,
      isFileExist: isFileExist ?? this.isFileExist,
      errorShowMessage: errorShowMessage ?? this.errorShowMessage,
      unsentSessions: unsentSessions ?? this.unsentSessions,
      hasUnsentSessions: hasUnsentSessions ?? this.hasUnsentSessions,
      dayProgress: dayProgress ?? this.dayProgress,
      shouldShowDaySelection:
          shouldShowDaySelection ?? this.shouldShowDaySelection,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      isFreeMode: isFreeMode ?? this.isFreeMode,
      isFree: isFree ?? this.isFree,
      totalTT: totalTT ?? this.totalTT,
      completedTT: completedTT ?? this.completedTT,
      unsentTT: unsentTT ?? this.unsentTT,
      isTotalDay: isTotalDay ?? this.isTotalDay,
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
        selectedMarketCenter:
            Get.find<RoutersRepository>().todayRouters.isNotEmpty
                ? Get.find<RoutersRepository>().todayRouters.first
                : MarketCenter.init(),
        filePath: Get.find<UserRepository>().user.filePath,
        isFileExist: false,
        errorShowMessage: Get.find<RoutersRepository>().errorMessage,
        unsentSessions: const {},
        hasUnsentSessions: false,
        dayProgress: const {},
        shouldShowDaySelection: false,
        isFirstLogin: false,
        isFreeMode: false,
        isFree: Get.find<RoutersRepository>().todayRouters.isEmpty,
        totalTT: Get.find<RoutersRepository>().todayRouters.length,
        completedTT: Get.find<UserRepository>().hystorySessions.isNotEmpty
            ? Get.find<UserRepository>()
                .hystorySessions
                .last
                .listSessions
                .length
            : 0,
        unsentTT: 0, // Будет рассчитано в _onLoadRoutersEvent
        isTotalDay: false, // Будет рассчитано в _onLoadRoutersEvent
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        curSession,
        dayHystorySession,
        marketCenters,
        todayRouters,
        errorShowMessage,
        filePath,
        isFileExist,
        unsentSessions,
        hasUnsentSessions,
        dayProgress,
        shouldShowDaySelection,
        isFirstLogin,
        isFreeMode,
        isFree,
        totalTT,
        completedTT,
        unsentTT,
        isTotalDay,
      ];
}
