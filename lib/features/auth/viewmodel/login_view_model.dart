import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/core/services/notification_service.dart';
import 'package:seeker/core/storage/token_storage.dart';
import '../repositories/auth_repository.dart';

/// 📂 اسم الملف: login_view_model.dart
/// 📝 الوصف: ViewModel لصفحة تسجيل الدخول.
/// المسؤول عن:
/// 1. إدارة حالة الصفحة (تحميل، خطأ، نجاح).
/// 2. التحقق من المدخلات (validation).
/// 3. التواصل مع `AuthRepository` لتنفيذ عملية الدخول.

class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  LoginViewModel({required this.authRepository, required this.tokenStorage});

  // 📝 الكونترولرز للتحكم في الحقول النصية
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ⏳ حالة التحميل (لإظهار مؤشر الانتظار عند الاتصال بالسيرفر)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 🔓 دالة تنفيذ تسجيل الدخول.
  Future<void> login(BuildContext context) async {
    // 1. التحقق البسيط من أن الحقول ليست فارغة
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      QSAlerts.showWarning(context, 'الرجاء تعبئة جميع الحقول');
      return;
    }

    // 2. تفعيل حالة التحميل وتحديث الواجهة
    _isLoading = true;
    notifyListeners();

    try {
      // 3. استدعاء الدالة من الـ Repository
      final user = await authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 4. التحقق من حالة التفعيل
      if (context.mounted) {
        if (user.isVerified) {
          // 🔔 إرسال توكن الإشعارات للسيرفر فور تسجيل الدخول
          NotificationService().updateTokenToServer();

          // ✅ الحساب مفعل -> التحقق من الموافقة على السياسة (سيرفر أو محلي)
          bool isAgreedLocally = await tokenStorage.isPolicyAgreed();
          
          if (user.seekerPolicy || isAgreedLocally) {
            // تفريغ الستاك وجعل الرئيسية هي الجذر
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else {
            // غير موافق -> التوجه لصفحة السياسة
            Navigator.pushReplacementNamed(context, AppRoutes.privacyPolicy);
          }
        } else {
          // ⚠️ الحساب غير مفعل -> الذهاب لصفحة التفعيل
          QSAlerts.showWarning(context, 'الرجاء تفعيل حسابك أولاً');
          Navigator.pushNamed(
            context,
            AppRoutes.verifyEmail,
            arguments: user.email,
          );
        }
      }
    } catch (e) {
      // 5. في حال الفشل، عرض رسالة الخطأ للمستخدم
      if (context.mounted) {
        QSAlerts.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      // 6. إيقاف حالة التحميل في جميع الأحوال (نجاح أو فشل)
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🌐 دالة تسجيل الدخول عبر جوجل.
  Future<void> loginWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await authRepository.loginWithGoogle();

      if (context.mounted) {
        if (user.isVerified) {
          // 🔔 تحديث توكن الإشعارات
          NotificationService().updateTokenToServer();

          // ✅ التحقق من السياسة
          bool isAgreedLocally = await tokenStorage.isPolicyAgreed();
          
          if (user.seekerPolicy || isAgreedLocally) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.privacyPolicy);
          }
        } else {
          QSAlerts.showWarning(context, 'الرجاء تفعيل حسابك أولاً');
          Navigator.pushNamed(context, AppRoutes.verifyEmail, arguments: user.email);
        }
      }
    } catch (e) {
      if (context.mounted) {
        // إذا ألغى المستخدم الدخول فلا نعرض رسالة خطأ، عدا ذلك نعرضها
        if (!e.toString().contains('إلغاء')) {
          QSAlerts.showError(context, e.toString().replaceAll('Exception: ', ''));
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 👤 دالة الدخول كزائر.
  Future<void> loginAsGuest(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.loginAsGuest();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        QSAlerts.showError(context, 'حدث خطأ: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗑️ تنظيف الموارد عند إغلاق الصفحة.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
