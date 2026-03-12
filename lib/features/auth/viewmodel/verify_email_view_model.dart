/// 📂 اسم الملف: verify_email_view_model.dart
/// 📝 الوصف: ViewModel لصفحة تفعيل البريد الإلكتروني.
/// يدير عملية إرسال كود التفعيل (OTP) والتحقق منه.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  VerifyEmailViewModel({required this.authRepository});

  // 📝 الـ Controllers
  // سنستخدم 6 كونترولرز منفصلة لكل خانة لسهولة التحكم في التنقل
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // 📝 FocusNodes للتحكم في التنقل بين الخانات
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  // ⏳ حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 📥 دالة لتجميع الكود من الـ Controllers
  String get _otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// ✅ دالة التحقق من صحة الكود وإرساله للسيرفر
  Future<void> verifyEmail(BuildContext context, String email) async {
    final otp = _otpCode;

    // 1. التحقق من أن الكود مكون من 6 أرقام
    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال الكود كاملاً')));
      return;
    }

    // 2. بدء التحميل
    _isLoading = true;
    notifyListeners();

    try {
      // 3. استدعاء الدالة من الـ Repository
      await authRepository.verifyEmail(email, otp);

      // 4. في حال النجاح، التوجيه للصفحة التالية (الرئيسية أو تسجيل الدخول)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل الحساب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        // التوجيه لصفحة تسجيل الدخول بعد التفعيل
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      // 5. معالجة الأخطاء
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ⏱️ المؤقت (Timer)
  Timer? _timer;
  int _start = 120; // 120 ثانية = دقيقتان
  bool _isTimerRunning = false;

  bool get isTimerRunning => _isTimerRunning;
  int get timerCurrentValue => _start;

  /// بدء المؤقت
  void startTimer() {
    _start = 120;
    _isTimerRunning = true;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        _isTimerRunning = false;
        timer.cancel();
        notifyListeners();
      } else {
        _start--;
        notifyListeners();
      }
    });
  }

  /// 🔄 دالة إعادة إرسال كود التفعيل
  Future<void> resendCode(BuildContext context, String email) async {
    // منع الضغط المتكرر أو إذا كان المؤقت يعمل
    if (_isLoading) return;

    if (_isTimerRunning) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى الانتظار ${_start} ثانية قبل إعادة الإرسال'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.resendVerificationCode(email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة إرسال كود التفعيل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // بدء المؤقت عند النجاح
      startTimer();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
