/// Класс, представляющий пользователя
class User {
  String id;
  String family; // фамилия
  String name; // имя
  String patron; // отчество
  String filePath; // путь к файлу

  User({
    required this.id,
    required this.family,
    required this.patron,
    required this.name,
    required this.filePath,
  });
  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      family: data['family'] ?? '',
      name: data['name'] ?? '',
      patron: data['patron'] ?? '',
      filePath: data['filePath'] ?? '${data['id']}_routers.json',
    );
  }

  factory User.initial() {
    return User(
      id: '',
      family: '',
      name: '',
      patron: '',
      filePath: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family': family,
      'name': name,
      'patron': patron,
      'filePath': filePath,
    };
  }
}
