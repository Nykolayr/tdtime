// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HistoryDaysTable extends HistoryDays
    with TableInfo<$HistoryDaysTable, HistoryDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayTimeMsMeta =
      const VerificationMeta('dayTimeMs');
  @override
  late final GeneratedColumn<int> dayTimeMs = GeneratedColumn<int>(
      'day_time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dayStateIndexMeta =
      const VerificationMeta('dayStateIndex');
  @override
  late final GeneratedColumn<int> dayStateIndex = GeneratedColumn<int>(
      'day_state_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, dayTimeMs, dayStateIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_days';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_time_ms')) {
      context.handle(
          _dayTimeMsMeta,
          dayTimeMs.isAcceptableOrUnknown(
              data['day_time_ms']!, _dayTimeMsMeta));
    } else if (isInserting) {
      context.missing(_dayTimeMsMeta);
    }
    if (data.containsKey('day_state_index')) {
      context.handle(
          _dayStateIndexMeta,
          dayStateIndex.isAcceptableOrUnknown(
              data['day_state_index']!, _dayStateIndexMeta));
    } else if (isInserting) {
      context.missing(_dayStateIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_time_ms'])!,
      dayStateIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_state_index'])!,
    );
  }

  @override
  $HistoryDaysTable createAlias(String alias) {
    return $HistoryDaysTable(attachedDatabase, alias);
  }
}

class HistoryDay extends DataClass implements Insertable<HistoryDay> {
  final int id;
  final int dayTimeMs;
  final int dayStateIndex;
  const HistoryDay(
      {required this.id, required this.dayTimeMs, required this.dayStateIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_time_ms'] = Variable<int>(dayTimeMs);
    map['day_state_index'] = Variable<int>(dayStateIndex);
    return map;
  }

  HistoryDaysCompanion toCompanion(bool nullToAbsent) {
    return HistoryDaysCompanion(
      id: Value(id),
      dayTimeMs: Value(dayTimeMs),
      dayStateIndex: Value(dayStateIndex),
    );
  }

  factory HistoryDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryDay(
      id: serializer.fromJson<int>(json['id']),
      dayTimeMs: serializer.fromJson<int>(json['dayTimeMs']),
      dayStateIndex: serializer.fromJson<int>(json['dayStateIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayTimeMs': serializer.toJson<int>(dayTimeMs),
      'dayStateIndex': serializer.toJson<int>(dayStateIndex),
    };
  }

  HistoryDay copyWith({int? id, int? dayTimeMs, int? dayStateIndex}) =>
      HistoryDay(
        id: id ?? this.id,
        dayTimeMs: dayTimeMs ?? this.dayTimeMs,
        dayStateIndex: dayStateIndex ?? this.dayStateIndex,
      );
  HistoryDay copyWithCompanion(HistoryDaysCompanion data) {
    return HistoryDay(
      id: data.id.present ? data.id.value : this.id,
      dayTimeMs: data.dayTimeMs.present ? data.dayTimeMs.value : this.dayTimeMs,
      dayStateIndex: data.dayStateIndex.present
          ? data.dayStateIndex.value
          : this.dayStateIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryDay(')
          ..write('id: $id, ')
          ..write('dayTimeMs: $dayTimeMs, ')
          ..write('dayStateIndex: $dayStateIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayTimeMs, dayStateIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryDay &&
          other.id == this.id &&
          other.dayTimeMs == this.dayTimeMs &&
          other.dayStateIndex == this.dayStateIndex);
}

class HistoryDaysCompanion extends UpdateCompanion<HistoryDay> {
  final Value<int> id;
  final Value<int> dayTimeMs;
  final Value<int> dayStateIndex;
  const HistoryDaysCompanion({
    this.id = const Value.absent(),
    this.dayTimeMs = const Value.absent(),
    this.dayStateIndex = const Value.absent(),
  });
  HistoryDaysCompanion.insert({
    this.id = const Value.absent(),
    required int dayTimeMs,
    required int dayStateIndex,
  })  : dayTimeMs = Value(dayTimeMs),
        dayStateIndex = Value(dayStateIndex);
  static Insertable<HistoryDay> custom({
    Expression<int>? id,
    Expression<int>? dayTimeMs,
    Expression<int>? dayStateIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayTimeMs != null) 'day_time_ms': dayTimeMs,
      if (dayStateIndex != null) 'day_state_index': dayStateIndex,
    });
  }

  HistoryDaysCompanion copyWith(
      {Value<int>? id, Value<int>? dayTimeMs, Value<int>? dayStateIndex}) {
    return HistoryDaysCompanion(
      id: id ?? this.id,
      dayTimeMs: dayTimeMs ?? this.dayTimeMs,
      dayStateIndex: dayStateIndex ?? this.dayStateIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayTimeMs.present) {
      map['day_time_ms'] = Variable<int>(dayTimeMs.value);
    }
    if (dayStateIndex.present) {
      map['day_state_index'] = Variable<int>(dayStateIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryDaysCompanion(')
          ..write('id: $id, ')
          ..write('dayTimeMs: $dayTimeMs, ')
          ..write('dayStateIndex: $dayStateIndex')
          ..write(')'))
        .toString();
  }
}

class $RouteSessionRowsTable extends RouteSessionRows
    with TableInfo<$RouteSessionRowsTable, RouteSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteSessionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
      'day_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_days (id) ON DELETE CASCADE'));
  static const VerificationMeta _ttIdMeta = const VerificationMeta('ttId');
  @override
  late final GeneratedColumn<String> ttId = GeneratedColumn<String>(
      'tt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionTimeMsMeta =
      const VerificationMeta('sessionTimeMs');
  @override
  late final GeneratedColumn<int> sessionTimeMs = GeneratedColumn<int>(
      'session_time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionStateIndexMeta =
      const VerificationMeta('sessionStateIndex');
  @override
  late final GeneratedColumn<int> sessionStateIndex = GeneratedColumn<int>(
      'session_state_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isUploadedMeta =
      const VerificationMeta('isUploaded');
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
      'is_uploaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_uploaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _positionJsonMeta =
      const VerificationMeta('positionJson');
  @override
  late final GeneratedColumn<String> positionJson = GeneratedColumn<String>(
      'position_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionOrderMeta =
      const VerificationMeta('sessionOrder');
  @override
  late final GeneratedColumn<int> sessionOrder = GeneratedColumn<int>(
      'session_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dayId,
        ttId,
        sessionTimeMs,
        sessionStateIndex,
        isUploaded,
        positionJson,
        sessionOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_session_rows';
  @override
  VerificationContext validateIntegrity(Insertable<RouteSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
          _dayIdMeta, dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta));
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('tt_id')) {
      context.handle(
          _ttIdMeta, ttId.isAcceptableOrUnknown(data['tt_id']!, _ttIdMeta));
    } else if (isInserting) {
      context.missing(_ttIdMeta);
    }
    if (data.containsKey('session_time_ms')) {
      context.handle(
          _sessionTimeMsMeta,
          sessionTimeMs.isAcceptableOrUnknown(
              data['session_time_ms']!, _sessionTimeMsMeta));
    } else if (isInserting) {
      context.missing(_sessionTimeMsMeta);
    }
    if (data.containsKey('session_state_index')) {
      context.handle(
          _sessionStateIndexMeta,
          sessionStateIndex.isAcceptableOrUnknown(
              data['session_state_index']!, _sessionStateIndexMeta));
    } else if (isInserting) {
      context.missing(_sessionStateIndexMeta);
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
          _isUploadedMeta,
          isUploaded.isAcceptableOrUnknown(
              data['is_uploaded']!, _isUploadedMeta));
    }
    if (data.containsKey('position_json')) {
      context.handle(
          _positionJsonMeta,
          positionJson.isAcceptableOrUnknown(
              data['position_json']!, _positionJsonMeta));
    } else if (isInserting) {
      context.missing(_positionJsonMeta);
    }
    if (data.containsKey('session_order')) {
      context.handle(
          _sessionOrderMeta,
          sessionOrder.isAcceptableOrUnknown(
              data['session_order']!, _sessionOrderMeta));
    } else if (isInserting) {
      context.missing(_sessionOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_id'])!,
      ttId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tt_id'])!,
      sessionTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_time_ms'])!,
      sessionStateIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}session_state_index'])!,
      isUploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_uploaded'])!,
      positionJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}position_json'])!,
      sessionOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_order'])!,
    );
  }

  @override
  $RouteSessionRowsTable createAlias(String alias) {
    return $RouteSessionRowsTable(attachedDatabase, alias);
  }
}

class RouteSessionRow extends DataClass implements Insertable<RouteSessionRow> {
  final int id;
  final int dayId;
  final String ttId;
  final int sessionTimeMs;
  final int sessionStateIndex;
  final bool isUploaded;
  final String positionJson;
  final int sessionOrder;
  const RouteSessionRow(
      {required this.id,
      required this.dayId,
      required this.ttId,
      required this.sessionTimeMs,
      required this.sessionStateIndex,
      required this.isUploaded,
      required this.positionJson,
      required this.sessionOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['tt_id'] = Variable<String>(ttId);
    map['session_time_ms'] = Variable<int>(sessionTimeMs);
    map['session_state_index'] = Variable<int>(sessionStateIndex);
    map['is_uploaded'] = Variable<bool>(isUploaded);
    map['position_json'] = Variable<String>(positionJson);
    map['session_order'] = Variable<int>(sessionOrder);
    return map;
  }

  RouteSessionRowsCompanion toCompanion(bool nullToAbsent) {
    return RouteSessionRowsCompanion(
      id: Value(id),
      dayId: Value(dayId),
      ttId: Value(ttId),
      sessionTimeMs: Value(sessionTimeMs),
      sessionStateIndex: Value(sessionStateIndex),
      isUploaded: Value(isUploaded),
      positionJson: Value(positionJson),
      sessionOrder: Value(sessionOrder),
    );
  }

  factory RouteSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteSessionRow(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      ttId: serializer.fromJson<String>(json['ttId']),
      sessionTimeMs: serializer.fromJson<int>(json['sessionTimeMs']),
      sessionStateIndex: serializer.fromJson<int>(json['sessionStateIndex']),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      positionJson: serializer.fromJson<String>(json['positionJson']),
      sessionOrder: serializer.fromJson<int>(json['sessionOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'ttId': serializer.toJson<String>(ttId),
      'sessionTimeMs': serializer.toJson<int>(sessionTimeMs),
      'sessionStateIndex': serializer.toJson<int>(sessionStateIndex),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'positionJson': serializer.toJson<String>(positionJson),
      'sessionOrder': serializer.toJson<int>(sessionOrder),
    };
  }

  RouteSessionRow copyWith(
          {int? id,
          int? dayId,
          String? ttId,
          int? sessionTimeMs,
          int? sessionStateIndex,
          bool? isUploaded,
          String? positionJson,
          int? sessionOrder}) =>
      RouteSessionRow(
        id: id ?? this.id,
        dayId: dayId ?? this.dayId,
        ttId: ttId ?? this.ttId,
        sessionTimeMs: sessionTimeMs ?? this.sessionTimeMs,
        sessionStateIndex: sessionStateIndex ?? this.sessionStateIndex,
        isUploaded: isUploaded ?? this.isUploaded,
        positionJson: positionJson ?? this.positionJson,
        sessionOrder: sessionOrder ?? this.sessionOrder,
      );
  RouteSessionRow copyWithCompanion(RouteSessionRowsCompanion data) {
    return RouteSessionRow(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      ttId: data.ttId.present ? data.ttId.value : this.ttId,
      sessionTimeMs: data.sessionTimeMs.present
          ? data.sessionTimeMs.value
          : this.sessionTimeMs,
      sessionStateIndex: data.sessionStateIndex.present
          ? data.sessionStateIndex.value
          : this.sessionStateIndex,
      isUploaded:
          data.isUploaded.present ? data.isUploaded.value : this.isUploaded,
      positionJson: data.positionJson.present
          ? data.positionJson.value
          : this.positionJson,
      sessionOrder: data.sessionOrder.present
          ? data.sessionOrder.value
          : this.sessionOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteSessionRow(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('ttId: $ttId, ')
          ..write('sessionTimeMs: $sessionTimeMs, ')
          ..write('sessionStateIndex: $sessionStateIndex, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('positionJson: $positionJson, ')
          ..write('sessionOrder: $sessionOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayId, ttId, sessionTimeMs,
      sessionStateIndex, isUploaded, positionJson, sessionOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteSessionRow &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.ttId == this.ttId &&
          other.sessionTimeMs == this.sessionTimeMs &&
          other.sessionStateIndex == this.sessionStateIndex &&
          other.isUploaded == this.isUploaded &&
          other.positionJson == this.positionJson &&
          other.sessionOrder == this.sessionOrder);
}

class RouteSessionRowsCompanion extends UpdateCompanion<RouteSessionRow> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<String> ttId;
  final Value<int> sessionTimeMs;
  final Value<int> sessionStateIndex;
  final Value<bool> isUploaded;
  final Value<String> positionJson;
  final Value<int> sessionOrder;
  const RouteSessionRowsCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.ttId = const Value.absent(),
    this.sessionTimeMs = const Value.absent(),
    this.sessionStateIndex = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.positionJson = const Value.absent(),
    this.sessionOrder = const Value.absent(),
  });
  RouteSessionRowsCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required String ttId,
    required int sessionTimeMs,
    required int sessionStateIndex,
    this.isUploaded = const Value.absent(),
    required String positionJson,
    required int sessionOrder,
  })  : dayId = Value(dayId),
        ttId = Value(ttId),
        sessionTimeMs = Value(sessionTimeMs),
        sessionStateIndex = Value(sessionStateIndex),
        positionJson = Value(positionJson),
        sessionOrder = Value(sessionOrder);
  static Insertable<RouteSessionRow> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<String>? ttId,
    Expression<int>? sessionTimeMs,
    Expression<int>? sessionStateIndex,
    Expression<bool>? isUploaded,
    Expression<String>? positionJson,
    Expression<int>? sessionOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (ttId != null) 'tt_id': ttId,
      if (sessionTimeMs != null) 'session_time_ms': sessionTimeMs,
      if (sessionStateIndex != null) 'session_state_index': sessionStateIndex,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (positionJson != null) 'position_json': positionJson,
      if (sessionOrder != null) 'session_order': sessionOrder,
    });
  }

  RouteSessionRowsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dayId,
      Value<String>? ttId,
      Value<int>? sessionTimeMs,
      Value<int>? sessionStateIndex,
      Value<bool>? isUploaded,
      Value<String>? positionJson,
      Value<int>? sessionOrder}) {
    return RouteSessionRowsCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      ttId: ttId ?? this.ttId,
      sessionTimeMs: sessionTimeMs ?? this.sessionTimeMs,
      sessionStateIndex: sessionStateIndex ?? this.sessionStateIndex,
      isUploaded: isUploaded ?? this.isUploaded,
      positionJson: positionJson ?? this.positionJson,
      sessionOrder: sessionOrder ?? this.sessionOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (ttId.present) {
      map['tt_id'] = Variable<String>(ttId.value);
    }
    if (sessionTimeMs.present) {
      map['session_time_ms'] = Variable<int>(sessionTimeMs.value);
    }
    if (sessionStateIndex.present) {
      map['session_state_index'] = Variable<int>(sessionStateIndex.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (positionJson.present) {
      map['position_json'] = Variable<String>(positionJson.value);
    }
    if (sessionOrder.present) {
      map['session_order'] = Variable<int>(sessionOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteSessionRowsCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('ttId: $ttId, ')
          ..write('sessionTimeMs: $sessionTimeMs, ')
          ..write('sessionStateIndex: $sessionStateIndex, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('positionJson: $positionJson, ')
          ..write('sessionOrder: $sessionOrder')
          ..write(')'))
        .toString();
  }
}

class $MatrixScanLinesTable extends MatrixScanLines
    with TableInfo<$MatrixScanLinesTable, MatrixScanLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatrixScanLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES route_session_rows (id) ON DELETE CASCADE'));
  static const VerificationMeta _sortIndexMeta =
      const VerificationMeta('sortIndex');
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
      'sort_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, sortIndex, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matrix_scan_lines';
  @override
  VerificationContext validateIntegrity(Insertable<MatrixScanLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(_sortIndexMeta,
          sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta));
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatrixScanLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatrixScanLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      sortIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_index'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
    );
  }

  @override
  $MatrixScanLinesTable createAlias(String alias) {
    return $MatrixScanLinesTable(attachedDatabase, alias);
  }
}

class MatrixScanLine extends DataClass implements Insertable<MatrixScanLine> {
  final int id;
  final int sessionId;
  final int sortIndex;
  final String code;
  const MatrixScanLine(
      {required this.id,
      required this.sessionId,
      required this.sortIndex,
      required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['sort_index'] = Variable<int>(sortIndex);
    map['code'] = Variable<String>(code);
    return map;
  }

  MatrixScanLinesCompanion toCompanion(bool nullToAbsent) {
    return MatrixScanLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      sortIndex: Value(sortIndex),
      code: Value(code),
    );
  }

  factory MatrixScanLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatrixScanLine(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'code': serializer.toJson<String>(code),
    };
  }

  MatrixScanLine copyWith(
          {int? id, int? sessionId, int? sortIndex, String? code}) =>
      MatrixScanLine(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        sortIndex: sortIndex ?? this.sortIndex,
        code: code ?? this.code,
      );
  MatrixScanLine copyWithCompanion(MatrixScanLinesCompanion data) {
    return MatrixScanLine(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatrixScanLine(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, sortIndex, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatrixScanLine &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.sortIndex == this.sortIndex &&
          other.code == this.code);
}

class MatrixScanLinesCompanion extends UpdateCompanion<MatrixScanLine> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> sortIndex;
  final Value<String> code;
  const MatrixScanLinesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.code = const Value.absent(),
  });
  MatrixScanLinesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int sortIndex,
    required String code,
  })  : sessionId = Value(sessionId),
        sortIndex = Value(sortIndex),
        code = Value(code);
  static Insertable<MatrixScanLine> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? sortIndex,
    Expression<String>? code,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (code != null) 'code': code,
    });
  }

  MatrixScanLinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? sortIndex,
      Value<String>? code}) {
    return MatrixScanLinesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sortIndex: sortIndex ?? this.sortIndex,
      code: code ?? this.code,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatrixScanLinesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryDaysTable historyDays = $HistoryDaysTable(this);
  late final $RouteSessionRowsTable routeSessionRows =
      $RouteSessionRowsTable(this);
  late final $MatrixScanLinesTable matrixScanLines =
      $MatrixScanLinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [historyDays, routeSessionRows, matrixScanLines];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('history_days',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('route_session_rows', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('route_session_rows',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('matrix_scan_lines', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$HistoryDaysTableCreateCompanionBuilder = HistoryDaysCompanion
    Function({
  Value<int> id,
  required int dayTimeMs,
  required int dayStateIndex,
});
typedef $$HistoryDaysTableUpdateCompanionBuilder = HistoryDaysCompanion
    Function({
  Value<int> id,
  Value<int> dayTimeMs,
  Value<int> dayStateIndex,
});

final class $$HistoryDaysTableReferences
    extends BaseReferences<_$AppDatabase, $HistoryDaysTable, HistoryDay> {
  $$HistoryDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RouteSessionRowsTable, List<RouteSessionRow>>
      _routeSessionRowsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.routeSessionRows,
              aliasName: $_aliasNameGenerator(
                  db.historyDays.id, db.routeSessionRows.dayId));

  $$RouteSessionRowsTableProcessedTableManager get routeSessionRowsRefs {
    final manager =
        $$RouteSessionRowsTableTableManager($_db, $_db.routeSessionRows)
            .filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_routeSessionRowsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HistoryDaysTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryDaysTable> {
  $$HistoryDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayTimeMs => $composableBuilder(
      column: $table.dayTimeMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayStateIndex => $composableBuilder(
      column: $table.dayStateIndex, builder: (column) => ColumnFilters(column));

  Expression<bool> routeSessionRowsRefs(
      Expression<bool> Function($$RouteSessionRowsTableFilterComposer f) f) {
    final $$RouteSessionRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routeSessionRows,
        getReferencedColumn: (t) => t.dayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RouteSessionRowsTableFilterComposer(
              $db: $db,
              $table: $db.routeSessionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HistoryDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryDaysTable> {
  $$HistoryDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayTimeMs => $composableBuilder(
      column: $table.dayTimeMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayStateIndex => $composableBuilder(
      column: $table.dayStateIndex,
      builder: (column) => ColumnOrderings(column));
}

class $$HistoryDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryDaysTable> {
  $$HistoryDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayTimeMs =>
      $composableBuilder(column: $table.dayTimeMs, builder: (column) => column);

  GeneratedColumn<int> get dayStateIndex => $composableBuilder(
      column: $table.dayStateIndex, builder: (column) => column);

  Expression<T> routeSessionRowsRefs<T extends Object>(
      Expression<T> Function($$RouteSessionRowsTableAnnotationComposer a) f) {
    final $$RouteSessionRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routeSessionRows,
        getReferencedColumn: (t) => t.dayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RouteSessionRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.routeSessionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HistoryDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryDaysTable,
    HistoryDay,
    $$HistoryDaysTableFilterComposer,
    $$HistoryDaysTableOrderingComposer,
    $$HistoryDaysTableAnnotationComposer,
    $$HistoryDaysTableCreateCompanionBuilder,
    $$HistoryDaysTableUpdateCompanionBuilder,
    (HistoryDay, $$HistoryDaysTableReferences),
    HistoryDay,
    PrefetchHooks Function({bool routeSessionRowsRefs})> {
  $$HistoryDaysTableTableManager(_$AppDatabase db, $HistoryDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dayTimeMs = const Value.absent(),
            Value<int> dayStateIndex = const Value.absent(),
          }) =>
              HistoryDaysCompanion(
            id: id,
            dayTimeMs: dayTimeMs,
            dayStateIndex: dayStateIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dayTimeMs,
            required int dayStateIndex,
          }) =>
              HistoryDaysCompanion.insert(
            id: id,
            dayTimeMs: dayTimeMs,
            dayStateIndex: dayStateIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$HistoryDaysTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({routeSessionRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (routeSessionRowsRefs) db.routeSessionRows
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routeSessionRowsRefs)
                    await $_getPrefetchedData<HistoryDay, $HistoryDaysTable,
                            RouteSessionRow>(
                        currentTable: table,
                        referencedTable: $$HistoryDaysTableReferences
                            ._routeSessionRowsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HistoryDaysTableReferences(db, table, p0)
                                .routeSessionRowsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.dayId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HistoryDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryDaysTable,
    HistoryDay,
    $$HistoryDaysTableFilterComposer,
    $$HistoryDaysTableOrderingComposer,
    $$HistoryDaysTableAnnotationComposer,
    $$HistoryDaysTableCreateCompanionBuilder,
    $$HistoryDaysTableUpdateCompanionBuilder,
    (HistoryDay, $$HistoryDaysTableReferences),
    HistoryDay,
    PrefetchHooks Function({bool routeSessionRowsRefs})>;
typedef $$RouteSessionRowsTableCreateCompanionBuilder
    = RouteSessionRowsCompanion Function({
  Value<int> id,
  required int dayId,
  required String ttId,
  required int sessionTimeMs,
  required int sessionStateIndex,
  Value<bool> isUploaded,
  required String positionJson,
  required int sessionOrder,
});
typedef $$RouteSessionRowsTableUpdateCompanionBuilder
    = RouteSessionRowsCompanion Function({
  Value<int> id,
  Value<int> dayId,
  Value<String> ttId,
  Value<int> sessionTimeMs,
  Value<int> sessionStateIndex,
  Value<bool> isUploaded,
  Value<String> positionJson,
  Value<int> sessionOrder,
});

final class $$RouteSessionRowsTableReferences extends BaseReferences<
    _$AppDatabase, $RouteSessionRowsTable, RouteSessionRow> {
  $$RouteSessionRowsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $HistoryDaysTable _dayIdTable(_$AppDatabase db) =>
      db.historyDays.createAlias(
          $_aliasNameGenerator(db.routeSessionRows.dayId, db.historyDays.id));

  $$HistoryDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$HistoryDaysTableTableManager($_db, $_db.historyDays)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MatrixScanLinesTable, List<MatrixScanLine>>
      _matrixScanLinesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.matrixScanLines,
              aliasName: $_aliasNameGenerator(
                  db.routeSessionRows.id, db.matrixScanLines.sessionId));

  $$MatrixScanLinesTableProcessedTableManager get matrixScanLinesRefs {
    final manager =
        $$MatrixScanLinesTableTableManager($_db, $_db.matrixScanLines)
            .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_matrixScanLinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RouteSessionRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteSessionRowsTable> {
  $$RouteSessionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ttId => $composableBuilder(
      column: $table.ttId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionTimeMs => $composableBuilder(
      column: $table.sessionTimeMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionStateIndex => $composableBuilder(
      column: $table.sessionStateIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get positionJson => $composableBuilder(
      column: $table.positionJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionOrder => $composableBuilder(
      column: $table.sessionOrder, builder: (column) => ColumnFilters(column));

  $$HistoryDaysTableFilterComposer get dayId {
    final $$HistoryDaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dayId,
        referencedTable: $db.historyDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryDaysTableFilterComposer(
              $db: $db,
              $table: $db.historyDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> matrixScanLinesRefs(
      Expression<bool> Function($$MatrixScanLinesTableFilterComposer f) f) {
    final $$MatrixScanLinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.matrixScanLines,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatrixScanLinesTableFilterComposer(
              $db: $db,
              $table: $db.matrixScanLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RouteSessionRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteSessionRowsTable> {
  $$RouteSessionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ttId => $composableBuilder(
      column: $table.ttId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionTimeMs => $composableBuilder(
      column: $table.sessionTimeMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionStateIndex => $composableBuilder(
      column: $table.sessionStateIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positionJson => $composableBuilder(
      column: $table.positionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionOrder => $composableBuilder(
      column: $table.sessionOrder,
      builder: (column) => ColumnOrderings(column));

  $$HistoryDaysTableOrderingComposer get dayId {
    final $$HistoryDaysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dayId,
        referencedTable: $db.historyDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryDaysTableOrderingComposer(
              $db: $db,
              $table: $db.historyDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RouteSessionRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteSessionRowsTable> {
  $$RouteSessionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ttId =>
      $composableBuilder(column: $table.ttId, builder: (column) => column);

  GeneratedColumn<int> get sessionTimeMs => $composableBuilder(
      column: $table.sessionTimeMs, builder: (column) => column);

  GeneratedColumn<int> get sessionStateIndex => $composableBuilder(
      column: $table.sessionStateIndex, builder: (column) => column);

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => column);

  GeneratedColumn<String> get positionJson => $composableBuilder(
      column: $table.positionJson, builder: (column) => column);

  GeneratedColumn<int> get sessionOrder => $composableBuilder(
      column: $table.sessionOrder, builder: (column) => column);

  $$HistoryDaysTableAnnotationComposer get dayId {
    final $$HistoryDaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dayId,
        referencedTable: $db.historyDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryDaysTableAnnotationComposer(
              $db: $db,
              $table: $db.historyDays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> matrixScanLinesRefs<T extends Object>(
      Expression<T> Function($$MatrixScanLinesTableAnnotationComposer a) f) {
    final $$MatrixScanLinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.matrixScanLines,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatrixScanLinesTableAnnotationComposer(
              $db: $db,
              $table: $db.matrixScanLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RouteSessionRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RouteSessionRowsTable,
    RouteSessionRow,
    $$RouteSessionRowsTableFilterComposer,
    $$RouteSessionRowsTableOrderingComposer,
    $$RouteSessionRowsTableAnnotationComposer,
    $$RouteSessionRowsTableCreateCompanionBuilder,
    $$RouteSessionRowsTableUpdateCompanionBuilder,
    (RouteSessionRow, $$RouteSessionRowsTableReferences),
    RouteSessionRow,
    PrefetchHooks Function({bool dayId, bool matrixScanLinesRefs})> {
  $$RouteSessionRowsTableTableManager(
      _$AppDatabase db, $RouteSessionRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteSessionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteSessionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteSessionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dayId = const Value.absent(),
            Value<String> ttId = const Value.absent(),
            Value<int> sessionTimeMs = const Value.absent(),
            Value<int> sessionStateIndex = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<String> positionJson = const Value.absent(),
            Value<int> sessionOrder = const Value.absent(),
          }) =>
              RouteSessionRowsCompanion(
            id: id,
            dayId: dayId,
            ttId: ttId,
            sessionTimeMs: sessionTimeMs,
            sessionStateIndex: sessionStateIndex,
            isUploaded: isUploaded,
            positionJson: positionJson,
            sessionOrder: sessionOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dayId,
            required String ttId,
            required int sessionTimeMs,
            required int sessionStateIndex,
            Value<bool> isUploaded = const Value.absent(),
            required String positionJson,
            required int sessionOrder,
          }) =>
              RouteSessionRowsCompanion.insert(
            id: id,
            dayId: dayId,
            ttId: ttId,
            sessionTimeMs: sessionTimeMs,
            sessionStateIndex: sessionStateIndex,
            isUploaded: isUploaded,
            positionJson: positionJson,
            sessionOrder: sessionOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RouteSessionRowsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {dayId = false, matrixScanLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (matrixScanLinesRefs) db.matrixScanLines
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (dayId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dayId,
                    referencedTable:
                        $$RouteSessionRowsTableReferences._dayIdTable(db),
                    referencedColumn:
                        $$RouteSessionRowsTableReferences._dayIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (matrixScanLinesRefs)
                    await $_getPrefetchedData<RouteSessionRow,
                            $RouteSessionRowsTable, MatrixScanLine>(
                        currentTable: table,
                        referencedTable: $$RouteSessionRowsTableReferences
                            ._matrixScanLinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RouteSessionRowsTableReferences(db, table, p0)
                                .matrixScanLinesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RouteSessionRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RouteSessionRowsTable,
    RouteSessionRow,
    $$RouteSessionRowsTableFilterComposer,
    $$RouteSessionRowsTableOrderingComposer,
    $$RouteSessionRowsTableAnnotationComposer,
    $$RouteSessionRowsTableCreateCompanionBuilder,
    $$RouteSessionRowsTableUpdateCompanionBuilder,
    (RouteSessionRow, $$RouteSessionRowsTableReferences),
    RouteSessionRow,
    PrefetchHooks Function({bool dayId, bool matrixScanLinesRefs})>;
typedef $$MatrixScanLinesTableCreateCompanionBuilder = MatrixScanLinesCompanion
    Function({
  Value<int> id,
  required int sessionId,
  required int sortIndex,
  required String code,
});
typedef $$MatrixScanLinesTableUpdateCompanionBuilder = MatrixScanLinesCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> sortIndex,
  Value<String> code,
});

final class $$MatrixScanLinesTableReferences extends BaseReferences<
    _$AppDatabase, $MatrixScanLinesTable, MatrixScanLine> {
  $$MatrixScanLinesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RouteSessionRowsTable _sessionIdTable(_$AppDatabase db) =>
      db.routeSessionRows.createAlias($_aliasNameGenerator(
          db.matrixScanLines.sessionId, db.routeSessionRows.id));

  $$RouteSessionRowsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager =
        $$RouteSessionRowsTableTableManager($_db, $_db.routeSessionRows)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MatrixScanLinesTableFilterComposer
    extends Composer<_$AppDatabase, $MatrixScanLinesTable> {
  $$MatrixScanLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  $$RouteSessionRowsTableFilterComposer get sessionId {
    final $$RouteSessionRowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.routeSessionRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RouteSessionRowsTableFilterComposer(
              $db: $db,
              $table: $db.routeSessionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixScanLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatrixScanLinesTable> {
  $$MatrixScanLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  $$RouteSessionRowsTableOrderingComposer get sessionId {
    final $$RouteSessionRowsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.routeSessionRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RouteSessionRowsTableOrderingComposer(
              $db: $db,
              $table: $db.routeSessionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixScanLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatrixScanLinesTable> {
  $$MatrixScanLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  $$RouteSessionRowsTableAnnotationComposer get sessionId {
    final $$RouteSessionRowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.routeSessionRows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RouteSessionRowsTableAnnotationComposer(
              $db: $db,
              $table: $db.routeSessionRows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixScanLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatrixScanLinesTable,
    MatrixScanLine,
    $$MatrixScanLinesTableFilterComposer,
    $$MatrixScanLinesTableOrderingComposer,
    $$MatrixScanLinesTableAnnotationComposer,
    $$MatrixScanLinesTableCreateCompanionBuilder,
    $$MatrixScanLinesTableUpdateCompanionBuilder,
    (MatrixScanLine, $$MatrixScanLinesTableReferences),
    MatrixScanLine,
    PrefetchHooks Function({bool sessionId})> {
  $$MatrixScanLinesTableTableManager(
      _$AppDatabase db, $MatrixScanLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatrixScanLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatrixScanLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatrixScanLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> sortIndex = const Value.absent(),
            Value<String> code = const Value.absent(),
          }) =>
              MatrixScanLinesCompanion(
            id: id,
            sessionId: sessionId,
            sortIndex: sortIndex,
            code: code,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int sortIndex,
            required String code,
          }) =>
              MatrixScanLinesCompanion.insert(
            id: id,
            sessionId: sessionId,
            sortIndex: sortIndex,
            code: code,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MatrixScanLinesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$MatrixScanLinesTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$MatrixScanLinesTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MatrixScanLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatrixScanLinesTable,
    MatrixScanLine,
    $$MatrixScanLinesTableFilterComposer,
    $$MatrixScanLinesTableOrderingComposer,
    $$MatrixScanLinesTableAnnotationComposer,
    $$MatrixScanLinesTableCreateCompanionBuilder,
    $$MatrixScanLinesTableUpdateCompanionBuilder,
    (MatrixScanLine, $$MatrixScanLinesTableReferences),
    MatrixScanLine,
    PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryDaysTableTableManager get historyDays =>
      $$HistoryDaysTableTableManager(_db, _db.historyDays);
  $$RouteSessionRowsTableTableManager get routeSessionRows =>
      $$RouteSessionRowsTableTableManager(_db, _db.routeSessionRows);
  $$MatrixScanLinesTableTableManager get matrixScanLines =>
      $$MatrixScanLinesTableTableManager(_db, _db.matrixScanLines);
}
