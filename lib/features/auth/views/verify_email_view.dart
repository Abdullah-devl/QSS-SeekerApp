import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/verify_email_view_model.dart';

/// 📂 اسم الملف: verify_email_view.dart
/// 📝 الوصف: شاشة التحقق من البريد الإلكتروني (OTP).
/// يقوم المستخدم بإدخال كود من 6 أرقام لتفعيل حسابه.

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    // استقبال البريد الإلكتروني من الصفحة السابقة
    final email = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2️⃣ العنوان (Title)
                  const Text(
                    'تفعيل الحساب',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 3️⃣ نص الشرح (Instructions)
                  Text(
                    'تم إرسال كود التفعيل إلى البريد الإلكتروني\n${email ?? ""}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 4️⃣ حقول إدخال الكود (OTP Fields)
                  Row(
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              // الانتقال للحقل التالي إذا لم يكن الأخير
                              if (index < 5) {
                                viewModel.focusNodes[index + 1].requestFocus();
                              } else {
                                // إخفاء الكيبورد إذا كان الحقل الأخير
                                viewModel.focusNodes[index].unfocus();
                              }
                            } else {
                              // الرجوع للحقل السابق عند الحذف
                              if (index > 0) {
                                viewModel.focusNodes[index - 1].requestFocus();
                              }
                            }
                          },
                        ),
                      );
                    }),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'حدث خطأ: البريد الإلكتروني غير متوفر',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.blue.withValues(
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
                          : const Text(
                              'تفعيل الحساب',
                              style: TextStyle(
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
                      const Text(
                        'لم تستلم الكود؟ ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        // TODO: يمكن إضافة وظيفة إعادة الإرسال هنا لاحقاً
                        onTap: () {
                          if (email != null) {
                            viewModel.resendCode(context, email);
                          }
                        },
                        child: const Text(
                          'إعادة إرسال',
                          style: TextStyle(
                            color: Colors.blue,
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
