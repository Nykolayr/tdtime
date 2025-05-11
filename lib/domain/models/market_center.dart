/// класс для торгового центра
class MarketCenter {
  String id;
  String name;
  String address;
  String phone;

  MarketCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory MarketCenter.fromJson(Map<String, dynamic> json) {
    return MarketCenter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  factory MarketCenter.init() {
    return MarketCenter(
      id: '',
      name: '',
      address: '',
      phone: '',
    );
  }
}
