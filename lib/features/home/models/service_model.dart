/// 📂 اسم الملف: service_model.dart
/// 📝 الوصف: نموذج بيانات الخدمة (Service).
/// يستخدم لعرض تفاصيل الخدمة مثل العنوان، السعر، والتقييم في قائمة "الأكثر طلباً".

class ServiceModel {
  final int id; // معرف الخدمة
  final String title; // عنوان الخدمة
  final String description; // وصف مختصر
  final double price; // السعر التقريبي
  final double rating; // التقييم (من 5)
  final String imageUrl; // رابط صورة الخدمة
  final String providerName; // اسم مقدم الخدمة

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.providerName,
  });

  /// 🔄 تحويل بيانات JSON إلى كائن ServiceModel.
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // التأكد من تحويل الأرقام إلى Double حتى لو جاءت كـ Int
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      providerName: json['provider_name'] ?? '',
    );
  }
}
