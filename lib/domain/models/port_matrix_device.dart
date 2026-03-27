class PortMatrixDevice {
  final String name;
  final String address;

  const PortMatrixDevice({
    required this.name,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
    };
  }

  factory PortMatrixDevice.fromJson(Map<String, dynamic> json) {
    return PortMatrixDevice(
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }
}
