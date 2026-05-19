/// 📂 اسم الملف: forgot_password_view_model.dart
/// 📝 الوصف: ViewModel لصفحة استعادة كلمة المرور.
/// يدير الخطوات الثلاث لعملية استعادة الحساب عبر الـ OTP.

import 'package:flutter/material.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  ForgotPasswordViewModel({required this.authRepository});

  // 📝 الكونترولرز للحقول
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // ⏳ حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 🗺️ الخطوة الحالية (0: البريد الإلكتروني، 1: رمز OTP، 2: كلمة المرور الجديدة)
  int _currentStep = 0;
  int get currentStep => _currentStep;

  /// 🔄 الانتقال لخطوة معينة
  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  /// 📌 الخطوة الأولى: إرسال رمز OTP للبريد الإلكتروني
  Future<void> sendResetOtp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();

    if (email.isEmpty) {
      QSAlerts.showWarning(context, l10n.pleaseFillFields);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.forgotPassword(email);
      if (context.mounted) {
        QSAlerts.showSuccess(context, l10n.resetOtpSentSuccess);
        _currentStep = 1; // الانتقال لخطوة كود الـ OTP
      }
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        QSAlerts.showError(context, context.tr(msg));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📌 الخطوة الثانية: التحقق من صحة كود الـ OTP
  Future<void> verifyResetOtp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (code.isEmpty) {
      QSAlerts.showWarning(context, l10n.pleaseFillFields);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.verifyResetCode(email, code);
      if (context.mounted) {
        QSAlerts.showSuccess(context, l10n.resetCodeVerifiedSuccess);
        _currentStep = 2; // الانتقال لخطوة تعيين كلمة المرور الجديدة
      }
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        QSAlerts.showError(context, context.tr(msg));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📌 الخطوة الثالثة: تعيين كلمة المرور الجديدة
  Future<void> resetNewPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      QSAlerts.showWarning(context, l10n.pleaseFillFields);
      return;
    }

    if (password != confirmPassword) {
      QSAlerts.showWarning(context, l10n.passwordsDoNotMatch);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.resetPassword(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: confirmPassword,
      );
      if (context.mounted) {
        await QSAlerts.showSuccess(context, l10n.resetPasswordSuccess);
        if (context.mounted) {
          // إعادة تصفير الحقول والخطوة
          emailController.clear();
          codeController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          _currentStep = 0;
          Navigator.pop(context); // الرجوع لشاشة تسجيل الدخول
        }
      }
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        QSAlerts.showError(context, context.tr(msg));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗑️ تنظيف الموارد
  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
