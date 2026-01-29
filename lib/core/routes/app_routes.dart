/// 📂 اسم الملف: app_routes.dart
/// 📝 الوصف: يحتوي هذا الملف على جميع مسارات (Routes) التطبيق.
/// الهدف منه هو استخدام ثوابت نصية (Strings) للإشارة إلى الصفحات بدلاً من كتابة المسار يدوياً في كل مكان.
class AppRoutes {
  /// 🔑 مسار صفحة تسجيل الدخول.
  static const String login = 'login';

  /// 📝 مسار صفحة إنشاء حساب جديد.
  static const String register = 'register';

  /// 🏠 مسار الصفحة الرئيسية.
  static const String home = 'الرئيسية';

  /// 📜 مسار صفحة الشروط والأحكام.
  static const String terms = 'terms';

  /// 👋 مسار صفحة الترحيب (Welcome Screen).
  static const String welcome = 'welcome';

  /// 📧 مسار صفحة التحقق من البريد الإلكتروني (OTP).
  static const String verifyEmail = 'verify_email';

  /// ⚙️ مسار صفحة الإعدادات.
  static const String settings = 'الاعدادات';

  /// 📂 مسار صفحة تفاصيل التصنيف.
  static const String categoryDetails = 'category_details';

  /// 👤 مسار صفحة الملف الشخصي.
  static const String profile = 'profile';
  //ميار االضافي
  /// ❤️ مسار صفحة المفضلة.
  static const String favorites = 'المفضلة';

  /// 🛒 مسار صفحة الطلبات
  static const String orders = 'الطلبات';

  /// 🛠️ مسار صفحة طلب مزود خدمة
  static const String beProvider = 'be_provider';
}
