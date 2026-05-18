/// 📂 اسم الملف: forgot_password_view.dart
/// 📝 الوصف: واجهة المستخدم لاستعادة كلمة المرور (Forgot Password).
/// تحتوي على 3 خطوات: طلب كود التحقق، التحقق من الكود، وإعادة تعيين كلمة المرور الجديدة.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/core/widgets/custom_text_field.dart';
import 'package:seeker/features/auth/viewmodel/forgot_password_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  Widget _buildLabel(BuildContext context, String text) {
    final colors = context.qsColors;
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.text,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // SafeArea لضمان بقاء المحتوى داخل منطقة الشاشة الآمنة
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<ForgotPasswordViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),

                        // 1️⃣ اللوجو أو أيقونة استعادة كلمة المرور
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStepIcon(viewModel.currentStep),
                            size: 60,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2️⃣ نصوص العنوان والوصف
                        Text(
                          _getStepTitle(viewModel.currentStep),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStepSubtitle(viewModel.currentStep),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSub,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 3️⃣ البطاقة الرئيسية للمدخلات (The Card Container)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colors.text.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildStepFields(context, viewModel),
                              const SizedBox(height: 30),

                              // زر الإجراء الرئيسي (عمل متجاوب مع التحميل)
                              ElevatedButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () => _onPrimaryButtonPressed(context, viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: viewModel.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getButtonIcon(viewModel.currentStep),
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getButtonText(viewModel.currentStep),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              // زر للرجوع للخطوة السابقة إذا كان في خطوة الـ OTP
                              if (viewModel.currentStep == 1) ...[
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => viewModel.setStep(0),
                                  child: Text(
                                    'تغيير البريد الإلكتروني',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // 7️⃣ زر الرجوع المخصص بالجهة اليمنى
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Directionality(
                textDirection: TextDirection.ltr, // يمنع الانعكاس التلقائي في لغة RTL
                child: Icon(
                  Icons.arrow_forward, // يتجه لليمين دائماً (→)
                  color: colors.text,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // الحصول على أيقونة الخطوة
  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.mark_email_read_outlined;
      case 1:
        return Icons.domain_verification_outlined;
      case 2:
        return Icons.lock_reset_outlined;
      default:
        return Icons.lock_outline;
    }
  }

  // الحصول على عنوان الخطوة
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'استعادة كلمة المرور';
      case 1:
        return 'التحقق من الرمز';
      case 2:
        return 'تعيين كلمة المرور الجديدة';
      default:
        return 'استعادة الحساب';
    }
  }

  // الحصول على وصف الخطوة
  String _getStepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'أدخل بريدك الإلكتروني المسجل وسنقوم بإرسال رمز OTP لتغيير كلمة المرور.';
      case 1:
        return 'أدخل الرمز المكون من 6 أرقام المرسل إلى البريد الإلكتروني الخاص بك.';
      case 2:
        return 'أدخل كلمة المرور الجديدة وتأكيدها لإتمام عملية تعيين كلمة المرور.';
      default:
        return '';
    }
  }

  // الحصول على نص زر الإجراء
  String _getButtonText(int step) {
    switch (step) {
      case 0:
        return 'إرسال رمز التحقق';
      case 1:
        return 'التحقق من الكود';
      case 2:
        return 'تحديث كلمة المرور';
      default:
        return 'استمرار';
    }
  }

  // الحصول على أيقونة زر الإجراء
  IconData _getButtonIcon(int step) {
    switch (step) {
      case 0:
        return Icons.send_rounded;
      case 1:
        return Icons.check_circle_outline_rounded;
      case 2:
        return Icons.published_with_changes_rounded;
      default:
        return Icons.arrow_forward;
    }
  }

  // بناء حقول المدخلات المناسبة للخطوة الحالية
  Widget _buildStepFields(BuildContext context, ForgotPasswordViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    switch (viewModel.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel(context, l10n.email),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: '',
              hintText: 'name@example.com',
              controller: viewModel.emailController,
              icon: Icons.email_outlined,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel(context, 'رمز التحقق (OTP)'),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: '',
              hintText: '______',
              controller: viewModel.codeController,
              icon: Icons.security_rounded,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel(context, 'كلمة المرور الجديدة'),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: '',
              hintText: 'كلمة المرور الجديدة',
              controller: viewModel.passwordController,
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildLabel(context, 'تأكيد كلمة المرور'),
            const SizedBox(height: 8),
            CustomTextField(
              labelText: '',
              hintText: 'تأكيد كلمة المرور',
              controller: viewModel.confirmPasswordController,
              icon: Icons.lock_outline,
              isPassword: true,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // معالجة الضغط على زر الإجراء الرئيسي للخطوات
  void _onPrimaryButtonPressed(BuildContext context, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        viewModel.sendResetOtp(context);
        break;
      case 1:
        viewModel.verifyResetOtp(context);
        break;
      case 2:
        viewModel.resetNewPassword(context);
        break;
    }
  }
}
