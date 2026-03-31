import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdtime/data/drift/app_database.dart';
import 'package:tdtime/data/local_data.dart';
import 'package:tdtime/domain/models/hystory_sessions.dart';
import 'package:tdtime/domain/models/session.dart';

/// Локальное хранение истории сессий (дни → сессии ТТ → строки DataMatrix).
class HistoryDriftRepository {
  HistoryDriftRepository(this._db);

  final AppDatabase _db;

  static int _stateIndex(StateSession s) =>
      StateSession.values.indexOf(s).clamp(0, StateSession.values.length - 1);

  static StateSession _stateAt(int index) {
    final i = index.clamp(0, StateSession.values.length - 1);
    return StateSession.values[i];
  }

  Future<void> migrateFromPrefsIfNeeded() async {
    final existing = await _db.select(_db.historyDays).get();
    if (existing.isNotEmpty) {
      await _clearPrefsHistoryKey();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(LocalDataKey.hystorySessions.name);
    if (raw == null || raw.isEmpty) return;

    final maps = <Map<String, dynamic>>[];
    try {
      for (final s in raw) {
        maps.add(jsonDecode(s) as Map<String, dynamic>);
      }
    } catch (e) {
      Logger.e('HistoryDriftRepository migrate decode: $e');
      return;
    }
    if (maps.isEmpty) return;
    if (maps.first['error'] != null) return;

    await _db.transaction(() async {
      for (final dayMap in maps) {
        final day = HystorySessions.fromJson(dayMap);
        final dayId = await _db.into(_db.historyDays).insert(
              HistoryDaysCompanion.insert(
                dayTimeMs: day.time.millisecondsSinceEpoch,
                dayStateIndex: _stateIndex(day.state),
              ),
            );
        for (var i = 0; i < day.listSessions.length; i++) {
          final session = day.listSessions[i];
          final sid = await _insertSessionRow(
            dayId: dayId,
            session: session,
            sessionOrder: i,
          );
          for (var j = 0; j < session.dataMatrix.length; j++) {
            await _db.into(_db.matrixScanLines).insert(
                  MatrixScanLinesCompanion.insert(
                    sessionId: sid,
                    sortIndex: j,
                    code: session.dataMatrix[j],
                  ),
                );
          }
        }
      }
    });

    await prefs.remove(LocalDataKey.hystorySessions.name);
    Logger.i('История мигрирована из SharedPreferences в Drift');
  }

  Future<List<HystorySessions>> loadAllDays() async {
    final dayRows = await (_db.select(_db.historyDays)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();

    final result = <HystorySessions>[];
    for (final d in dayRows) {
      final sessionRows = await (_db.select(_db.routeSessionRows)
            ..where((t) => t.dayId.equals(d.id))
            ..orderBy([(t) => OrderingTerm(expression: t.sessionOrder)]))
          .get();

      final listSessions = <SessionScan>[];
      for (final sr in sessionRows) {
        final lineRows = await (_db.select(_db.matrixScanLines)
              ..where((t) => t.sessionId.equals(sr.id))
              ..orderBy([(t) => OrderingTerm(expression: t.sortIndex)]))
            .get();

        final posMap =
            jsonDecode(sr.positionJson) as Map<String, dynamic>? ?? {};
        listSessions.add(SessionScan(
          id: sr.ttId,
          position: Position.fromMap(posMap),
          time: DateTime.fromMillisecondsSinceEpoch(sr.sessionTimeMs),
          dataMatrix: lineRows.map((l) => l.code).toList(),
          state: _stateAt(sr.sessionStateIndex),
          isUploaded: sr.isUploaded,
          driftRowId: sr.id,
        ));
      }

      result.add(HystorySessions(
        listSessions: listSessions,
        time: DateTime.fromMillisecondsSinceEpoch(d.dayTimeMs),
        state: _stateAt(d.dayStateIndex),
        driftDayRowId: d.id,
      ));
    }
    return result;
  }

  Future<void> insertNewDay(HystorySessions day) async {
    final id = await _db.into(_db.historyDays).insert(
          HistoryDaysCompanion.insert(
            dayTimeMs: day.time.millisecondsSinceEpoch,
            dayStateIndex: _stateIndex(day.state),
          ),
        );
    day.driftDayRowId = id;
  }

  Future<void> insertSessionForDay(HystorySessions day, SessionScan session) async {
    final dayId = day.driftDayRowId;
    if (dayId == null) {
      Logger.e('insertSessionForDay: нет driftDayRowId');
      return;
    }
    final order = day.listSessions.length - 1;
    final sid = await _insertSessionRow(
      dayId: dayId,
      session: session,
      sessionOrder: order,
    );
    session.driftRowId = sid;

    await (_db.update(_db.historyDays)..where((t) => t.id.equals(dayId))).write(
          HistoryDaysCompanion(
            dayStateIndex: Value(_stateIndex(day.state)),
            dayTimeMs: Value(day.time.millisecondsSinceEpoch),
          ),
        );
  }

  Future<int> _insertSessionRow({
    required int dayId,
    required SessionScan session,
    required int sessionOrder,
  }) {
    return _db.into(_db.routeSessionRows).insert(
          RouteSessionRowsCompanion.insert(
            dayId: dayId,
            ttId: session.id,
            sessionTimeMs: session.time.millisecondsSinceEpoch,
            sessionStateIndex: _stateIndex(session.state),
            isUploaded: Value(session.isUploaded),
            positionJson: jsonEncode(session.position.toJson()),
            sessionOrder: sessionOrder,
          ),
        );
  }

  Future<void> appendScanLine({
    required int dayId,
    required int sessionDriftId,
    required int sortIndex,
    required String code,
  }) async {
    await _db.into(_db.matrixScanLines).insert(
          MatrixScanLinesCompanion.insert(
            sessionId: sessionDriftId,
            sortIndex: sortIndex,
            code: code,
          ),
        );

    await (_db.update(_db.routeSessionRows)
          ..where((t) => t.id.equals(sessionDriftId)))
        .write(
      RouteSessionRowsCompanion(
        sessionStateIndex: Value(_stateIndex(StateSession.inwork)),
      ),
    );

    await (_db.update(_db.historyDays)..where((t) => t.id.equals(dayId))).write(
          HistoryDaysCompanion(
            dayStateIndex: Value(_stateIndex(StateSession.inwork)),
          ),
        );
  }

  Future<void> deleteSessionByTtIdOnDay(int dayId, String ttId) async {
    final row = await (_db.select(_db.routeSessionRows)
          ..where((t) => t.dayId.equals(dayId) & t.ttId.equals(ttId)))
        .getSingleOrNull();
    if (row == null) return;

    await (_db.delete(_db.routeSessionRows)..where((t) => t.id.equals(row.id)))
        .go();

    await (_db.update(_db.historyDays)..where((t) => t.id.equals(dayId))).write(
          HistoryDaysCompanion(
            dayStateIndex: Value(_stateIndex(StateSession.open)),
          ),
        );
  }

  Future<void> deleteLastSessionOnDay(int dayId) async {
    final rows = await (_db.select(_db.routeSessionRows)
          ..where((t) => t.dayId.equals(dayId))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.sessionOrder,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .get();
    if (rows.isEmpty) return;

    await (_db.delete(_db.routeSessionRows)
          ..where((t) => t.id.equals(rows.first.id)))
        .go();

    await (_db.update(_db.historyDays)..where((t) => t.id.equals(dayId))).write(
          HistoryDaysCompanion(
            dayStateIndex: Value(_stateIndex(StateSession.open)),
          ),
        );
  }

  Future<void> updateSessionTtId(int sessionDriftId, String newTtId) async {
    await (_db.update(_db.routeSessionRows)
          ..where((t) => t.id.equals(sessionDriftId)))
        .write(RouteSessionRowsCompanion(ttId: Value(newTtId)));
  }

  Future<void> persistSessionFlags(SessionScan session) async {
    final rid = session.driftRowId;
    if (rid == null) return;
    await (_db.update(_db.routeSessionRows)..where((t) => t.id.equals(rid)))
        .write(
      RouteSessionRowsCompanion(
        sessionStateIndex: Value(_stateIndex(session.state)),
        isUploaded: Value(session.isUploaded),
      ),
    );
  }

  Future<void> updateDayState(int dayId, StateSession state) async {
    await (_db.update(_db.historyDays)..where((t) => t.id.equals(dayId))).write(
          HistoryDaysCompanion(dayStateIndex: Value(_stateIndex(state))),
        );
  }

  Future<void> clearAll() async {
    await _db.delete(_db.matrixScanLines).go();
    await _db.delete(_db.routeSessionRows).go();
    await _db.delete(_db.historyDays).go();
  }

  Future<void> _clearPrefsHistoryKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalDataKey.hystorySessions.name);
  }
}
