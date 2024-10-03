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
  List<HystorySessions> hystorySessions = [];
  SessionScan curSession = SessionScan.init();
  HystorySessions curHystorySession = HystorySessions.init();

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
    await loadHystorySessionsFromLocal();
  }

  /// Добавление сессии в историю
  String addHystorySessions({
    required String id,
    required Position position,
  }) {
    final result =
        curHystorySession.listSessions.firstWhereOrNull((e) => e.id == id);
    if (result != null) {
      return 'Эту сессию вы уже сканировали!';
    } else {
      SessionScan curSession = SessionScan.init();
      curSession.id = id;
      curSession.position = position;
      curSession.time = DateTime.now();

      curHystorySession = HystorySessions.init();
      curHystorySession.addSession(curSession);
      curHystorySession.state = StateSession.open;
      hystorySessions.add(curHystorySession);
      saveHystorySessionsToLocal();
    }
    return '';
  }

  /// Добавление DataMatrix в сессию
  String addMatrix({required String id}) {
    if (hystorySessions.last.listSessions.last.dataMatrix.contains(id)) {
      return 'Этот  DataMatrix вы уже сканировали!';
    } else {
      hystorySessions.last.listSessions.last.dataMatrix.add(id);
      saveHystorySessionsToLocal();
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData().clear();
    user = User.initial();
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
