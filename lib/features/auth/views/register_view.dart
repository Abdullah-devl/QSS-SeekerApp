import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/widgets/custom_text_field.dart';
import 'package:seeker/features/auth/viewmodel/register_view_model.dart';
import 'package:seeker/features/provider/theme_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: register_view.dart
/// 📝 الوصف: واجهة المستخدم لإنشاء حساب جديد.
/// تحتوي على نموذج التسجيل (الاسم، البريد، كلمة المرور) وخانة الموافقة على الشروط.

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 استدعاء الألوان والثيم
    final colors = context.qsColors;
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: colors.background, // ✅ خلفية متجاوبة
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Consumer<RegisterViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1️⃣ الشريط العلوي (Top Bar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الوضع الليلي (يسار الشاشة)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.nightlight_round,
                            color: colors.text,
                          ),
                          onPressed: context.read<ThemeProvider>().toggleTheme,
                        ),
                      ),

                      // زر الرجوع (يمين الشاشة)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, color: colors.text),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 2️⃣ أيقونة المستخدم التعبيرية (Icon)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8EAF6), // لون خلفية سماوي فاتح
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 40,
                        color: Color(0xFF2B7CD6), // لون أزرق
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3️⃣ العنوان والوصف (Title & Subtitle)
                  Text(
                    AppLocalizations.of(context)!.createNewAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: colors.textSub),
                  ),

                  const SizedBox(height: 32),

                  // 4️⃣ حقول الإدخال (Form Fields)

                  // -- الاسم الكامل --
                  _buildLabel(context, AppLocalizations.of(context)!.name),
                  CustomTextField(
                    labelText: '',
                    hintText: AppLocalizations.of(context)!.enterFullName,
                    controller: viewModel.nameController,
                    icon: Icons.person,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // -- البريد الإلكتروني --
                  _buildLabel(context, AppLocalizations.of(context)!.email),
                  CustomTextField(
                    labelText: '',
                    hintText: 'example@email.com',
                    controller: viewModel.emailController,
                    icon: Icons.email_outlined,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // -- كلمة المرور --
                  _buildLabel(context, AppLocalizations.of(context)!.password),
                  CustomTextField(
                    labelText: '',
                    hintText: '........',
                    controller: viewModel.passwordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // -- تأكيد كلمة المرور --
                  _buildLabel(
                    context,
                    AppLocalizations.of(context)!.confirmPassword,
                  ),
                  CustomTextField(
                    labelText: '',
                    hintText: '........',
                    controller: viewModel.confirmPasswordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // 5️⃣ الشروط والأحكام (Terms & Privacy)
                  // يحتوي على نص قابل للضغط وزر اختيار (Checkbox)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              viewModel.toggleAgreement(!viewModel.isAgreed),
                          child: RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo', // النص العربي
                                color: colors.text,
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.agreeTo,
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.termsAndPrivacy,
                                  style: const TextStyle(
                                    color: Color(
                                      0xFF2B7CD6,
                                    ), // لون الرابط الأزرق
                                    fontWeight: FontWeight.bold,
                                  ),
                                  // عند الضغط على النص يتم فتح صفحة الشروط
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        viewModel.openTermsPage(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: viewModel.isAgreed,
                        activeColor: const Color(0xFF2B7CD6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: BorderSide(
                          color: colors.textSub.withValues(alpha: 0.5),
                        ),
                        onChanged: (val) => viewModel.toggleAgreement(val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 6️⃣ زر الإنشاء (Sign Up Button)
                  ElevatedButton(
                    // الزر غير مفعل إلا عند الموافقة وعدم وجود تحميل حالي
                    onPressed: (viewModel.isAgreed && !viewModel.isLoading)
                        ? () => viewModel.register(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6), // الأزرق
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      disabledBackgroundColor: const Color(
                        0xFF3B82F6,
                      ).withValues(alpha: 0.5),
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 20), // سهم لليسار
                              SizedBox(width: 8),
                              Text(
                                // AppLocalizations.of(context)!.signUp,
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 30),

                  // 7️⃣ فاصل "أو سجل باستخدام"
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(color: colors.textSub.withValues(alpha: 0.2)),
                      Container(
                        color: colors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.orRegisterWith,
                          style: TextStyle(fontSize: 12, color: colors.textSub),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 8️⃣ أزرار السوشيال
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          context,
                          label: 'Apple',
                          icon: Icons.apple,
                          isApple: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          context,
                          label: 'Google',
                          icon: Icons.g_mobiledata,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 9️⃣ رابط العودة لتسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // العودة
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        AppLocalizations.of(context)!.haveAccount,
                        style: TextStyle(color: colors.textSub),
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

  // ===========================================================================
  // 🛠️ دوال مساعدة (Helpers)
  // ===========================================================================

  /// دالة لبناء عنوان الحقل
  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          color: context.qsColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// دالة بناء أزرار السوشيال
  Widget _buildSocialButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isApple = false,
  }) {
    final isDark = context.read<ThemeProvider>().isDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.qsColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 24,
              color: isApple ? Colors.black : Colors.red, // لون مؤقت
            ),
          ],
        ),
      ),
    );
  }
}
