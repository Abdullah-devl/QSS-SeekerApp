import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';

/// 📂 اسم الملف: splash_view.dart
/// 📝 الوصف: شاشة البداية (Splash Screen).
/// تظهر عند فتح التطبيق وتقوم بالتحقق من حالة المستخدم (جديد، مسجل دخول، أو زائر) وتوجيهه للشاشة المناسبة.

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate(); // بدء عملية التحقق عند بناء الصفحة
  }

  /// 🔄 دالة للتحقق من حالة المصادقة والتوجيه.
  Future<void> _checkAuthAndNavigate() async {
    // ⏳ انتظار 3 ثواني لإظهار الشعار (تجربة مستخدم أفضل)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final tokenStorage = context.read<TokenStorage>();
      final isFirstTime = await tokenStorage.isFirstTime();
      final hasToken = await tokenStorage.hasToken();
      final isGuest = await tokenStorage.isGuest();

      if (!mounted) return;

      if (isFirstTime) {
        // 1️⃣ المستخدم يفتح التطبيق لأول مرة -> نذهب لصفحة الترحيب (Welcome)
        await tokenStorage.setFirstTime(
          false,
        ); // نحدث الحالة لكي لا تظهر مرة أخرى
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      } else if (hasToken || isGuest) {
        // 2️⃣ المستخدم مسجل دخول سابقاً (لديه توكن) أو زائر -> نذهب للرئيسية (Home)
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // 3️⃣ مستخدم عاد للتطبيق ولكنه غير مسجل دخول -> نذهب لتسجيل الدخول (Login)
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      if (!mounted) return;
      // ⚠️ في حال حدوث أي خطأ غير متوقع، نوجه المستخدم لتسجيل الدخول كإجراء احتياطي
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم qsColors للوصول للألوان المتوافقة مع الثيم (فاتح/داكن)
    return Scaffold(
      backgroundColor: context.qsColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق (Container دائري مع أيقونة)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.qsColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.home_repair_service, // أيقونة تعبيرية عن الخدمات
                size: 80,
                color: context.qsColors.background,
              ),
            ),
            const SizedBox(height: 20),

            // اسم التطبيق
            Text(
              'QuickServe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.qsColors.text,
              ),
            ),
            const SizedBox(height: 20),

            // مؤشر تحميل بسيط
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
