import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/data/mock/routers_mock.dart';
import 'package:tdtime/data/mock/tt_mock.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/domain/models/week_routers.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class RoutersRepository {
  static final RoutersRepository _instance = RoutersRepository._internal();
  factory RoutersRepository() => _instance;
  RoutersRepository._internal();

  // Хранилище всех торговых центров
  List<MarketCenter> marketCenters = [];

  // Хранилище маршрутов по дням недели
  List<WeekRouters> weekRouters = [];

  // Инициализация данных
  Future<void> init() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) {
      Logger.i('User not registered yet, skipping data loading');
      return;
    }

    try {
      // Пытаемся загрузить данные из FTP
      await _loadFromFtp();
    } catch (e) {
      Logger.e('Failed to load from FTP: $e');
      // Если не получилось, пробуем из локальных файлов
      try {
        await _loadFromLocal();
      } catch (e) {
        Logger.e('Failed to load from local: $e');
        // Если и локальных нет, берем из моковых
        await _loadFromMock();
      }
    }
  }

  // Загрузка данных из FTP
  Future<void> _loadFromFtp() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    // Загружаем список ТЦ
    final ttJson = await Api().downloadJsonFile('all_tt.json');
    if (ttJson != null) {
      marketCenters = (ttJson['marketCenters'] as List)
          .map((mc) => MarketCenter.fromJson(mc))
          .toList();
    }

    // Загружаем маршруты
    final routersJson = await Api().downloadJsonFile('${user.id}_routers.json');
    if (routersJson != null) {
      weekRouters = (routersJson['routers'] as List)
          .map((r) => WeekRouters.fromJson(r))
          .toList();
    }

    // Если данные успешно загружены, сохраняем их локально
    if (marketCenters.isNotEmpty && weekRouters.isNotEmpty) {
      await _saveToLocal();
    } else {
      throw 'Failed to load data from FTP';
    }
  }

  // Загрузка данных из локальных файлов
  Future<void> _loadFromLocal() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();

    // Загружаем список ТЦ
    final ttFile = File('${dir.path}/all_tt.json');
    if (await ttFile.exists()) {
      final ttJson = jsonDecode(await ttFile.readAsString());
      marketCenters = (ttJson['marketCenters'] as List)
          .map((mc) => MarketCenter.fromJson(mc))
          .toList();
    }

    // Загружаем маршруты
    final routersFile = File('${dir.path}/${user.id}_routers.json');
    if (await routersFile.exists()) {
      final routersJson = jsonDecode(await routersFile.readAsString());
      weekRouters = (routersJson['routers'] as List)
          .map((r) => WeekRouters.fromJson(r))
          .toList();
    }

    // Если локальных данных нет, берем из моковых и сохраняем
    if (marketCenters.isEmpty || weekRouters.isEmpty) {
      await _loadFromMock();
    }
  }

  // Загрузка данных из моковых данных
  Future<void> _loadFromMock() async {
    marketCenters = TTMock.getMockData();
    weekRouters = routersMock.map((route) {
      return WeekRouters(
        day: WeekDay.values.firstWhere(
          (day) => day.toString().split('.').last.toLowerCase() == route['day'],
        ),
        marketCenterIds: List<String>.from(route['marketCenterIds']),
      );
    }).toList();

    // Сохраняем моковые данные в FTP и локально
    try {
      await _saveToFtp();
    } catch (e) {
      Logger.e('Failed to save to FTP: $e');
    }
    try {
      await _saveToLocal();
    } catch (e) {
      Logger.e('Failed to save to local: $e');
    }
  }

  // Сохранение данных в FTP
  Future<void> _saveToFtp() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    // Сохраняем список ТЦ
    final ttJson = {
      'marketCenters': marketCenters.map((mc) => mc.toJson()).toList(),
    };
    await Api().uploadJsonFile('all_tt.json', ttJson);

    // Сохраняем маршруты
    final routersJson = {
      'routers': weekRouters.map((r) => r.toJson()).toList(),
    };
    await Api().uploadJsonFile('${user.id}_routers.json', routersJson);
  }

  // Сохранение данных локально
  Future<void> _saveToLocal() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();

    // Сохраняем список ТЦ
    final ttFile = File('${dir.path}/all_tt.json');
    final ttJson = {
      'marketCenters': marketCenters.map((mc) => mc.toJson()).toList(),
    };
    await ttFile.writeAsString(jsonEncode(ttJson));

    // Сохраняем маршруты
    final routersFile = File('${dir.path}/${user.id}_routers.json');
    final routersJson = {
      'routers': weekRouters.map((r) => r.toJson()).toList(),
    };
    await routersFile.writeAsString(jsonEncode(routersJson));
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
  List<MarketCenter> getMarketCentersForDay(WeekDay day) {
    final route = getRoutersByDay(day);
    if (route == null) return [];

    return route.marketCenterIds.map((id) {
      return getMarketCenterById(id) ?? MarketCenter.init();
    }).toList();
  }

  // Получение списка торговых центров для текущего дня
  List<MarketCenter> getMarketCentersForCurrentDay() {
    final now = DateTime.now();
    final currentDay = WeekDay.values[now.weekday - 1];
    return getMarketCentersForDay(currentDay);
  }
}
