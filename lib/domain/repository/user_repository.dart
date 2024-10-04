import 'package:geolocator/geolocator.dart';
import 'package:tdtime/data/local_data.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/user.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';

/// репо для юзера
class UserRepository extends GetxController {
  User user = User.initial();
  String get id => user.id;
  bool get isReg => user.id.isNotEmpty;
  HystorySessions get lastDay => hystorySessions.last;
  List<HystorySessions> hystorySessions = [];

  static final UserRepository _instance = UserRepository._internal();

  UserRepository._internal();

  factory UserRepository() => _instance;

  Future<bool> deleteUser() async {
    return false;
  }

  Future<bool> getUser() async {
    return false;
  }

  /// Начальная загрузка пользователя из локального хранилища
  Future init() async {
    // LocalData().clear();
    await loadUserFromLocal();
    try {
      await loadHystorySessionsFromLocal();
    } catch (e) {
      Logger.e('errror loadHystorySessionsFromLocal $e');
    }

    if (hystorySessions.isEmpty) {
      hystorySessions.add(HystorySessions.init());
    }
  }

  /// закрытие сессии
  void closeSession() {
    lastDay.listSessions.last.state = StateSession.close;
    Logger.i('${lastDay.listSessions.last.toJson()}');
    saveHystorySessionsToLocal();
    Logger.i('${hystorySessions.last.listSessions.last.toJson()}');
  }

  /// закрытие дня
  Future<String> closeDay() async {
    lastDay.state = StateSession.close;
    hystorySessions.add(HystorySessions.init());
    saveHystorySessionsToLocal();
    await Future.delayed(const Duration(seconds: 4));
    return '';
  }

  /// Добавление сессии
  String addHystorySessions({
    required String id,
    required Position position,
  }) {
    final result = lastDay.listSessions.firstWhereOrNull((e) => e.id == id);
    if (result != null) {
      return 'Эту сессию вы уже сканировали!';
    } else {
      SessionScan tempSession = SessionScan.init();
      tempSession.id = id;
      tempSession.position = position;
      tempSession.time = DateTime.now();
      lastDay.addSession(tempSession);
      lastDay.state = StateSession.open;
      hystorySessions.last.listSessions.last.state = StateSession.open;
      saveHystorySessionsToLocal();
    }
    return '';
  }

  /// Добавление DataMatrix в сессию
  String addMatrix({required String id}) {
    if (hystorySessions.last.listSessions.last.dataMatrix.contains(id)) {
      return 'Этот DataMatrix вы уже сканировали!';
    } else {
      hystorySessions.last.listSessions.last.dataMatrix.add(id);
      hystorySessions.last.state = StateSession.inwork;
      saveHystorySessionsToLocal();
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData().clear();
    user = User.initial();
    hystorySessions = [];
    saveHystorySessionsToLocal();
  }

  /// авторизация пользователя

  authUser({required User userIn}) async {
    user = userIn;
    saveUserToLocal();
  }

  Future<bool> userEdit() async {
    return false;
  }

  /// Загрузка пользователя из локального хранилища
  Future<void> loadUserFromLocal() async {
    try {
      final data = await LocalData.loadJson(key: LocalDataKey.user);
      Logger.e('loadUserFromLocal $data');
      if (data['error'] == null) {
        user = User.fromJson(data);
      } else {
        await saveUserToLocal();
      }
    } catch (e) {
      Logger.e('user error $e');
      try {
        await saveUserToLocal();
      } catch (e) {
        Logger.e('saveUserToLocal error $e');
      }
    }
  }

  /// Сохранение пользователя в локальное хранилище
  Future<void> saveUserToLocal() async {
    await LocalData.saveJson(json: user.toJson(), key: LocalDataKey.user);
  }

  /// Сохранение истории сессий в локальное хранилище
  Future<void> saveHystorySessionsToLocal() async {
    await LocalData.saveListJson(
        json: hystorySessions.map((item) => item.toJson()).toList(),
        key: LocalDataKey.hystorySessions);
  }

  /// Загрузка истории сессий из локального хранилища
  Future<void> loadHystorySessionsFromLocal() async {
    final data =
        await LocalData.loadListJson(key: LocalDataKey.hystorySessions);
    if (data.isNotEmpty && data.first['error'] == null) {
      hystorySessions =
          data.map((travel) => HystorySessions.fromJson(travel)).toList();
    } else {
      await saveHystorySessionsToLocal();
    }
  }
}
