import 'package:tdtime/domain/models/session.dart';

class HystorySessions {
  List<SessionScan> listSessions;
  DateTime time;
  bool isOut;

  // Конструктор
  HystorySessions({
    required this.listSessions,
    required this.time,
    this.isOut = false,
  });

  // Метод для инициализации
  factory HystorySessions.init() {
    return HystorySessions(
        listSessions: [], time: DateTime.now(), isOut: false);
  }

  // Метод для добавления сессии
  void addSession(SessionScan session) {
    listSessions.add(session);
  }

  // Метод для получения количества сессий
  int getSessionCount() {
    return listSessions.length;
  }

  // Метод для проверки статуса
  bool checkIsOut() {
    return isOut;
  }

  // Метод fromJson
  factory HystorySessions.fromJson(Map<String, dynamic> json) {
    return HystorySessions(
      listSessions: (json['listSessions'] as List)
          .map((session) => SessionScan.fromJson(session))
          .toList(),
      time: DateTime.parse(json['time']),
      isOut: json['isOut'] ?? false,
    );
  }

  // Метод toJson
  Map<String, dynamic> toJson() {
    return {
      'listSessions': listSessions.map((session) => session.toJson()).toList(),
      'time': time.toIso8601String(),
      'isOut': isOut,
    };
  }

  // Метод для форматирования даты
  String getDate() {
    return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year.toString().substring(2)}';
  }
}
