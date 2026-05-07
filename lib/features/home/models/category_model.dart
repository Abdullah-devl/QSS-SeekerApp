// /// 📂 اسم الملف: category_model.dart
// /// 📝 الوصف: نموذج بيانات التصنيفات (Categories).
// /// يستخدم لعرض الأيقونات والأسماء في القائمة الأفقية بالشاشة الرئيسية.

// class CategoryModel {
//   final int id; // المعرف الفريد للتصنيف
//   final String name; // اسم التصنيف (مثلاً: سباكة، كهرباء)
//   final String iconPath; // مسار الأيقونة (رابط صورة أو مسار محلي)

//   CategoryModel({required this.id, required this.name, required this.iconPath});

//   //                   /// 🔄 تحويل الـ JSON إلى كائن CategoryModel.
//   // factory CategoryModel.fromJson(Map<String, dynamic> json) {
//   //   return CategoryModel(
//   //     id: json['id'] ?? 0,
//   //     name: json['name'] ?? '',
//   //     // محاولة استخراج مسار الصورة من عدة مفاتيح محتملة
//   //     iconPath:
//   //         json['icon_path'] ??
//   //         json['image_path'] ??
//   //         json['image'] ??
//   //         json['icon'] ??
//   //         '',
//   //   );
//   // }

// }
/// 📂 اسم الملف: category_model.dart
/// 📝 الوصف: نموذج بيانات التصنيفات (Categories).
import 'dart:developer' as developer;
import 'package:seeker/core/network/api_endpoints.dart';

class CategoryModel {
  final int id;
  final String name;
  final String iconPath;

  CategoryModel({required this.id, required this.name, required this.iconPath});

  /// 🔄 تحويل الـ JSON إلى كائن CategoryModel بأمان تام
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // 1. محاولة استخراج مسار الصورة من عدة مفاتيح محتملة
    String rawImagePath =
        json['image_url'] ??
        json['icon_path'] ??
        json['image_path'] ??
        json['image'] ??
        json['icon'] ??
        '';

    String finalImage = '';

    // 2. 🚀 حارس البوابة (الشرط الذكي) لمنع الروابط المكسورة
    finalImage = ApiEndpoints.getImageUrl(rawImagePath);

    // 3. طباعة للتأكد من الرابط النهائي (Debug)
    developer.log(
      '📁 Category URL for [${json['name']}]: $finalImage',
      name: 'CategoryModel',
    );

    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      iconPath: finalImage, // الآن سيمرر الرابط كاملاً، أو يتركه فارغاً ''
    );
  }
}
