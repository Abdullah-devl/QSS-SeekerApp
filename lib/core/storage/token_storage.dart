import 'package:shared_preferences/shared_preferences.dart';

/// 📂 اسم الملف: token_storage.dart
/// 📝 الوصف: يحتوي هذا الملف على كلاس `TokenStorage` المسؤول عن إدارة التخزين المحلي للبيانات.
/// يعتمد على مكتبة `shared_preferences` لحفظ البيانات البسيطة مثل الـ Token ومعلومات المستخدم.

class TokenStorage {
  // 🔑 المفاتيح المستخدمة لحفظ واسترجاع البيانات من الذاكرة.
  static const String _tokenKey = 'auth_token';
  static const String _firstTimeKey = 'is_first_time';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // ===========================================================================
  // 🔐 إدارة الـ Token
  // ===========================================================================

  /// 💾 حفظ الـ Token في الذاكرة.
  /// يستخدم عند تسجيل الدخول أو إنشاء حساب جديد.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 📤 استرجاع الـ Token المخزن.
  /// يعود بـ null إذا لم يكن هناك token محفوظ.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 🗑️ حذف الـ Token من الذاكرة.
  /// يستخدم عند تسجيل الخروج.
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 🔎 التحقق مما إذا كان المستخدم مسجلاً للدخول.
  /// يعيد true إذا كان هناك token محفوظ وليس فارغاً.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ===========================================================================
  // 👤 إدارة بيانات المستخدم
  // ===========================================================================

  /// 💾 حفظ بيانات المستخدم الأساسية (الاسم والدور).
  Future<void> saveUserData({
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  /// 📤 استرجاع بيانات المستخدم (الاسم والدور) كـ Map.
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'role': prefs.getString(_userRoleKey),
    };
  }

  /// 🗑️ مسح جميع بيانات المستخدم (الاسم، الدور، والـ Token).
  /// يتم استدعاؤها عند تسجيل الخروج الكامل.
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    // ومسح التوكن أيضاً للتأكد
    await prefs.remove(_tokenKey);
    // ومسح وضع الزائر
    await prefs.remove('is_guest');
  }

  // ===========================================================================
  // 👤 وضع الزائر (Guest Mode)
  // ===========================================================================

  /// 💾 حفظ وضع الزائر.
  Future<void> saveGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', isGuest);
  }

  /// 🔎 التحقق مما إذا كان المستخدم زائراً.
  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_guest') ?? false;
  }

  // ===========================================================================
  // 🆕 إدارة حالة "أول مرة" (First Time Launch)
  // ===========================================================================

  /// 💾 تحديد ما إذا كانت هذه هي المرة الأولى لفتح التطبيق أم لا.
  /// (false) تعني أن المستخدم قد فتح التطبيق سابقاً.
  Future<void> setFirstTime(bool isFirst) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, isFirst);
  }

  /// 🔎 التحقق مما إذا كان التطبيق يفتح لأول مرة.
  /// الافتراضي هو true (إذا لم تكن القيمة مخزنة).
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }
}
