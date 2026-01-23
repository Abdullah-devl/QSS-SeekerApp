/// 📂 اسم الملف: app_routes.dart
/// 📝 الوصف: يحتوي هذا الملف على جميع مسارات (Routes) التطبيق.
/// الهدف منه هو استخدام ثوابت نصية (Strings) للإشارة إلى الصفحات بدلاً من كتابة المسار يدوياً في كل مكان.
class AppRoutes {
  /// 🔑 مسار صفحة تسجيل الدخول.
  static const String login = '/login';

  /// 📝 مسار صفحة إنشاء حساب جديد.
  static const String register = '/register';

  /// 🏠 مسار الصفحة الرئيسية.
  static const String home = '/home';

  /// 📜 مسار صفحة الشروط والأحكام.
  static const String terms = '/terms';

  /// 👋 مسار صفحة الترحيب (Welcome Screen).
  static const String welcome = '/welcome';

  /// 📧 مسار صفحة التحقق من البريد الإلكتروني (OTP).
  static const String verifyEmail = '/verify_email';

  /// ⚙️ مسار صفحة الإعدادات.
  static const String settings = '/settings';
}
