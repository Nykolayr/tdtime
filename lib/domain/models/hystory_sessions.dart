import 'package:tdtime/domain/models/session.dart';

class HystorySessions {
  List<SessionScan> listSessions;
  DateTime time;
  StateSession state;

  // Конструктор
  HystorySessions({
    required this.listSessions,
    required this.time,
    required this.state,
  });

  // Метод для инициализации
  factory HystorySessions.init() {
    return HystorySessions(
      listSessions: [],
      time: DateTime.now(),
      state: StateSession.create,
    );
  }

  // Метод для добавления сессии
  void addSession(SessionScan session) {
    listSessions.add(session);
  }

  // Метод для получения количества сессий
  int getSessionCount() {
    return listSessions.length;
  }

  // Метод fromJson
  factory HystorySessions.fromJson(Map<String, dynamic> json) {
    return HystorySessions(
      listSessions: (json['listSessions'] as List)
          .map((session) => SessionScan.fromJson(session))
          .toList(),
      time: DateTime.parse(json['time']),
      state: StateSession.values.firstWhere((e) => e.name == json['state'],
          orElse: () => StateSession.create),
    );
  }

  // Метод toJson
  Map<String, dynamic> toJson() {
    return {
      'listSessions': listSessions.map((session) => session.toJson()).toList(),
      'time': time.toIso8601String(),
      'state': state.name,
    };
  }

  // Метод для форматирования даты
  String getDate() {
    return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year.toString().substring(2)}';
  }

  String getFormattedDateTime() {
    return '${time.day.toString().padLeft(2, '0')}_'
        '${time.month.toString().padLeft(2, '0')}_'
        '${time.year}_'
        '${time.hour.toString().padLeft(2, '0')}_'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

enum StateSession {
  create,
  open,
  inwork,
  inOut,
  close;

  String get title => switch (this) {
        StateSession.create => 'Создана',
        StateSession.open => 'Открыта',
        StateSession.inwork => 'В работе',
        StateSession.inOut => 'Ожидает отправки',
        StateSession.close => 'Закрыта'
      };
}
