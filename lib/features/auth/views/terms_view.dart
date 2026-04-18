import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/provider/theme_provider.dart';

/// 📂 اسم الملف: terms_view.dart
/// 📝 الوصف: صفحة عرض الشروط والأحكام.
/// يجب على المستخدم الموافقة عليها قبل إتمام عملية التسجيل.

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
  // حالة الموافقة الداخلية لهذه الصفحة (Checkbox)
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    // 🎨 الألوان والثيم
    final colors = context.qsColors;
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1️⃣ الأيقونة العلوية (الدرع - Shield Icon)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.security_rounded, // أيقونة الدرع
                  size: 40,
                  color: colors.primary, // اللون المتجاوب
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2️⃣ العنوان والوصف القصير
            Text(
              context.tr('terms_of_service'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.text,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('read_terms_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSub,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // 3️⃣ الحاوية البيضاء للنص (Scrollable Text Container)
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.text.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نصوص الشروط والأحكام
                       _buildSectionTitle(context.tr('terms_intro_title')),
                      _buildSectionText(
                        context.tr('terms_intro_text'),
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context.tr('terms_quality_title')),
                      _buildSectionText(
                        context.tr('terms_quality_text'),
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context.tr('terms_pricing_title')),
                      _buildSectionText(
                        context.tr('terms_pricing_text'),
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context.tr('terms_cancellation_title')),
                      _buildSectionText(
                        context.tr('terms_cancellation_text'),
                        colors.textSub,
                      ),
                      const SizedBox(height: 200), // مساحة إضافية لضمان التمرير
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4️⃣ خيار "لقد قرات ووافقت" مع Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).cardColor : colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Cairo', // النص العربي
                              color: colors.text,
                            ),
                            children: [
                              TextSpan(text: context.tr('agree_to_terms_prefix')),
                              TextSpan(
                                text: context.tr('terms_of_service'),
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: context.tr('and_label')),
                              TextSpan(
                                text: context.tr('privacy_policy'),
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    // Checkbox دائري مخصص
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _isChecked,
                        activeColor: colors.primary,
                        shape: const CircleBorder(), // لجعله دائرياً
                        side: BorderSide(
                          color: colors.textSub.withValues(alpha: 0.5),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _isChecked = val ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5️⃣ الأزرار (الموافقة / إلغاء)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // زر الموافقة
                  ElevatedButton(
                    onPressed: _isChecked
                        ? () {
                            // نرجع true للصفحة السابقة (RegisterView)
                            Navigator.pop(context, true);
                          }
                        : null, // معطل حتى يوافق المستخدم
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('agree_and_continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // زر الإلغاء
                  OutlinedButton(
                    onPressed: () {
                      // العودة بدون موافقة
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: colors.textSub.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    child: Text(
                      context.tr('cancel'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 📐 عنوان فرعي للشروط
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.qsColors.text),
    );
  }

  /// 📄 نص الشروط
  Widget _buildSectionText(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 14, color: color, height: 1.6),
    );
  }
}
