class WeekRouters {
  final WeekDay day;
  final List<String> marketCenterIds;

  WeekRouters({required this.day, required this.marketCenterIds});

  factory WeekRouters.fromJson(Map<String, dynamic> json) {
    return WeekRouters(
      day: WeekDay.values.firstWhere((e) => e.name == json['day']),
      marketCenterIds: json['marketCenterIds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.name,
      'marketCenterIds': marketCenterIds,
    };
  }

  factory WeekRouters.init() {
    return WeekRouters(
      day: WeekDay.monday,
      marketCenterIds: [],
    );
  }
}

enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get title => switch (this) {
        WeekDay.monday => 'Понедельник',
        WeekDay.tuesday => 'Вторник',
        WeekDay.wednesday => 'Среда',
        WeekDay.thursday => 'Четверг',
        WeekDay.friday => 'Пятница',
        WeekDay.saturday => 'Суббота',
        WeekDay.sunday => 'Воскресенье',
      };
}
