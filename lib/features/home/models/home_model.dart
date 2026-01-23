/// 📂 اسم الملف: home_model.dart
/// 📝 الوصف: نموذج عام لبيانات الصفحة الرئيسية.
/// هذا الملف يمثل شكل البيانات التي تأتي من الـ API وكيفية تحويلها إلى كود.
/// يجب أن تطابق المتغيرات هنا مع مفاتيح الـ JSON القادمة من السيرفر.

class HomeModel {
  // مثال: إذا كان الـ API يرجع { "id": 1, "title": "hello" }
  final int? id;
  final String? title;

  HomeModel({this.id, this.title});

  /// 🔄 دالة لتحويل الـ JSON القادم من السيرفر إلى هذا الكلاس.
  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(id: json['id'], title: json['title']);
  }

  /// 📤 دالة لتحويل هذا الكلاس إلى JSON (لإرساله للسيرفر مثلاً).
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
