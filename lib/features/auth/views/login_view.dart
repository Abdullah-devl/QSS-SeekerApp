import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';

import 'package:seeker/features/provider/theme_provider.dart';
// تأكد من استدعاء الويجت الخاص بك
import 'package:seeker/core/widgets/custom_text_field.dart';
import 'package:seeker/features/auth/viewmodel/login_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 📂 اسم الملف: login_view.dart
/// 📝 الوصف: واجهة المستخدم لصفحة تسجيل الدخول.
/// تحتوي على حقول إدخال البريد وكلمة المرور، وأزرار الدخول عبر السوشيال ميديا.

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 استدعاء الألوان الحالية (سواء فاتح أو داكن) من الـ Extension
    final colors = context.qsColors;
    // 🌙 معرفة حالة الوضع الحالي (هل هو داكن أم لا)
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: colors.background, // ✅ استخدام لون الخلفية المتجاوب
      body: Stack(
        children: [
          // SafeArea لضمان عدم ظهور المحتوى تحت شريط الحالة (Status Bar)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<LoginViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // 1️⃣ اللوجو (Logo)
                        // تصميم مربع بحواف دائرية ولون خلفية شفاف
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(
                              alpha: 0.1,
                            ), // خلفية شفافة من لونك الأساسي
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons
                                .construction, // أيقونة مؤقتة (يمكن تغييرها لصورة)
                            size: 40,
                            color: colors.primary, // لونك الأساسي
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2️⃣ نصوص الترحيب
                        Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.text, // لون النص المتجاوب
                            fontFamily: 'Cairo', // تأكيد الخط العربي
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.loginToContinue,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSub, // لون النص الفرعي
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 3️⃣ البطاقة الرئيسية (The Card)
                        // حاوية تحتوي على حقول الإدخال بتصميم مميز
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            // نستخدم لون السطح (Card Color) من الثيم
                            color: colors.card,
                            borderRadius: BorderRadius.circular(24),
                            // ظل خفيف لإعطاء عمق للبطاقة
                            boxShadow: [
                              BoxShadow(
                                color: colors.text.withValues(alpha: 0.11),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // -- حقل البريد الإلكتروني --
                              _buildLabel(
                                context,
                                AppLocalizations.of(context)!.email,
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                labelText:
                                    '', // العنوان خارجي لذلك نتركه فارغاً
                                hintText: 'name@example.com',
                                controller: viewModel.emailController,
                                icon: Icons.email_outlined,
                              ),

                              const SizedBox(height: 20),

                              // -- حقل كلمة المرور --
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // زر "نسيت كلمة المرور" (يسار)
                                  GestureDetector(
                                    onTap: () {}, // لم يتم تفعيله بعد
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.forgotPassword,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // العنوان (يمين/البداية)
                                  _buildLabel(
                                    context,
                                    AppLocalizations.of(context)!.password,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                labelText: '',
                                hintText: '........',
                                controller: viewModel.passwordController,
                                icon: Icons.lock_outline,
                                isPassword: true, // تفعيل إخفاء النص
                              ),

                              const SizedBox(height: 30),

                              // -- زر تسجيل الدخول (Button) --
                              ElevatedButton(
                                // تعطيل الزر إذا كان هناك تحميل
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () => viewModel.login(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: viewModel.isLoading
                                    ? const SizedBox(
                                        // مؤشر تحميل صغير داخل الزر
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        // نص الزر والأيقونة
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.login_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)!.login,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 4️⃣ فاصل "أو المتابعة" (Separator)
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: colors.textSub.withValues(alpha: 0.2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.orContinueWith,
                                style: TextStyle(
                                  color: colors.textSub,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: colors.textSub.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 5️⃣ أزرار السوشيال (Social Buttons)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                context,
                                icon: Icons.apple,
                                label: 'Apple',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSocialButton(
                                context,
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                onTap: () => viewModel.loginWithGoogle(context),
                                isGoogle: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // 6️⃣ زر الانتقال لإنشاء حساب جديد
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // الانتقال لصفحة التسجيل
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.signUp,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppLocalizations.of(context)!.dontHaveAccount,
                              style: TextStyle(color: colors.textSub),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30), // زيادة مسافة صغيرة
                        // 7️⃣ زر الدخول كزائر (Button)
                        TextButton(
                          onPressed: () => viewModel.loginAsGuest(context),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.textSub,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Warning: I made a mistake in previous thought. The Text widget is inside Row.
                              Text(
                                AppLocalizations.of(context)!.loginAsGuest,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.arrow_back
                                    : Icons.arrow_forward,
                                size: 18,
                                color: colors.textSub,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // 7️⃣ زر الوضع الليلي العائم (Floating Theme Toggle)
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              onPressed: context.read<ThemeProvider>().toggleTheme,
              backgroundColor: isDark ? colors.secondary : colors.background,
              elevation: 4,
              child: Icon(
                isDark ? Icons.light_mode : Icons.nightlight_round,
                color: colors.text,
              ),
            ),
          ),

          // زر الرجوع في الأعلى (اختياري، يظهر فقط إذا كان هناك صفحة سابقة)
          Positioned(
            top: 50,
            right: Directionality.of(context) == TextDirection.rtl ? 20 : null,
            left: Directionality.of(context) == TextDirection.ltr ? 20 : null,
            child: IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios,
                color: colors.text,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🛠️ دوال مساعدة للتصميم (Helper Widgets)
  // ===========================================================================

  /// 🏷️ دالة لبناء عنوان الحقل (Label) بشكل موحد.
  Widget _buildLabel(BuildContext context, String text) {
    return Align(
      alignment: AlignmentDirectional.centerEnd, // محاذاة متجاوبة مع الاتجاه
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: context.qsColors.text, // استخدام لون النص العام
        ),
      ),
    );
  }

  /// 🔘 زر الدخول عبر وسائل التواصل الاجتماعي.
  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isGoogle = false,
  }) {
    final colors = context.qsColors;
    final isDark = context.watch<ThemeProvider>().isDark;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        // الخلفية تتغير حسب الثيم
        backgroundColor: colors.card,
        side: BorderSide(color: colors.textSub.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isGoogle
                ? colors
                      .error // تلوين أيقونة جوجل بلون الخطأ للهوية
                : colors.text,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
