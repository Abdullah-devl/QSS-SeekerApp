/// 📂 اسم الملف: category_model.dart
/// 📝 الوصف: نموذج بيانات التصنيفات (Categories).
/// يستخدم لعرض الأيقونات والأسماء في القائمة الأفقية بالشاشة الرئيسية.

class CategoryModel {
  final int id; // المعرف الفريد للتصنيف
  final String name; // اسم التصنيف (مثلاً: سباكة، كهرباء)
  final String iconPath; // مسار الأيقونة (رابط صورة أو مسار محلي)

  CategoryModel({required this.id, required this.name, required this.iconPath});

  /// 🔄 تحويل الـ JSON إلى كائن CategoryModel.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      // محاولة استخراج مسار الصورة من عدة مفاتيح محتملة
      iconPath:
          json['icon_path'] ??
          json['image_path'] ??
          json['image'] ??
          json['icon'] ??
          '',
    );
  }
}
