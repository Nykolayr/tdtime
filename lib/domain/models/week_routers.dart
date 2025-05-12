import 'package:tdtime/domain/models/market_center.dart';

class WeekRouters {
  final WeekDay day;
  final List<String> marketCenterIds;
  final List<MarketCenter> marketCenters;

  WeekRouters(
      {required this.day,
      required this.marketCenterIds,
      required this.marketCenters});

  factory WeekRouters.fromJson(Map<String, dynamic> json) {
    return WeekRouters(
      day: WeekDay.values.firstWhere((e) => e.name == json['day']),
      marketCenterIds:
          (json['marketCenterIds'] as List).map((id) => id.toString()).toList(),
      marketCenters: json['marketCenters'] == null
          ? []
          : (json['marketCenters'] as List)
              .map((mc) => MarketCenter.fromJson(mc))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.name,
      'marketCenterIds': marketCenterIds,
      'marketCenters': marketCenters.map((mc) => mc.toJson()).toList(),
    };
  }

  factory WeekRouters.init() {
    return WeekRouters(
      day: WeekDay.monday,
      marketCenterIds: [],
      marketCenters: [],
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
