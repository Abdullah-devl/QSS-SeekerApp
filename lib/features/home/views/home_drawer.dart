import 'package:flutter/material.dart';
import 'package:seeker/core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/theme/qs_colors.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/features/orders/ViewModels/orders_viewmodel.dart';
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
      // 🔔 إزالة توكن الإشعارات من السيرفر قبل تسجيل الخروج
      final notificationService = NotificationService();
      await notificationService.deleteTokenOnLogout();

      if (!mounted) return;
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
      backgroundColor: colors.background,
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
          final String userName = userData.name == 'Guest'
              ? AppLocalizations.of(context)!.guest
              : userData.name;
          final String userRole =
              (userData.role == 'guest' || userData.role == 'زائر')
              ? AppLocalizations.of(context)!.guest
              : userData.role;

          return SafeArea(
            child: Column(
              children: [
                // =================================================================
                // 1. رأس القائمة (Header - معلومات المستخدم)
                // =================================================================
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
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
                              color: colors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.background,
                                width: 2,
                              ),
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
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
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

                Divider(
                  color: colors.textSub.withValues(alpha: 0.1),
                  thickness: 1,
                ),

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
                      if (userRole != AppLocalizations.of(context)!.guest) ...[
                        _buildNavItem(
                          colors,
                          Icons.archive,
                          AppLocalizations.of(context)!.myOrders,
                          false,
                          () {
                            Navigator.pop(context);
                            widget.onLinkTap?.call(1);
                          },
                          badgeCount: context
                              .watch<OrdersViewModel>()
                              .newOrdersCount,
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
                      if (userRole != 'provider' &&
                          (userRole == 'seeker' || userRole == 'client'))
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: userRole == AppLocalizations.of(context)!.guest
                      ? //  إذا كان المستخدم زائراً، نعرض زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              ); // إغلاق القائمة الجانبية لتسهيل الانتقال
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            icon: const Icon(
                              Icons.login,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.login,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        )
                      : // إذا لم يكن زائراً، نعرض زر تسجيل الخروج الأصلي
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: Icon(
                              Icons.logout,
                              color: colors.error,
                              size: 20,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.logout,
                              style: TextStyle(
                                color: colors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colors.error.withValues(alpha: 0.2),
                              ),
                              backgroundColor: colors.error.withValues(
                                alpha: 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                ),
                // شعار التطبيق في الأسفل
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
                // رقم الإصدار
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'QSS v1.0.0',
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
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
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
                foregroundColor: colors.background,
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
            color: colors.card,
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
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colors.primary : colors.textSub,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colors.primary : colors.textSub,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: (badgeCount != null && badgeCount > 0)
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: colors.background,
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
