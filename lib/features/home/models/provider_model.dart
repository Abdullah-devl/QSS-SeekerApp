// /// 📂 اسم الملف: provider_model.dart
// /// 📝 الوصف: نموذج بيانات مقدم الخدمة (Provider).
// /// يستخدم لعرض "الموصى بهم" في صفحة تفاصيل التصنيف.
// class ProviderModel {
//   final int id;
//   final String name;
//   final String imageUrl;
//   final double rating;
//   final String specialty; // التخصص (مثلاً: سباك محترف)

//   ProviderModel({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.rating,
//     required this.specialty,
//   });

//   factory ProviderModel.fromJson(Map<String, dynamic> json) {
//     return ProviderModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       imageUrl: json['image_url'] ?? '',
//       rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
//       specialty: json['specialty'] ?? '',
//     );
//   }
// }
/// 📂 اسم الملف: provider_model.dart
/// 📝 الوصف: نموذج بيانات مقدم الخدمة (Provider).

class ProviderModel {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final String specialty;

  ProviderModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.specialty,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    // 1. استخراج مسار الصورة
    String rawImagePath = json['image_path'] ?? json['image_url'] ?? json['avatar'] ?? '';
    String finalImage = '';

    // 2. 🚀 حارس البوابة (الشرط الذكي)
    if (rawImagePath.toString().trim().isNotEmpty && rawImagePath.toString() != 'null') {
      finalImage = rawImagePath.startsWith('http') 
          ? rawImagePath 
          : 'http://127.0.0.1:8000/storage/$rawImagePath';
    }

    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: finalImage, // الرابط الآمن
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      specialty: json['specialty'] ?? '',
    );
  }
}