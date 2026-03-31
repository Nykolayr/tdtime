import 'package:geolocator/geolocator.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/data/drift/app_database.dart';
import 'package:tdtime/data/drift/history_drift_repository.dart';
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

  late final HistoryDriftRepository _historyStore;

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
    _historyStore = HistoryDriftRepository(Get.find<AppDatabase>());
    await loadUserFromLocal();
    try {
      await _historyStore.migrateFromPrefsIfNeeded();
      hystorySessions = await _historyStore.loadAllDays();
      if (hystorySessions.isEmpty) {
        final d = HystorySessions.init();
        hystorySessions.add(d);
        await _historyStore.insertNewDay(d);
      }
    } catch (e) {
      Logger.e('error load history from Drift $e');
      final fallback = HystorySessions.init();
      hystorySessions = [fallback];
      try {
        await _historyStore.insertNewDay(fallback);
      } catch (e2) {
        Logger.e('insertNewDay after history load error: $e2');
      }
    }

    // Проверяем, есть ли неотправленные сессии в предыдущих днях
    await _checkForUnsentSessions();

    Logger.i('lastDay init ${lastDay.toJson()}');
  }

  /// Новый «день» при смене маршрута (выбор дня недели).
  Future<void> addNewRouteDay() async {
    final d = HystorySessions.init();
    hystorySessions.add(d);
    await _historyStore.insertNewDay(d);
  }

  /// Пустой закрытый день после [closeDay] (логика главного экрана).
  Future<void> appendClosedEmptyDayAfterDayClose() async {
    final newDay = HystorySessions.init();
    newDay.state = StateSession.close;
    hystorySessions.add(newDay);
    await _historyStore.insertNewDay(newDay);
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
                await _historyStore.persistSessionFlags(session);
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

    if (failCount == 0) {
      return '';
    } else {
      return 'Отправлено: $successCount, Ошибок: $failCount. Последняя ошибка: $lastError';
    }
  }

  /// удаление сессии
  Future<void> deleteMatrix({required String id}) async {
    final day = hystorySessions.last;
    final dayDbId = day.driftDayRowId;
    day.listSessions.removeWhere((e) => e.id == id);
    day.state = StateSession.open;
    if (dayDbId != null) {
      await _historyStore.deleteSessionByTtIdOnDay(dayDbId, id);
    }
  }

  /// отмена сканирования
  Future<void> undoMatrix() async {
    final day = hystorySessions.last;
    if (day.listSessions.isEmpty) return;
    day.listSessions.removeLast();
    day.state = StateSession.open;
    final dayDbId = day.driftDayRowId;
    if (dayDbId != null) {
      await _historyStore.deleteLastSessionOnDay(dayDbId);
    }
  }

  /// Обновление ID сессии
  Future<String> updateSessionId(
      {required String oldId, required String newId}) async {
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
    final rid = session.driftRowId;
    if (rid != null) {
      await _historyStore.updateSessionTtId(rid, newId);
    }
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
    await _historyStore.persistSessionFlags(lastDay.listSessions.last);

    // Если была ошибка FTP, возвращаем сообщение об ошибке
    if (answer.isNotEmpty) {
      return 'Ошибка сохранения на сервер: $answer. Данные сохранены локально и будут отправлены позже.';
    }

    return '';
  }

  /// закрытие дня
  Future<String> closeDay() async {
    lastDay.state = StateSession.close;
    final did = lastDay.driftDayRowId;
    if (did != null) {
      await _historyStore.updateDayState(did, StateSession.close);
    }

    // Пытаемся повторно отправить все неотправленные сессии
    await _retryFailedUploads();

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
              await _historyStore.persistSessionFlags(session);
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
              await _historyStore.persistSessionFlags(session);
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

    if (failCount == 0) {
      return '';
    } else {
      return 'Отправлено: $successCount, Ошибок: $failCount. Последняя ошибка: $lastError';
    }
  }

  /// Добавление сессии
  Future<String> addHystorySessions({
    required String id,
    required String sessionId,
    required Position position,
  }) async {
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
      await _historyStore.insertSessionForDay(lastDay, tempSession);
    }
    return '';
  }

  /// Добавление DataMatrix в сессию
  Future<String> addMatrix({required String id}) async {
    if (hystorySessions.last.listSessions.last.dataMatrix.contains(id)) {
      return 'Этот DataMatrix вы уже сканировали!';
    }
    hystorySessions.last.listSessions.last.dataMatrix.add(id);
    hystorySessions.last.state = StateSession.inwork;
    final day = hystorySessions.last;
    final session = day.listSessions.last;
    final dayId = day.driftDayRowId;
    final sid = session.driftRowId;
    if (dayId != null && sid != null) {
      await _historyStore.appendScanLine(
        dayId: dayId,
        sessionDriftId: sid,
        sortIndex: session.dataMatrix.length - 1,
        code: id,
      );
    } else {
      Logger.e('addMatrix: нет drift id у дня или сессии');
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData().clear();
    user = User.initial();
    hystorySessions.clear();
    await _historyStore.clearAll();
    final d = HystorySessions.init();
    hystorySessions.add(d);
    await _historyStore.insertNewDay(d);
    Logger.i('lastDay ${lastDay.toJson()}');
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
  Future<void> checkFirstLogin() async {
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

}
