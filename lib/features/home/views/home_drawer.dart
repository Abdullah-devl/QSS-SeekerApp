import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/theme/qs_colors.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/features/auth/repositories/auth_repository.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seeker/l10n/app_localizations.dart';

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
  /// 🚪 عملية تسجيل الخروج
  Future<void> _logout() async {
    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        TokenStorage().deleteToken();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 الوصول للألوان من خلال الـ BuildContext بشكل آمن
    final colors = context.qsColors;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      // ✅ استخدام Selector لاسترجاع (الاسم والدور) معاً كـ Record
      // هذا يمنع الانهيار ويحسن الأداء لأنه يستمع فقط للتغيرات المطلوبة
      child: Selector<HomeViewModel, ({String name, String role})>(
        selector: (context, vm) => (name: vm.userName, role: vm.role),
        builder: (context, userData, child) {
          final String userName = userData.name;
          final String userRole = userData.role;

          return SafeArea(
            child: Column(
              children: [
                // =================================================================
                // 1. رأس القائمة (Header - معلومات المستخدم)
                // =================================================================
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
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
                            ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.hello}$userName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
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
                      _buildNavItem(
                        colors,
                        Icons.home,
                        AppLocalizations.of(context)!.home,
                        true,
                        () {
                          Navigator.pop(context);
                          widget.onLinkTap?.call(0);
                        },
                      ),

                      // 🛡️ شرط الصلاحيات: عرض "طلباتي" و "المفضلة" فقط إذا لم يكن زائر
                      if (userRole != 'زائر') ...[
                        _buildNavItem(
                          colors,
                          Icons.archive,
                          AppLocalizations.of(context)!.myOrders,
                          false,
                          () {
                            Navigator.pop(context);
                            widget.onLinkTap?.call(1);
                          },
                          badgeCount: 3,
                        ),

                        _buildNavItem(
                          colors,
                          Icons.favorite_border,
                          AppLocalizations.of(context)!.favorites,
                          false,
                          () {
                            Navigator.pop(context);
                            widget.onLinkTap?.call(3);
                          },
                        ),
                        _buildNavItem(
                          colors,
                          Icons.notifications,
                          AppLocalizations.of(context)!.notifications,
                          false,
                          () {},
                        ),
                      ],

                      _buildNavItem(
                        colors,
                        Icons.settings,
                        AppLocalizations.of(context)!.settings,
                        true,
                        () {
                          Navigator.pop(context);
                          widget.onLinkTap?.call(4);
                        },
                      ),

                      const SizedBox(height: 20),

                      // 🛡️ شرط الصلاحيات: كارد الترويج يظهر فقط للأعضاء المسجلين
                      // if (userRole == 'seeker')
                      //   _buildPromoCard(context, colors),
                      if (userRole != 'provider' && userRole == 'seeker')
                        _buildPromoCard(context, colors),
                    ],
                  ),
                ),

                // زر تبديل الثيم
                _buildThemeSwitcher(context, colors),
                // =================================================================
                // 3. منطقة أزرار الدخول / الخروج
                // =================================================================
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: userRole == 'زائر'
                      ? //  إذا كان المستخدم زائراً، نعرض زر تسجيل الدخول
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.login, color: colors.text),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color: colors.text, // لون مختلف للتمييز
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : // إذا لم يكن زائراً، نعرض زر تسجيل الخروج الأصلي
                        InkWell(
                          onTap: _logout,
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.logout,
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
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'QuickServe v1.0.0',
                    style: TextStyle(color: colors.textSub, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🛠️ ودجت كارد الترويج (تم فصلها لتحسين القراءة)
  Widget _buildPromoCard(BuildContext context, QSColors colors) {
    return Container(
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
              Text(
                AppLocalizations.of(context)!.beProvider,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            AppLocalizations.of(context)!.beProviderDesc,
            style: TextStyle(fontSize: 12, color: colors.text),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق القائمة الجانبية
                Navigator.pushNamed(context, AppRoutes.beProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.registerNow),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌙 ودجت زر تبديل الوضع الليلي
  Widget _buildThemeSwitcher(BuildContext context, QSColors colors) {
    final themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.text.withValues(alpha: 0.4),
                blurRadius: 60,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.nightlight_round,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ),
      ),
    );
  }

  /// 🛠️ دالة مساعدة لبناء عناصر القائمة
  Widget _buildNavItem(
    QSColors colors,
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? colors.text : colors.textSub),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colors.text : colors.textSub,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
