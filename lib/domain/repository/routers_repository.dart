import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/week_routers.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/data/local_data.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class RoutersRepository {
  static final RoutersRepository _instance = RoutersRepository._internal();
  factory RoutersRepository() => _instance;
  RoutersRepository._internal();

  // Хранилище всех торговых центров
  List<MarketCenter> marketCenters = [];

  // Хранилище маршрутов по дням недели
  List<WeekRouters> weekRouters = [];

  // Хранилище точек на сегодня
  List<MarketCenter> todayRouters = [];

  // Выбранный день недели (для расчета прогресса)
  WeekDay? selectedDay;

  // Флаг, указывающий на наличие файла с маршрутами
  bool isFileExist = false;

  // Сообщение об ошибке
  String errorMessage = '';

  // Флаг наличия роутеров
  bool isRouters = false;

  // Инициализация данных
  Future<bool> init() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) {
      return false;
    }

    // Очищаем предыдущие данные при новой инициализации
    marketCenters.clear();
    weekRouters.clear();
    todayRouters.clear();
    errorMessage = '';
    isRouters = false;

    // Сначала пытаемся загрузить с FTP (приоритет)
    bool ftpSuccess = false;
    try {
      Logger.i('init: Пытаемся загрузить данные с FTP...');
      await _loadFromFtp();
      if (marketCenters.isNotEmpty) {
        Logger.i('init: Данные успешно загружены с FTP');
        ftpSuccess = true;
      } else {
        Logger.w('init: FTP загрузка не дала результатов');
      }
    } catch (e) {
      Logger.e('init: Failed to load from FTP: $e');
      Logger.w(
          'init: FTP недоступен, пытаемся загрузить с локального хранилища');
    }

    // Если FTP не удался, загружаем из локального хранилища
    if (!ftpSuccess) {
      try {
        Logger.i('init: Загружаем данные из локального хранилища...');
        await _loadFromLocal();
        if (marketCenters.isNotEmpty) {
          Logger.i('init: Данные загружены из локального хранилища');
        } else {
          Logger.w('init: Локальных данных нет или они неполные');
        }
      } catch (e) {
        Logger.e('init: Failed to load from local: $e');
      }
    }

    final today = getCurrentDay();
    final lastOpened = await loadLastOpenedWeekDay();

    if (lastOpened == null || lastOpened != today) {
      // Новый день — обновляем todayRouters из weekRouters
      todayRouters = getMarketCentersForDay(day: today);
      await _saveTodayRouters();
      // НЕ сохраняем lastOpenedWeekDay здесь, чтобы не мешать проверке первого входа
      if (lastOpened != null) {
        await saveLastOpenedWeekDay(today);
      }
    } else {
      // День тот же — todayRouters из локалки
      final saved =
          await LocalData.loadListJson(key: LocalDataKey.todayRouters);
      if (saved.isNotEmpty && saved.first['error'] == null) {
        todayRouters = saved.map((mc) => MarketCenter.fromJson(mc)).toList();
      } else {
        todayRouters = getMarketCentersForDay(day: today);
      }
    }

    // Устанавливаем флаг наличия роутеров на основе todayRouters
    isRouters = todayRouters.isNotEmpty;

    // Восстанавливаем незавершенный день, если есть
    await restoreUnfinishedDay();

    // Если нет данных вообще, активируем свободный режим
    if (marketCenters.isEmpty) {
      Logger.i('init: Нет данных, активируем свободный режим');
      marketCenters = []; // Пустой список для свободного режима
      todayRouters = []; // Пустой список для свободного режима
      isRouters = false; // Нет роутеров - свободный режим
    }

    // Возвращаем true всегда - либо с данными, либо в свободном режиме
    return true;
  }

  /// убираем выбранный ТЦ из списка точек на сегодня
  void removeMarketCenter(MarketCenter marketCenter) {
    todayRouters.remove(marketCenter);
    _saveTodayRouters();
  }

  /// Выбор дня
  Future<void> selectDay(WeekDay day) async {
    // Сохраняем выбранный день
    selectedDay = day;

    todayRouters = getMarketCentersForDay(day: day);
    await _saveTodayRouters();
  }

  /// Восстановление маршрута для незавершенного дня
  Future<void> restoreUnfinishedDay() async {
    final user = Get.find<UserRepository>();

    // Получаем все закрытые сессии за сегодня
    List<SessionScan> closedSessions = user.lastDay.listSessions
        .where((session) => session.state == StateSession.close)
        .toList();

    if (closedSessions.isNotEmpty) {
      // Удаляем из todayRouters те торговые точки, которые уже обработаны
      List<String> processedIds =
          closedSessions.map((s) => s.id).where((id) => id.isNotEmpty).toList();

      // Восстанавливаем оригинальный список для сегодняшнего дня
      todayRouters = getMarketCentersForDay(day: getCurrentDay());

      // Удаляем уже обработанные торговые точки
      todayRouters.removeWhere((mc) => processedIds.contains(mc.id));

      await _saveTodayRouters();
    }
  }

  /// Проверка, завершен ли рабочий день
  bool isDayCompleted() {
    return todayRouters.isEmpty;
  }

  /// Получение прогресса дня
  Map<String, dynamic> getDayProgress() {
    final user = Get.find<UserRepository>();

    // Получаем день для расчета прогресса
    WeekDay dayForProgress = selectedDay ?? getCurrentDay();

    // Считаем количество обработанных ТТ для текущего дня
    // (история не разделена по дням недели, только по датам)
    Set<String> processedTTs =
        user.lastDay.listSessions.map((session) => session.id).toSet();
    int completed = processedTTs.length;

    // СВОБОДНЫЙ РЕЖИМ - просто количество обработанных точек
    if (!isRouters) {
      return {
        'total': 0, // Не показываем "из X"
        'completed': completed,
        'remaining': 0,
        'isCompleted': false,
        'progress': 0.0, // Нет прогресс-бара
      };
    }

    // В режиме роутеров считаем правильно
    // Получаем полный список торговых точек для выбранного дня (фиксированное количество)
    List<MarketCenter> fullDayRouters =
        getMarketCentersForDay(day: dayForProgress);
    int total =
        fullDayRouters.length; // Общее количество ТТ на день (не меняется)
    int remaining = total - completed; // Осталось = общее - обработанные

    return {
      'total': total,
      'completed': completed,
      'remaining': remaining,
      'isCompleted': remaining == 0,
      'progress': total > 0 ? (completed / total) : 0.0,
    };
  }

  // загрузка точек на сегодня
  Future<void> loadTodayRouters() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    try {
      // Загружаем список ТЦ
      final ttData =
          await LocalData.loadListJson(key: LocalDataKey.todayRouters);
      if (ttData.isNotEmpty && ttData.first['error'] == null) {
        todayRouters = ttData.map((mc) => MarketCenter.fromJson(mc)).toList();
      } else {
        await _saveTodayRouters();
      }
    } catch (e) {
      await _saveTodayRouters();
    }
  }

  // сохранение точек на сегодня
  Future<void> _saveTodayRouters() async {
    await LocalData.saveListJson(
      json: todayRouters.map((mc) => mc.toJson()).toList(),
      key: LocalDataKey.todayRouters,
    );
  }

  // Публичный метод для сохранения точек на сегодня
  Future<void> saveTodayRouters() async {
    await _saveTodayRouters();
  }

  // Загрузка данных из FTP
  Future<void> _loadFromFtp() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    Logger.i(
        '_loadFromFtp: Начинаем загрузку с FTP для пользователя: ${user.id}');
    Logger.i('_loadFromFtp: filePath: ${user.filePath}');

    try {
      // Загружаем список ТЦ
      Logger.i('_loadFromFtp: Загружаем all_tt.json...');
      final ttData = await Api().downloadJsonFile('all_tt.json');
      if (ttData['error'] == null) {
        marketCenters = (ttData['marketCenters'] as List)
            .map((mc) => MarketCenter.fromJson(mc))
            .toList();
        Logger.i('_loadFromFtp: Загружено ТЦ: ${marketCenters.length}');
        errorMessage = ''; // Очищаем ошибку при успешной загрузке
      } else {
        Logger.e(
            '_loadFromFtp: Ошибка загрузки all_tt.json: ${ttData['error']}');
        errorMessage = ttData['error'];
        return;
      }
      // Загружаем маршруты
      Logger.i('_loadFromFtp: Загружаем ${user.filePath}...');
      final routersData = await Api().downloadJsonFile(user.filePath);
      if (routersData['error'] == null) {
        Logger.i('_loadFromFtp: FTP: Загруженные данные: $routersData');
        Logger.i(
            '_loadFromFtp: FTP: routers.length = ${(routersData['routers'] as List).length}');

        // Обрабатываем маршруты из FTP
        weekRouters = (routersData['routers'] as List)
            .map((router) => WeekRouters.fromJson(router))
            .toList();
      } else {
        Logger.e(
            '_loadFromFtp: Ошибка загрузки ${user.filePath}: ${routersData['error']}');
        isFileExist = false;
        errorMessage = routersData['error'];
        return;
      }

      // Если данные успешно загружены, сохраняем их локально
      if (marketCenters.isNotEmpty) {
        errorMessage = ''; // Очищаем ошибку при успешной загрузке
        await _saveToLocal();
        Logger.i('_loadFromFtp: Данные сохранены локально');
      } else {
        Logger.e('_loadFromFtp: marketCenters пустой, выбрасываем ошибку');
        throw 'Failed to load data from FTP';
      }
    } catch (e) {
      Logger.e('_loadFromFtp: Exception: $e');
      // Не устанавливаем errorMessage при отсутствии интернета - работаем с локальными данными
      if (!e.toString().contains('SocketException') &&
          !e.toString().contains('No Internet')) {
        errorMessage = e.toString();
        Logger.e('_loadFromFtp: Устанавливаем errorMessage: $errorMessage');
      } else {
        Logger.w('_loadFromFtp: Нет интернета, работаем с локальными данными');
      }
      return;
    }
  }

  Future<String> loadFromFtpTT(String fileName) async {
    final routersData = await Api().downloadJsonFile(fileName);

    if (routersData['error'] == null) {
      weekRouters = (routersData['routers'] as List).map((r) {
        final ids =
            (r['marketCenterIds'] as List).map((id) => id.toString()).toList();
        final centers = ids
            .map((id) => marketCenters.firstWhere((mc) => mc.id == id,
                orElse: () => MarketCenter.init()))
            .toList();
        return WeekRouters(
          day: WeekDay.values.firstWhere((e) => e.name == r['day']),
          marketCenterIds: ids,
          marketCenters: centers,
        );
      }).toList();
      todayRouters = getMarketCentersForDay(day: getCurrentDay());
      Get.find<UserRepository>().user.filePath = fileName;
      Get.find<UserRepository>().saveUserToLocal();
      await _saveToLocal();
      isFileExist = true;
      errorMessage = '';
      return '';
    } else {
      isFileExist = false;
      return routersData['error'];
    }
  }

  // Загрузка данных из локальных файлов
  Future<void> _loadFromLocal() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    Logger.i('_loadFromLocal: Начинаем загрузку из локального хранилища');

    try {
      // Загружаем список ТЦ
      Logger.i('_loadFromLocal: Загружаем список ТЦ...');
      final ttData = await LocalData.loadJson(key: LocalDataKey.marketCenters);
      if (ttData['error'] == null) {
        marketCenters = (ttData['marketCenters'] as List)
            .map((mc) => MarketCenter.fromJson(mc))
            .toList();
        Logger.i('_loadFromLocal: Загружено ТЦ: ${marketCenters.length}');
      } else {
        Logger.w('_loadFromLocal: Ошибка загрузки ТЦ: ${ttData['error']}');
      }

      // Загружаем маршруты
      Logger.i('_loadFromLocal: Загружаем маршруты...');
      final routersData =
          await LocalData.loadListJson(key: LocalDataKey.routers);
      if (routersData.isNotEmpty && routersData.first['error'] == null) {
        weekRouters = routersData.map((r) {
          return WeekRouters(
            day: WeekDay.values.firstWhere(
              (day) => day.name == r['day'],
            ),
            marketCenterIds: (r['marketCenterIds'] as List)
                .map((id) => id.toString())
                .toList(),
            marketCenters: (r['marketCenters'] as List)
                .map((mc) => MarketCenter.fromJson(mc))
                .toList(),
          );
        }).toList();
        Logger.i('_loadFromLocal: Загружено маршрутов: ${weekRouters.length}');
      } else {
        Logger.w('_loadFromLocal: Ошибка загрузки маршрутов или данных нет');
      }

      // Если нет торговых центров, очищаем все данные
      if (marketCenters.isEmpty) {
        Logger.w('_loadFromLocal: Нет торговых центров, очищаем все данные');
        marketCenters.clear();
        weekRouters.clear();
        return;
      }

      // Если нет маршрутов, но есть торговые центры - это нормально для свободного режима
      if (weekRouters.isEmpty) {
        Logger.i(
            '_loadFromLocal: Нет маршрутов, но есть торговые центры - активируем свободный режим');
      }
    } catch (e) {
      Logger.e('_loadFromLocal: Exception: $e');
    }
  }

  // Сохранение данных локально
  Future<void> _saveToLocal() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    Logger.i('_saveToLocal: Начинаем сохранение данных локально');

    try {
      // Сохраняем список ТЦ
      Logger.i('_saveToLocal: Сохраняем список ТЦ...');
      final ttJson = {
        'marketCenters': marketCenters.map((mc) => mc.toJson()).toList(),
      };
      await LocalData.saveJson(json: ttJson, key: LocalDataKey.marketCenters);

      // Сохраняем маршруты
      Logger.i('_saveToLocal: Сохраняем маршруты...');
      await LocalData.saveListJson(
        json: weekRouters.map((r) => r.toJson()).toList(),
        key: LocalDataKey.routers,
      );
      Logger.i('_saveToLocal: Данные успешно сохранены локально');
    } catch (e) {
      Logger.e('_saveToLocal: Ошибка сохранения: $e');
    }
  }

  // Получение всех торговых центров
  List<MarketCenter> getAllMarketCenters() {
    return marketCenters;
  }

  // Получение торгового центра по ID
  MarketCenter? getMarketCenterById(String id) {
    try {
      return marketCenters.firstWhere((mc) => mc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение всех маршрутов
  List<WeekRouters> getAllRouters() {
    return weekRouters;
  }

  // Получение маршрута по дню недели
  WeekRouters? getRoutersByDay(WeekDay day) {
    try {
      return weekRouters.firstWhere((route) => route.day == day);
    } catch (e) {
      return null;
    }
  }

  // Получение маршрута для текущего дня
  WeekRouters? getCurrentDayRouters() {
    final now = DateTime.now();
    final currentDay = WeekDay.values[now.weekday - 1];
    return getRoutersByDay(currentDay);
  }

  // Получение списка торговых центров для конкретного дня
  List<MarketCenter> getMarketCentersForDay({WeekDay? day}) {
    day ??= getCurrentDay();
    final route = getRoutersByDay(day);
    if (route == null) return [];

    return route.marketCenterIds.map((id) {
      return getMarketCenterById(id) ?? MarketCenter.init();
    }).toList();
  }

  /// получение текущего дня недели
  WeekDay getCurrentDay() {
    final now = DateTime.now();
    final currentDay = WeekDay.values[now.weekday - 1];
    return currentDay;
  }

  // --- Методы для lastOpenedWeekDay ---
  Future<void> saveLastOpenedWeekDay(WeekDay day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastOpenedWeekDay', day.index);
  }

  Future<WeekDay?> loadLastOpenedWeekDay() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('lastOpenedWeekDay');
    if (idx != null && idx >= 0 && idx < WeekDay.values.length) {
      return WeekDay.values[idx];
    }
    return null;
  }
}
