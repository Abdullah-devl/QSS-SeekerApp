// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/intro/viewmodels/welcome_view_model.dart';
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: welcome_view.dart
/// 📝 الوصف: شاشة الترحيب (Welcome Screen).
/// هي الشاشة الأولى التي يراها المستخدم الجديد. تعرض شعار التطبيق،
/// زر لتغيير الثيم، وخيارات لتسجيل الدخول أو إنشاء حساب جديد.

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // الوصول للألوان بناءً على الثيم الحالي
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 1️⃣ زر تبديل الوضع الليلي (Dark Mode Toggle)
              // ==========================================
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.qsColors.text.withValues(alpha: 0.4),
                        blurRadius: 60,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      context.watch<ThemeProvider>().isDark
                          ? Icons.light_mode
                          : Icons.nightlight_round,
                    ),
                    onPressed: context.read<ThemeProvider>().toggleTheme,
                  ),
                ),
              ),

              const Spacer(),

              // ==========================================
              // 2️⃣ شعار التطبيق (Logo)
              // ==========================================
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_repair_service_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ==========================================
              // 3️⃣ العنوان والوصف (Title & Description)
              // ==========================================
              Text(
                'QuickServe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.qsColors.text,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                l10n.welcomeDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: context.qsColors.textSub,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // ==========================================
              // 4️⃣ أزرار الإجراءات (Buttons)
              // ==========================================

              // زر تسجيل الدخول
              ElevatedButton(
                onPressed: () {
                  context.read<WelcomeViewModel>().login(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.login,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // زر إنشاء حساب جديد
              ElevatedButton(
                onPressed: () {
                  context.read<WelcomeViewModel>().register(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(color: colors.primary, width: 1.5),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.createNewAccount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 5️⃣ الشروط والأحكام (Terms)
              // ==========================================
              Text(
                l10n.termsAndConditions,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.qsColors.textSub),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
