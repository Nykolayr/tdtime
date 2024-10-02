/// Класс, представляющий пользователя

class User {
  String id;
  String family; // имя
  String name; // пароль
  String patron; // почта

  User({
    required this.id,
    required this.family,
    required this.patron,
    required this.name,
  });
  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      family: data['family'] ?? '',
      name: data['name'] ?? '',
      patron: data['patron'] ?? '',
    );
  }

  factory User.initial() {
    return User(
      id: '',
      family: '',
      name: '',
      patron: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family': family,
      'name': name,
      'patron': patron,
    };
  }
}
