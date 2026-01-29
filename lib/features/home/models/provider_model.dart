/// 📂 اسم الملف: provider_model.dart
/// 📝 الوصف: نموذج بيانات مقدم الخدمة (Provider).
/// يستخدم لعرض "الموصى بهم" في صفحة تفاصيل التصنيف.
class ProviderModel {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final String specialty; // التخصص (مثلاً: سباك محترف)

  ProviderModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.specialty,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      specialty: json['specialty'] ?? '',
    );
  }
}
