/// 📂 اسم الملف: register_view_model.dart
/// 📝 الوصف: ViewModel لصفحة إنشاء الحساب.
/// يدير عمليات التحقق من البيانات، الموافقة على الشروط، والتواصل مع الـ Repository لإنشاء الحساب.

import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';
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

  /// 📜 دالة لفتح صفحة الشروط والأحكام.
  /// إذا وافق المستخدم في تلك الصفحة، نعود ونفعّل الـ Checkbox تلقائياً.
  Future<void> openTermsPage(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/terms');
    if (result == true) {
      toggleAgreement(true);
    }
  }

  /// 📝 دالة تنفيذ إنشاء الحساب.
  Future<void> register(BuildContext context) async {
    // 1. التحقق من أن الحقول غير فارغة
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول')));
      return;
    }

    // 2. التحقق من تطابق كلمة المرور
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمة المرور غير متطابقة')));
      return;
    }

    // 3. التحقق من الموافقة على الشروط
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
      );
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
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyEmail,
          arguments: emailController.text.trim(),
        );
      }
    } catch (e) {
      // 7. معالجة الأخطاء وعرضها
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '$e')),
            backgroundColor: Colors.red,
          ),
        );
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
