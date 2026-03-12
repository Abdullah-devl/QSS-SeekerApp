/// 📂 اسم الملف: user_model.dart
/// 📝 الوصف: نموذج البيانات (Data Model) الخاص بالمستخدم.
/// يستخدم لتحويل بيانات الـ JSON القادمة من السيرفر إلى كائن (Object) يمكن التعامل معه في الكود.

class UserModel {
  final int id; // المعرف الفريد للمستخدم
  final String name; // اسم المستخدم
  final String email; // البريد الإلكتروني
  final String? token; // التوكن الخاص بالمصادقة (يأتي عند تسجيل الدخول/التسجيل)
  final String? role; // نوع المستخدم (مثلاً: client أو provider)
  final String? phone; // رقم الهاتف
  final String? address; // العنوان
  final bool isVerified; // هل الحساب مفعل؟

  /// 🏗️ البناء (Constructor)
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.role,
    this.phone,
    this.address,
    this.isVerified = false,
  });

  /// 🔄 تحويل الـ JSON إلى كائن UserModel.
  /// [json]: خريطة البيانات القادمة من الـ API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'], // استخراج المعرف من داخل كائن user
      name: json['user']['name'], // استخراج الاسم
      email: json['user']['email'], // استخراج البريد
      role: json['user']['role'], // استخراج الدور
      phone: json['user']['phone'], // استخراج الهاتف
      address: json['user']['address'], // استخراج العنوان
      token: json['token'], // استخراج التوكن (قد يكون خارج كائن user)
      isVerified:
          // json['user']['email_verified_at'] !=
          // null, // التحقق مما إذا كان التاريخ موجوداً
          json['email_verified'] ?? false,
    );
  }
}
