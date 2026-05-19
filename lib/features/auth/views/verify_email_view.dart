import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../viewmodel/verify_email_view_model.dart';

/// 📂 اسم الملف: verify_email_view.dart
/// 📝 الوصف: شاشة التحقق من البريد الإلكتروني (OTP).
/// يقوم المستخدم بإدخال كود من 6 أرقام لتفعيل حسابه.

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    // استقبال الألوان من الإكسنشن
    final colors = context.qsColors;
    // استقبال البريد الإلكتروني من الصفحة السابقة
    final email = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: colors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<VerifyEmailViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // 1️⃣ أيقونة البريد (Email Icon)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 60,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2️⃣ العنوان (Title)
                  Text(
                    AppLocalizations.of(context)!.activateAccount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 3️⃣ نص الشرح (Instructions)
                  Text(
                    context.tr(
                      'activation_code_sent',
                      args: {'email': email ?? ''},
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textSub,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 4️⃣ حقول إدخال الكود (OTP Fields)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: viewModel.otpControllers[index],
                            focusNode: viewModel.focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colors.textSub.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                // الانتقال للحقل التالي إذا لم يكن الأخير
                                if (index < 5) {
                                  viewModel.focusNodes[index + 1]
                                      .requestFocus();
                                } else {
                                  // إخفاء الكيبورد إذا كان الحقل الأخير
                                  viewModel.focusNodes[index].unfocus();
                                }
                              } else {
                                // الرجوع للحقل السابق عند الحذف
                                if (index > 0) {
                                  viewModel.focusNodes[index - 1]
                                      .requestFocus();
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 5️⃣ زر التفعيل (Verify Button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              if (email != null) {
                                viewModel.verifyEmail(context, email);
                              } else {
                                QSAlerts.showError(
                                  context,
                                  context.tr('error_email_missing'),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        disabledBackgroundColor: colors.primary.withValues(
                          alpha: 0.6,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : Text(
                              AppLocalizations.of(context)!.activateAccount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // 6️⃣ إعادة الإرسال (Resend Code)
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('did_not_receive_code'),
                        style: TextStyle(color: colors.textSub),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (email != null && !viewModel.isTimerRunning) {
                            viewModel.resendCode(context, email);
                          }
                        },
                        child: Text(
                          viewModel.isTimerRunning
                              ? context.tr(
                                  'resend_code_timer',
                                  args: {
                                    'timer': viewModel.timerCurrentValue
                                        .toString(),
                                  },
                                )
                              : context.tr('resend_code'),
                          style: TextStyle(
                            color: viewModel.isTimerRunning
                                ? colors.textSub
                                : colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
