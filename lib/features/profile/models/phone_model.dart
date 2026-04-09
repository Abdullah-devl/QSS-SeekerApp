class PhoneModel {
  final int id;
  final String phone;

  PhoneModel({required this.id, required this.phone});

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
    );
  }
}
