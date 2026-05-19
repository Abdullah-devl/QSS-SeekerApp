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
  final bool seekerPolicy; // هل وافق على سياسة طالب الخدمة؟

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
    this.seekerPolicy = false,
  });

  /// 🔄 تحويل الـ JSON إلى كائن UserModel.
  /// [json]: خريطة البيانات القادمة من الـ API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    return UserModel(
      id: userJson['id'], // استخراج المعرف من داخل كائن user
      name: userJson['name'], // استخراج الاسم
      email: userJson['email'], // استخراج البريد
      role: userJson['role'], // استخراج الدور
      phone: userJson['phone'], // استخراج الهاتف
      address: userJson['address'], // استخراج العنوان
      token:
          json['token'] ??
          json['access_token'], // يدعم كلاً من login العادي و Google login
      isVerified:
          json['email_verified'] == true ||
          json['email_verified'] == 1 ||
          json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['user']?['email_verified_at'] != null,
      seekerPolicy:
          userJson['seeker_policy'] == 1 || userJson['seeker_policy'] == true,
    );
  }
}
