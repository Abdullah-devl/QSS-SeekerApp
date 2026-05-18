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
  static const String _userPhoneKey = 'user_phone';
  static const String _userAddressKey = 'user_address';
  static const String _userIdKey = 'user_id';
  static const String _languageKey = 'app_language';
  static const String _policyAgreedKey = 'is_policy_agreed';

  // ===========================================================================
  // 📜 إدارة الموافقة على السياسة
  // ===========================================================================

  /// 💾 حفظ حالة الموافقة على السياسة
  Future<void> savePolicyAgreement(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_policyAgreedKey, agreed);
  }

  /// 📤 استرجاع حالة الموافقة على السياسة
  Future<bool> isPolicyAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_policyAgreedKey) ?? false;
  }

  // ===========================================================================
  // 🌍 إدارة اللغة
  // ===========================================================================

  /// 💾 حفظ لغة التطبيق المختارة
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// 📤 استرجاع اللغة المحفوظة
  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

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
    required int id,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
    if (address != null) await prefs.setString(_userAddressKey, address);
  }

  /// 📤 استرجاع بيانات المستخدم (الاسم والدور) كـ Map.
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'role': prefs.getString(_userRoleKey),
      'phone': prefs.getString(_userPhoneKey),
      'address': prefs.getString(_userAddressKey),
    };
  }

  /// 📤 استرجاع دور المستخدم فقط
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// 🗑️ مسح جميع بيانات المستخدم (الاسم، الدور، والـ Token).
  /// يتم استدعاؤها عند تسجيل الخروج الكامل.
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userAddressKey);
    await prefs.remove(_userIdKey);
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

  // ===========================================================================
  // 🔔 إدارة الإشعارات (Notifications Settings)
  // ===========================================================================

  /// 💾 حفظ حالة تفعيل الإشعارات
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// 📤 استرجاع حالة تفعيل الإشعارات
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
}
