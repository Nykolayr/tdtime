import 'package:geolocator/geolocator.dart';

/// класс сессии для сканироваиня
class SessionScan {
  String id;
  Position position;
  DateTime time;
  List<String> dataMatrix;

  // Конструктор
  SessionScan(
      {required this.id,
      required this.position,
      required this.time,
      required this.dataMatrix});

  // Метод fromJson
  factory SessionScan.fromJson(Map<String, dynamic> json) {
    return SessionScan(
      id: json['id'],
      position: Position.fromMap(json['coordinates']),
      time: DateTime.parse(json['time']),
      dataMatrix: List<String>.from(json['DataMatrix']),
    );
  }

  // Метод toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coordinates': position.toJson(),
      'time': time.toIso8601String(),
      'DataMatrix': dataMatrix,
    };
  }

  factory SessionScan.init() {
    return SessionScan(
      id: '', // Укажите значение по умолчанию
      position: Position(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        altitude: 0,
        speed: 0,
        heading: 0,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        speedAccuracy: 0,
      ),
      time: DateTime.now(),
      dataMatrix: [],
    );
  }

  // Метод для форматирования даты
  String getDate() {
    return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year.toString().substring(2)}';
  }
}
