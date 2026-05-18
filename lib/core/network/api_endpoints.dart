/// � اسم الملف: api_endpoints.dart
/// 📝 الوصف: يحتوي هذا الملف على جميع روابط الـ API المستخدمة في التطبيق.
/// الهدف منه هو تجميع الروابط في مكان واحد لسهولة التعديل والإدارة.

class ApiEndpoints {
  /// 🌐 النطاق الأساسي (Domain) للسيرفر.
  /// يتم استخدامه كأساس لجميع الروابط الأخرى.
  // static String get domain => "http://10.0.2.2:8000";
  // static String get domain => "http://192.168.137.59 :8000";
  static String get domain => "https://qss-back-end.onrender.com";
  // static String get domain => "http://192.168.43.245:8000";
  // static String get domain => "http://localhost:8000/api";

  /// 🗄️ رابط التخزين (Storage).
  /// يستخدم للوصول إلى الملفات والصور المخزنة على السيرفر.
  static String get storageBaseUrl => "$domain/storage/";

  /// 🖼️ دالة مساعدة لمعالجة روابط الصور.
  /// تتأكد من إضافة الرابط الأساسي إذا كان المسار نسبياً.
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null') return '';
    
    // 🚀 إذا كان الرابط مدمجاً بشكل خاطئ من الباك إند بسبب دمج مسار الـ storage مع رابط خارجي كامل:
    // مثال: https://qss-back-end.onrender.com/storage/https://lh3.googleusercontent.com/...
    if (path.contains('/storage/http')) {
      final int index = path.indexOf('/storage/http');
      return path.substring(index + 9); // تخطي '/storage/' والبدء من 'http...'
    }

    if (path.startsWith('http') || path.startsWith('assets/')) return path;
    
    // تنظيف المسار من السلاش في البداية
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // 🚀 إذا كان المسار يبدأ بـ "storage/" بالفعل، نقوم بدمجه مع الدومين فقط لتجنب التكرار
    if (cleanPath.startsWith('storage/')) {
      return "$domain/$cleanPath";
    }
    
    return "$storageBaseUrl$cleanPath";
  }

  /// 🔗 الرابط الأساسي للـ API (Base URL).
  /// يحتوي على المنطق لتحديد الرابط المناسب بناءً على بيئة التشغيل.
  static String get baseUrl {
    // يمكن إضافة شروط هنا لتغيير الرابط إذا كان التطبيق يعمل على الويب أو المحاكي.
    // حالياً يتم إرجاع رابط الـ API المعتمد على النطاق الأساسي.
    return "$domain/api";
  }

  // ===========================================================================
  // 🔐 روابط المصادقة (Auth Endpoints)
  // ===========================================================================

  /// 🔑 رابط تسجيل الدخول.
  static String get login => "$baseUrl/login";

  /// 📝 رابط إنشاء حساب جديد.
  static String get register => "$baseUrl/register";

  /// 🚪 رابط تسجيل الخروج.
  static String get logout => "$baseUrl/logout";

  /// 🔐 رابط تغيير كلمة المرور.
  static String get changePassword => "$baseUrl/change-password";

  /// ✅ رابط تفعيل البريد الإلكتروني (OTP).
  static String get verifyEmail => "$baseUrl/verify-email-code";

  /// 🔄 رابط إعادة إرسال كود التفعيل.
  static String get resendVerificationCode =>
      "$baseUrl/resend-verification-code";

  /// 🌐 رابط تسجيل الدخول عبر جوجل.
  static String get googleLogin => "$baseUrl/auth/google/callback";

  // ===========================================================================
  // 🏠 روابط الصفحة الرئيسية (Home Endpoints)
  // ===========================================================================

  /// 📊 رابط جلب بيانات الصفحة الرئيسية العامة.
  static String get getHomeData => "$baseUrl/home";

  /// 🗂️ رابط جلب قائمة التصنيفات (Categories).
  static String get categories => "$baseUrl/categories";

  /// ⭐ رابط جلب الخدمات الشائعة (Popular Services).
  static String get popularServices => "$baseUrl/popular-services";

  /// ✨ رابط جلب الخدمات الموصى بها (Recommended Services).
  static String get recommendedServices => "$baseUrl/recommended-services";

  // ===========================================================================
  // 📢 روابط الإعلانات (Advertisements Endpoints)
  // ===========================================================================

  /// 📢 رابط جلب الإعلانات النشطة.
  static String get advertisements => "$baseUrl/advertisements";

  /// 👁️ رابط تتبع ظهور الإعلان.
  static String trackAdView(int id) => "$baseUrl/advertisements/$id/view";

  /// 🖱️ رابط تتبع النقر على الإعلان.
  static String trackAdClick(int id) => "$baseUrl/advertisements/$id/click";

  /// 🔍 رابط البحث المتقدم عن الخدمات.
  static String get searchServices => "$baseUrl/services/search";

  /// 📂 رابط جلب تفاصيل التصنيف (خدمات، تصنيفات فرعية، موصى بهم).
  /// [id] هو معرف التصنيف.
  // static String categoryDetails(int id) => "$baseUrl/categories/$id";
  static String categoryDetails(int id) => "$baseUrl/categories/$id";

  static String get beProvider => "$baseUrl/provider-requests";

  /// 👤 رابط ملف المستخدم (Profile) لجلب بيانات المزود (النبذة والأعمال).
  static String userProfile(int userId) => "$baseUrl/user-profile/$userId";

  /// 👤 رابط الملف الشخصي للمستخدم الحالي (My Profile).
  static String get myProfile => "$baseUrl/my-profile";

  /// 👤 رابط تحديث الملف الشخصي.
  static String updateProfile(int profileId) => "$baseUrl/profiles/$profileId";

  /// 📸 رابط جلب معرض الأعمال السابقة لمستخدم معين.
  static String previousWorks(int userId) =>
      "$baseUrl/previous-work?user_id=$userId";

  /// 📞 روابط أرقام الجوال.
  static String get profilePhones => "$baseUrl/profile-phones";
  static String profilePhone(int id) => "$baseUrl/profile-phones/$id";

  // ===========================================================================
  // 📝 روابط الطلبات (Request Endpoints)
  // ===========================================================================

  /// 🛠️ رابط إرسال طلب مخصص.
  static String get customRequest => "$baseUrl/requests/custom";

  /// 🤝 رابط طلب حضور (لقاء جسدي).
  static String get meetingRequest => "$baseUrl/requests/meeting";

  /// 📝 رابط إنشاء طلب خدمة عادي.
  static String get createRequest => "$baseUrl/requests";

  /// 📜 رابط جلب الطلبات (عام أو للمزود).
  static String get getOrders => "$baseUrl/requests";

  /// 👤 رابط جلب طلبات طالب الخدمة (Seeker Specific).
  static String get getSeekerOrders => "$baseUrl/requests/seeker";

  /// 🔍 رابط جلب تفاصيل طلب معين.
  static String getOrderDetail(String id) => "$baseUrl/requests/$id";

  /// 🔄 رابط تحديث حالة الطلب.
  static String updateStatus(String id) => "$baseUrl/requests/$id/status";

  /// 💰 رابط إضافة مبلغ مدفوع للطلب.
  static String addAmount(String id) =>
      "$baseUrl/requests/$id/addAmountToMoneyPaid";

  // ===========================================================================
  // ⭐ روابط المفضلة (Favorites Endpoints)
  // ===========================================================================

  /// 📜 رابط جلب قائمة المفضلة.
  static String get favorites => "$baseUrl/favorites";

  /// ❤️ رابط إضافة/حذف من المفضلة.
  static String get toggleFavorite => "$baseUrl/favorites/toggle";

  /// ⭐ رابط إضافة تقييم جديد.
  static String get reviews => "$baseUrl/reviews";

  /// 🚨 رابط إرسال شكوى جديدة.
  static String get requestComplaints => "$baseUrl/request-complaints";

  /// 💰 روابط الدفع والسداد.
  /// 💰 روابط شحن وإدارة النقاط.
  static String get pointsBalance => "$baseUrl/points/balance";
  static String get availablePointsPackages =>
      "$baseUrl/available-points-packages";
  static String get myPointsPackages => "$baseUrl/my-points-packages";
  static String get subscribePointsPackage =>
      "$baseUrl/subscribe-points-package";

  static String payByPoints(String id) => "$baseUrl/requests/$id/payByPoints";
  static String get requestBonds => "$baseUrl/request-bonds";

  /// 📜 رابط جلب السياسات (Privacy Policy / Terms).
  static String policy(String role) => "$baseUrl/policies/$role";

  /// 🚨 روابط شكاوى النظام.
  static String get systemComplaints => "$baseUrl/system-complaints";

  // ===========================================================================
  // 🔔 روابط الإشعارات (Notifications Endpoints)
  // ===========================================================================

  /// 🔑 رابط تخزين توكن الإشعارات (FCM Token).
  static String get storeToken => "$baseUrl/store-token";

  /// 📜 رابط جلب قائمة الإشعارات.
  static String get notifications => "$baseUrl/notifications";

  /// ✅ رابط تمييز إشعار معين كمقروء.
  static String markNotificationRead(String id) =>
      "$baseUrl/notifications/$id/read";

  /// ✅ رابط تمييز جميع الإشعارات كمقروءة.
  static String get markAllNotificationsRead =>
      "$baseUrl/notifications/read-all";
}
