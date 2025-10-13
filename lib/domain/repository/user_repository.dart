import 'package:geolocator/geolocator.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/data/local_data.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/domain/models/user.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tdtime/domain/repository/routers_repository.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';

/// репо для юзера
class UserRepository {
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

    // Проверяем, есть ли неотправленные сессии в предыдущих днях
    await _checkForUnsentSessions();

    Logger.i('lastDay init ${lastDay.toJson()}');
  }

  /// Проверка неотправленных сессий при инициализации
  Future<void> _checkForUnsentSessions() async {
    bool hasUnsentSessions = false;

    for (var day in hystorySessions) {
      for (var session in day.listSessions) {
        if (session.state == StateSession.close && !session.isUploaded) {
          hasUnsentSessions = true;
          break;
        }
      }
      if (hasUnsentSessions) break;
    }

    if (hasUnsentSessions) {
      Logger.w('Обнаружены неотправленные сессии при инициализации');
      // Здесь можно добавить логику для показа экрана с неотправленными сессиями
    }
  }

  /// Получение всех неотправленных сессий по дням
  Map<String, dynamic> getAllUnsentSessions() {
    Map<String, List<SessionScan>> unsentByDay = {};
    int totalUnsent = 0;

    for (var day in hystorySessions) {
      List<SessionScan> unsentSessions = day.listSessions
          .where((session) =>
              session.state == StateSession.close && !session.isUploaded)
          .toList();

      if (unsentSessions.isNotEmpty) {
        String dayKey = day.getFormattedDateTime();
        unsentByDay[dayKey] = unsentSessions;
        totalUnsent += unsentSessions.length;
      }
    }

    return {
      'unsentByDay': unsentByDay,
      'totalUnsent': totalUnsent,
      'hasUnsent': totalUnsent > 0,
    };
  }

  /// Отправка всех неотправленных сессий для конкретного дня
  Future<String> uploadSessionsForDay(String dayKey) async {
    Logger.i('Отправка сессий для дня: $dayKey');

    int successCount = 0;
    int failCount = 0;
    String lastError = '';

    for (var day in hystorySessions) {
      String currentDayKey = day.getFormattedDateTime();
      if (currentDayKey == dayKey) {
        for (var session in day.listSessions) {
          if (session.state == StateSession.close && !session.isUploaded) {
            try {
              String fileName =
                  '${session.id}_${session.time.microsecondsSinceEpoch}.json';
              Map<String, dynamic> data = {};
              data['FIO'] = '${user.family} ${user.name} ${user.patron}';
              data['ID'] = user.id;
              data['TT_INFO'] = session.toMapForFtp();

              String answer =
                  await Api().uploadHystorySessionsToFtp(data, fileName);
              if (answer.isEmpty) {
                session.isUploaded = true;
                successCount++;
                Logger.i('Сессия ${session.id} успешно отправлена');
              } else {
                failCount++;
                lastError = answer;
                Logger.w('Не удалось отправить сессию ${session.id}: $answer');
              }
            } catch (e) {
              failCount++;
              lastError = e.toString();
              Logger.e('Ошибка при отправке сессии ${session.id}: $e');
            }
          }
        }
        break;
      }
    }

    // Сохраняем обновленные данные
    saveHystorySessionsToLocal();

    if (failCount == 0) {
      return '';
    } else {
      return 'Отправлено: $successCount, Ошибок: $failCount. Последняя ошибка: $lastError';
    }
  }

  /// удаление сессии
  void deleteMatrix({required String id}) {
    hystorySessions.last.listSessions.removeWhere((e) => e.id == id);
    hystorySessions.last.state = StateSession.open;
    saveHystorySessionsToLocal();
  }

  /// отмена сканирования
  void undoMatrix() {
    hystorySessions.last.listSessions.removeLast();
    hystorySessions.last.state = StateSession.open;
    saveHystorySessionsToLocal();
  }

  /// Обновление ID сессии
  String updateSessionId({required String oldId, required String newId}) {
    final session = lastDay.listSessions.firstWhereOrNull((e) => e.id == oldId);
    if (session == null) {
      return 'Сессия не найдена!';
    }

    final existingSession =
        lastDay.listSessions.firstWhereOrNull((e) => e.id == newId);
    if (existingSession != null) {
      return 'Сессия с таким ID уже существует!';
    }

    session.id = newId;
    saveHystorySessionsToLocal();
    return '';
  }

  /// закрытие сессии
  Future<String> closeSession() async {
    String fileName =
        '${lastDay.listSessions.last.id}_${lastDay.listSessions.last.time.microsecondsSinceEpoch}.json';
    Map<String, dynamic> data = {};
    data['FIO'] = '${user.family} ${user.name} ${user.patron}';
    data['ID'] = user.id;
    data['TT_INFO'] = lastDay.listSessions.last.toMapForFtp();
    Logger.i('data == $data');
    Logger.i('fileName == $fileName');

    // Пытаемся отправить на FTP сервер
    String answer = await Api().uploadHystorySessionsToFtp(data, fileName);
    Logger.i('answer == $answer');

    // ВАЖНО: Сохраняем данные локально ВСЕГДА, независимо от результата FTP
    lastDay.listSessions.last.state = StateSession.close;

    // Отмечаем сессию как отправленную только если FTP успешен
    if (answer.isEmpty) {
      lastDay.listSessions.last.isUploaded = true;
      Logger.i(
          'Сессия ${lastDay.listSessions.last.id} успешно отправлена на сервер');
    } else {
      lastDay.listSessions.last.isUploaded = false;
      Logger.w(
          'FTP загрузка не удалась, но данные сохранены локально: $answer');
    }

    Logger.i(
        'closeSession: после закрытия lastDay.listSessions.length = ${lastDay.listSessions.length}');
    Logger.i(
        'closeSession: после закрытия hystorySessions.last.listSessions.length = ${hystorySessions.last.listSessions.length}');
    Logger.i('${lastDay.listSessions.last.toJson()}');
    saveHystorySessionsToLocal();

    // Если была ошибка FTP, возвращаем сообщение об ошибке
    if (answer.isNotEmpty) {
      return 'Ошибка сохранения на сервер: $answer. Данные сохранены локально и будут отправлены позже.';
    }

    return '';
  }

  /// закрытие дня
  Future<String> closeDay() async {
    lastDay.state = StateSession.close;

    // Пытаемся повторно отправить все неотправленные сессии
    await _retryFailedUploads();

    // НЕ создаем новый день здесь - это должно происходить только в конце дня
    // hystorySessions.add(HystorySessions.init());
    saveHystorySessionsToLocal();
    await Future.delayed(const Duration(seconds: 1));
    return '';
  }

  /// Повторная отправка всех неотправленных сессий
  Future<void> _retryFailedUploads() async {
    Logger.i('Попытка повторной отправки неотправленных сессий...');

    for (var day in hystorySessions) {
      for (var session in day.listSessions) {
        if (session.state == StateSession.close && !session.isUploaded) {
          try {
            String fileName =
                '${session.id}_${session.time.microsecondsSinceEpoch}.json';
            Map<String, dynamic> data = {};
            data['FIO'] = '${user.family} ${user.name} ${user.patron}';
            data['ID'] = user.id;
            data['TT_INFO'] = session.toMapForFtp();

            String answer =
                await Api().uploadHystorySessionsToFtp(data, fileName);
            if (answer.isEmpty) {
              session.isUploaded = true;
              Logger.i('Сессия ${session.id} успешно отправлена повторно');
            } else {
              Logger.w(
                  'Не удалось повторно отправить сессию ${session.id}: $answer');
            }
          } catch (e) {
            Logger.e('Ошибка при повторной отправке сессии ${session.id}: $e');
          }
        }
      }
    }

    // Сохраняем обновленные данные
    saveHystorySessionsToLocal();
  }

  /// Проверка статуса отправки сессий за сегодня
  Map<String, dynamic> getTodayUploadStatus() {
    int totalClosed = 0;
    int uploaded = 0;
    int pending = 0;

    for (var session in lastDay.listSessions) {
      if (session.state == StateSession.close) {
        totalClosed++;
        if (session.isUploaded) {
          uploaded++;
        } else {
          pending++;
        }
      }
    }

    return {
      'totalClosed': totalClosed,
      'uploaded': uploaded,
      'pending': pending,
      'allUploaded': totalClosed > 0 && pending == 0,
    };
  }

  /// Принудительная отправка всех неотправленных сессий
  Future<String> forceUploadAllSessions() async {
    Logger.i('Принудительная отправка всех неотправленных сессий...');

    int successCount = 0;
    int failCount = 0;
    String lastError = '';

    for (var day in hystorySessions) {
      for (var session in day.listSessions) {
        if (session.state == StateSession.close && !session.isUploaded) {
          try {
            String fileName =
                '${session.id}_${session.time.microsecondsSinceEpoch}.json';
            Map<String, dynamic> data = {};
            data['FIO'] = '${user.family} ${user.name} ${user.patron}';
            data['ID'] = user.id;
            data['TT_INFO'] = session.toMapForFtp();

            String answer =
                await Api().uploadHystorySessionsToFtp(data, fileName);
            if (answer.isEmpty) {
              session.isUploaded = true;
              successCount++;
              Logger.i('Сессия ${session.id} успешно отправлена');
            } else {
              failCount++;
              lastError = answer;
              Logger.w('Не удалось отправить сессию ${session.id}: $answer');
            }
          } catch (e) {
            failCount++;
            lastError = e.toString();
            Logger.e('Ошибка при отправке сессии ${session.id}: $e');
          }
        }
      }
    }

    // Сохраняем обновленные данные
    saveHystorySessionsToLocal();

    if (failCount == 0) {
      return '';
    } else {
      return 'Отправлено: $successCount, Ошибок: $failCount. Последняя ошибка: $lastError';
    }
  }

  /// Добавление сессии
  String addHystorySessions({
    required String id,
    required String sessionId,
    required Position position,
  }) {
    final result =
        lastDay.listSessions.firstWhereOrNull((e) => e.id == sessionId);
    Logger.i(
        'addHystorySessions ${lastDay.listSessions.length} sessionId=$sessionId, ttId=$id, position=$position');
    if (result != null) {
      return 'Эту сессию вы уже сканировали!';
    } else {
      SessionScan tempSession = SessionScan.init();
      tempSession.id = sessionId; // Используем уникальный ID сессии
      tempSession.position = position;
      tempSession.time = DateTime.now();
      Logger.i(
          'addHystorySessions: ДО добавления lastDay.listSessions.length = ${lastDay.listSessions.length}');
      Logger.i(
          'addHystorySessions: ДО добавления hystorySessions.last.listSessions.length = ${hystorySessions.last.listSessions.length}');
      lastDay.addSession(tempSession);
      lastDay.state = StateSession.open;
      Logger.i(
          'addHystorySessions: после добавления lastDay.listSessions.length = ${lastDay.listSessions.length}');
      Logger.i(
          'addHystorySessions: после добавления hystorySessions.last.listSessions.length = ${hystorySessions.last.listSessions.length}');
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
    hystorySessions.clear();
    hystorySessions.add(HystorySessions.init());
    Logger.i('lastDay ${lastDay.toJson()}');
    await saveHystorySessionsToLocal();
  }

  /// авторизация пользователя
  Future<bool> authUser({required User userIn}) async {
    user = userIn;

    /// после авторизации загружаем данные из RoutersRepository
    bool dataLoaded = await Get.find<RoutersRepository>().init();

    if (!dataLoaded) {
      // Данные не загружены - НЕ переходим дальше
      return false;
    }

    // Только после успешной загрузки данных проверяем первый заход
    Get.find<MainBloc>().add(CheckFirstLoginEvent());
    Get.find<MainBloc>().add(LoadRoutersEvent());
    await saveUserToLocal();
    return true;
  }

  /// Проверка первого входа пользователя
  Future<void> _checkFirstLogin() async {
    // Проверяем, есть ли сохраненные данные о последнем открытом дне
    final lastOpened =
        await Get.find<RoutersRepository>().loadLastOpenedWeekDay();

    if (lastOpened == null) {
      // Это первый заход - нужно показать выбор дня
      Logger.i('Первый заход пользователя, нужно показать выбор дня');
      // Здесь можно добавить флаг или событие для показа экрана выбора дня
      // Пока что просто логируем
    } else {
      Logger.i('Пользователь уже работал ранее, последний день: $lastOpened');
    }
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
