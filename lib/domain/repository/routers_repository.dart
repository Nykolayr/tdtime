import 'package:get/get.dart';

import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/data/mock/routers_mock.dart';
import 'package:tdtime/data/mock/tt_mock.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/domain/models/week_routers.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tdtime/data/local_data.dart';

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

    Logger.i('Starting data initialization for user ${user.id}');
    try {
      // Пытаемся загрузить данные из FTP
      Logger.i('Attempting to load data from FTP...');
      await _loadFromFtp();
      Logger.i('Successfully loaded data from FTP');
    } catch (e) {
      Logger.e('Failed to load from FTP: $e');
      // Если не получилось, пробуем из локальных файлов
      try {
        Logger.i('Attempting to load data from local storage...');
        await _loadFromLocal();
        Logger.i('Successfully loaded data from local storage');
      } catch (e) {
        Logger.e('Failed to load from local: $e');
        // Если и локальных нет, берем из моковых
        Logger.i('Loading mock data...');
        await _loadFromMock();
        Logger.i('Successfully loaded and saved mock data');
      }
    }
    Logger.i(
        'Data initialization completed. Loaded ${marketCenters.length} market centers and ${weekRouters.length} routes');
  }

  // Загрузка данных из FTP
  Future<void> _loadFromFtp() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    try {
      // Загружаем список ТЦ
      final ttData = await Api().downloadJsonFile('all_tt.json');
      marketCenters = (ttData['marketCenters'] as List)
          .map((mc) => MarketCenter.fromJson(mc))
          .toList();

      // Загружаем маршруты
      final routersData =
          await Api().downloadJsonFile('${user.id}_routers.json');
      weekRouters = (routersData['routers'] as List)
          .map((r) => WeekRouters.fromJson(r))
          .toList();

      // Если данные успешно загружены, сохраняем их локально
      if (marketCenters.isNotEmpty && weekRouters.isNotEmpty) {
        await _saveToLocal();
      } else {
        throw 'Failed to load data from FTP';
      }
    } catch (e) {
      Logger.e('Failed to load from FTP: $e');
      rethrow;
    }
  }

  // Загрузка данных из локальных файлов
  Future<void> _loadFromLocal() async {
    final user = Get.find<UserRepository>().user;
    if (user.id.isEmpty) return;

    try {
      // Загружаем список ТЦ
      final ttData = await LocalData.loadJson(key: LocalDataKey.marketCenters);
      if (ttData['error'] == null) {
        marketCenters = (ttData['marketCenters'] as List)
            .map((mc) => MarketCenter.fromJson(mc))
            .toList();
      }

      // Загружаем маршруты
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
          );
        }).toList();
      }

      // Если локальных данных нет, берем из моковых и сохраняем
      if (marketCenters.isEmpty || weekRouters.isEmpty) {
        Logger.i('No local data found, loading from mock...');
        await _loadFromMock();
        return; // Прерываем выполнение, так как данные уже загружены в _loadFromMock
      }
    } catch (e) {
      Logger.e('Failed to load from local: $e');
      Logger.i('Loading from mock after local load error...');
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
        marketCenterIds: (route['marketCenterIds'] as List)
            .map((id) => id.toString())
            .toList(),
      );
    }).toList();

    // Сначала пытаемся сохранить в FTP
    try {
      await _saveToFtp();
      Logger.i('Successfully saved mock data to FTP');
    } catch (e) {
      Logger.e('Failed to save mock data to FTP: $e');
    }

    // Затем сохраняем локально
    try {
      await _saveToLocal();
      Logger.i('Successfully saved mock data locally');
    } catch (e) {
      Logger.e('Failed to save mock data locally: $e');
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

    try {
      // Сохраняем список ТЦ
      final ttJson = {
        'marketCenters': marketCenters.map((mc) => mc.toJson()).toList(),
      };
      await LocalData.saveJson(json: ttJson, key: LocalDataKey.marketCenters);

      // Сохраняем маршруты
      await LocalData.saveListJson(
        json: weekRouters.map((r) => r.toJson()).toList(),
        key: LocalDataKey.routers,
      );
    } catch (e) {
      Logger.e('Failed to save to local: $e');
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
