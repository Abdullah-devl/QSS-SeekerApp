/// 📂 اسم الملف: register_view_model.dart
/// 📝 الوصف: ViewModel لصفحة إنشاء الحساب.
/// يدير عمليات التحقق من البيانات، الموافقة على الشروط، والتواصل مع الـ Repository لإنشاء الحساب.

import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  RegisterViewModel({required this.authRepository});

  // 📝 الكونترولرز للحقول
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ⏳ حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ حالة الموافقة على الشروط والأحكام
  bool _isAgreed = false;
  bool get isAgreed => _isAgreed;

  /// 🔄 دالة لتغيير حالة الموافقة (Checkbox).
  void toggleAgreement(bool? value) {
    _isAgreed = value ?? false;
    notifyListeners(); // تحديث الواجهة لتفعيل/تعطيل زر التسجيل
  }

  Future<void> openTermsPage(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.privacyPolicy,
      arguments: {'fromRegister': true},
    );
    if (result == true) {
      toggleAgreement(true);
    }
  }

  /// 📝 دالة تنفيذ إنشاء الحساب.
  Future<void> register(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // 1. التحقق من أن الحقول غير فارغة
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      QSAlerts.showWarning(context, l10n.pleaseFillFields);
      return;
    }

    // 2. التحقق من تطابق كلمة المرور
    if (passwordController.text != confirmPasswordController.text) {
      QSAlerts.showWarning(context, l10n.passwordsDoNotMatch);
      return;
    }

    // 3. التحقق من الموافقة على الشروط
    if (!_isAgreed) {
      QSAlerts.showWarning(context, l10n.agreeToTermsRequired);
      return;
    }

    // 4. بدء التحميل
    _isLoading = true;
    notifyListeners();

    try {
      // 5. استدعاء الدالة من الـ Repository
      await authRepository.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
        isAgreed: _isAgreed,
      );

      // 6. في حال النجاح، التوجيه لصفحة التحقق من الإيميل (OTP)
      if (context.mounted) {
        await QSAlerts.showSuccess(
          context,
          l10n.accountCreatedSuccess,
        );
        
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.verifyEmail,
            arguments: emailController.text.trim(),
          );
        }
      }
    } catch (e) {
      // 7. معالجة الأخطاء وعرضها
      if (context.mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        QSAlerts.showError(context, context.tr(msg));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗑️ تنظيف الموارد.
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
