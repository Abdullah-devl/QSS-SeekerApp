import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
// import 'package:seeker/core/storage/token_storage.dart'; // Unused
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/theme/qs_colors.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart'; // Added
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/features/auth/repositories/auth_repository.dart';

/// 📂 اسم الملف: home_drawer.dart
/// 📝 الوصف: القائمة الجانبية (Drawer).
/// تحتوي على معلومات المستخدم، روابط التنقل السريع، وزر تسجيل الخروج.

class HomeDrawer extends StatefulWidget {
  final Function(int index)? onLinkTap;

  const HomeDrawer({super.key, this.onLinkTap});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  // 🎨 الوصول للألوان
  QSColors get colors => context.qsColors;

  /// 🚪 عملية تسجيل الخروج
  /// تقوم باستدعاء الـ Repository لمسح التوكن من السيرفر، ثم مسحه محلياً،
  /// وتوجيه المستخدم لشاشة تسجيل الدخول.
  Future<void> _logout() async {
    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false, // إزالة جميع الصفحات السابقة من المكدس
        );
      }
    } catch (e) {
      // حتى لو فشل الطلب (مثلاً مشاكل شبكة)، يجب حذف التوكن محلياً
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  /// 🏗️ دالة بناء الواجهة
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // تصميم حواف مستديرة للقائمة
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. رأس القائمة (Header - معلومات المستخدم)
            // =================================================================
            Padding(
              padding: const EdgeInsets.all(20.0),
              // نستخدم Selector للاستماع لتغيرات اسم المستخدم فقط
              child: Selector<HomeViewModel, String>(
                selector: (context, vm) => vm.userName,
                builder: (context, userName, child) {
                  return Row(
                    children: [
                      // صورة المستخدم مع حالة الأونلاين (نقطة خضراء)
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: const AssetImage(
                              'assets/images/user_placeholder.png',
                            ), // استبدلها بصورة حقيقية لاحقاً
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.person, size: 30),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: colors.primary,
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // الاسم والدور الوظيفي
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلا، $userName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'عميل', // يمكن إضافة Role في ViewModel لاحقاً
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // زر إغلاق القائمة
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              ),
            ),

            const Divider(),

            // =================================================================
            // 2. روابط التنقل (Navigation Items)
            // =================================================================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(Icons.home, 'الرئيسية', true, () {
                    Navigator.pop(context);
                    widget.onLinkTap?.call(0);
                  }),
                  _buildNavItem(Icons.person, 'الملف الشخصي', false, () {}),
                  _buildNavItem(Icons.archive, 'طلباتي', false, () {
                    Navigator.pop(context);
                    widget.onLinkTap?.call(1);
                  }, badgeCount: 3),
                  _buildNavItem(Icons.favorite_border, 'المفضلة', false, () {
                    Navigator.pop(context);
                    widget.onLinkTap?.call(3);
                  }),
                  _buildNavItem(Icons.notifications, 'الإشعارات', false, () {}),
                  _buildNavItem(Icons.settings, 'الإعدادات', true, () {
                    Navigator.pop(context);
                    widget.onLinkTap?.call(4);
                  }),

                  const SizedBox(height: 20),

                  // كارد ترويج (كن مزود خدمة)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'كن مزود خدمة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.handyman,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هل تريد تقديم خدماتك والربح معنا؟ انضم  اليناء  وكن مزود خدمة.',
                          style: TextStyle(fontSize: 12, color: colors.text),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('سجل الآن'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //زر تبديل الثيم
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (context.watch<ThemeProvider>().isDark
                                    ? colors.text
                                    : colors.text)
                                .withValues(alpha: 0.4),
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
            ),
            // =================================================================
            // 3. زر تسجيل الخروج
            // =================================================================
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                onTap: _logout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // رقم الإصدار
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'QuickServe v1.0.0',
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🛠️ دالة مساعدة لبناء عناصر القائمة
  Widget _buildNavItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // color: isSelected
        //     ? colors.primary.withValues(alpha: 0.5)
        //     : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? colors.text : colors.textSub),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colors.text : colors.textSub,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // عرض شارة (Badge) إذا وجد عدد (مثلاً للإشعارات)
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
