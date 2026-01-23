import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  color: const Color(0xFFD8EAF6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD8EAF6).withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_rounded, // أيقونة الدرع
                  size: 40,
                  color: Color(0xFF00A9F4), // الأزرق السماوي
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2️⃣ العنوان والوصف القصير
            Text(
              'شروط الخدمة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.text,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى قراءة سياسة التطبيق والكشروط والأحكام الخاصة\nبمقدمي الخدمات بعناية قبل المتابعة.',
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
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين
                    children: [
                      // نصوص الشروط والأحكام
                      _buildSectionTitle('1. مقدمة'),
                      _buildSectionText(
                        'أهلاً بك في تطبيق QuickServe. تُعد هذه الشروط اتفاقية ملزمة بينك كمقدم خدمة وبين إدارة التطبيق. باستخدامك للتطبيق، فإنك توافق على الالتزام بكافة البنود المذكورة.',
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('2. معايير الجودة'),
                      _buildSectionText(
                        'يلتزم مقدم الخدمة بالحفاظ على أعلى معايير الجودة والمهنية عند التعامل مع العملاء. يجب الحضور في الموعد المحدد وتنفيذ الخدمة المتفق عليها بدقة.',
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('3. التسعير والدفع'),
                      _buildSectionText(
                        'يتم تحديد الأسعار بناءً على نوع الخدمة. يمنع طلب مبالغ إضافية خارج التطبيق.',
                        colors.textSub,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('4. الإلغاء والاسترجاع'),
                      _buildSectionText(
                        'تخضع سياسة الإلغاء للشروط الموضحة في صفحة الحجوزات. قد يتم فرض رسوم عند الإلغاء المتأخر.',
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
                  color: isDark ? Colors.grey[900] : const Color(0xFFF5F9FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Cairo', // النص العربي
                            color: colors.text,
                          ),
                          children: [
                            const TextSpan(text: 'لقد قرأت ووافقت على '),
                            TextSpan(
                              text: 'شروط الخدمة',
                              style: const TextStyle(
                                color: Color(0xFF00A9F4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' و '),
                            TextSpan(
                              text: 'سياسة الخصوصية',
                              style: const TextStyle(
                                color: Color(0xFF00A9F4),
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
                        activeColor: const Color(0xFF00A9F4),
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
                      backgroundColor: const Color(0xFF00A9F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: const Color(
                        0xFF00A9F4,
                      ).withValues(alpha: 0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'الموافقة والمتابعة',
                          style: TextStyle(
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
                      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    ),
                    child: Text(
                      'إلغاء',
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
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  /// 📄 نص الشروط
  Widget _buildSectionText(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 14, color: color, height: 1.6),
    );
  }
}
