import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

class HistoryDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayTimeMs => integer()();

  IntColumn get dayStateIndex => integer()();
}

class RouteSessionRows extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayId => integer().references(HistoryDays, #id,
      onDelete: KeyAction.cascade)();

  TextColumn get ttId => text()();

  IntColumn get sessionTimeMs => integer()();

  IntColumn get sessionStateIndex => integer()();

  BoolColumn get isUploaded =>
      boolean().withDefault(const Constant(false))();

  TextColumn get positionJson => text()();

  IntColumn get sessionOrder => integer()();
}

class MatrixScanLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId => integer().references(RouteSessionRows, #id,
      onDelete: KeyAction.cascade)();

  IntColumn get sortIndex => integer()();

  TextColumn get code => text()();
}

@DriftDatabase(tables: [HistoryDays, RouteSessionRows, MatrixScanLines])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tdtime_history.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
