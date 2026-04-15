class PhoneModel {
  final int id;
  final String phone;
  final String? countryCode;
  final String? type; // 'whatsapp', 'phone', 'both'
  final bool isPrimary;
  final bool isActive;

  PhoneModel({
    required this.id, 
    required this.phone,
    this.countryCode,
    this.type,
    this.isPrimary = false,
    this.isActive = true,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      countryCode: json['country_code']?.toString(),
      type: json['type']?.toString(),
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
