import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/theme/qs_colors.dart';
import 'package:seeker/features/auth/repositories/auth_repository.dart';
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/features/settings/viewmodels/settings_view_model.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart'; // ✅ نحتاج HomeViewModel لمعرفة الدور
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seeker/l10n/app_localizations.dart';

import 'package:seeker/features/profile/viewmodels/profile_view_model.dart'; // ✅ تمت الإضافة

/// 📂 اسم الملف: settings_view.dart
/// 📝 الوصف: شاشة الإعدادات.
/// تتيح للمستخدم التحكم في حسابه وتفضيلات التطبيق.

class SettingsView extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const SettingsView({super.key, this.onMenuTap});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    // 🔄 تحميل بيانات المستخدم عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadUserData();
      // 🚀 جلب بيانات الملف الشخصي الحية
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

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
    final colors = context.qsColors;

    // ✅ نستخدم Selector لمعرفة دور المستخدم (زائر أم لا)
    final userRole = context.select<HomeViewModel, String>((vm) => vm.role);

    // مراقبة حالة الوضع الداكن فقط
    final isDark = context.select<ThemeProvider, bool>((p) => p.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.primary),
          onPressed: widget.onMenuTap,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =================================================================
            // 1. بطاقة المستخدم (تظهر للمسجلين فقط)
            // =================================================================
            if (userRole != 'guest')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.text.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<ProfileViewModel>(
                  builder: (context, profileVM, child) {
                    final profile = profileVM.profile;
                    final isLoading = profileVM.isLoading;

                    if (isLoading && profile == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? '...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.email ?? '...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSub,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 🏷️ وصف الدور (طالب خدمة / مزود خدمة)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  userRole == 'provider'
                                      ? AppLocalizations.of(
                                          context,
                                        )!.provider_role
                                      : AppLocalizations.of(
                                          context,
                                        )!.seeker_role,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 💰 عرض رصيد النقاط في الإعدادات
                              Row(
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 14,
                                    color: colors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${AppLocalizations.of(context)!.available_points}: ${(profile?.bonusPoints ?? 0).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colors.text,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              backgroundImage:
                                  (profile?.avatarUrl != null &&
                                      profile!.avatarUrl.isNotEmpty)
                                  ? NetworkImage(profile.avatarUrl)
                                  : null,
                              child:
                                  (profile?.avatarUrl == null ||
                                      profile!.avatarUrl.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: colors.primary,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              // 🔵 بطاقة دعوة للتسجيل تظهر للزائر فقط
              _buildGuestCard(colors),

            const SizedBox(height: 24),

            // =================================================================
            // 2. إعدادات الحساب (تختفي للزائر)
            // =================================================================
            if (userRole != 'guest') ...[
              _buildSectionTitle(
                AppLocalizations.of(context)!.account,
                colors.textSub,
              ),
              _buildSettingsContainer(context, [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: AppLocalizations.of(context)!.editProfile,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                _buildDivider(colors.textSub),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: AppLocalizations.of(context)!.changePassword,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.changePassword);
                  },
                ),
                _buildDivider(colors.textSub),
                _buildSettingsTile(
                  icon: Icons.monetization_on_outlined,
                  title: AppLocalizations.of(context)!.pointsManagementTitle,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.pointsManagement);
                  },
                ),
              ]),
              const SizedBox(height: 24),
            ],

            // =================================================================
            // 3. إعدادات التطبيق (متاحة للجميع)
            // =================================================================
            _buildSectionTitle(
              AppLocalizations.of(context)!.appSettings,
              colors.textSub,
            ),
            _buildSettingsContainer(context, [
              if (userRole != 'guest') ...[
                Selector<SettingsViewModel, bool>(
                  selector: (context, vm) => vm.notificationsEnabled,
                  builder: (context, notificationsEnabled, child) {
                    return _buildSwitchTile(
                      icon: Icons.notifications_none,
                      title: AppLocalizations.of(context)!.notifications,
                      value: notificationsEnabled,
                      onChanged: (val) => context
                          .read<SettingsViewModel>()
                          .toggleNotifications(val),
                    );
                  },
                ),
                _buildDivider(colors.textSub),
              ],
              _buildSwitchTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: AppLocalizations.of(context)!.darkMode,
                value: isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
              ),
              _buildDivider(colors.textSub),
              _buildSettingsTile(
                icon: Icons.language,
                title: AppLocalizations.of(context)!.language,
                trailingText:
                    context
                            .select<SettingsViewModel, Locale>(
                              (vm) => vm.locale,
                            )
                            .languageCode ==
                        'ar'
                    ? 'العربية'
                    : 'English',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.selectLanguage,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Text(
                                '🇸🇦',
                                style: TextStyle(fontSize: 24),
                              ),
                              title: const Text('العربية'),
                              trailing:
                                  context
                                          .read<SettingsViewModel>()
                                          .locale
                                          .languageCode ==
                                      'ar'
                                  ? Icon(Icons.check, color: colors.success)
                                  : null,
                              onTap: () {
                                context
                                    .read<SettingsViewModel>()
                                    .changeLanguage(const Locale('ar'));
                                Navigator.pop(context);
                              },
                            ),
                            _buildDivider(colors.textSub),
                            ListTile(
                              leading: const Text(
                                '🇺🇸',
                                style: TextStyle(fontSize: 24),
                              ),
                              title: const Text('English'),
                              trailing:
                                  context
                                          .read<SettingsViewModel>()
                                          .locale
                                          .languageCode ==
                                      'en'
                                  ? Icon(Icons.check, color: colors.success)
                                  : null,
                              onTap: () {
                                context
                                    .read<SettingsViewModel>()
                                    .changeLanguage(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // =================================================================
            // 4. الدعم والمساعدة
            // =================================================================
            if (userRole != 'guest') ...[
              _buildSectionTitle(
                AppLocalizations.of(context)!.support,
                colors.textSub,
              ),
              _buildSettingsContainer(context, [
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: AppLocalizations.of(context)!.privacyPolicy,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                  },
                ),
                _buildDivider(colors.textSub),
                _buildSettingsTile(
                  icon: Icons.feedback_outlined,
                  title: AppLocalizations.of(context)!.complaintsHub,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.systemComplaints);
                  },
                ),
              ]),
            ],
            const SizedBox(height: 30),

            // =================================================================
            // 5. زر تسجيل الخروج أو تسجيل الدخول (تبديل شرطي)
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // ✅ إذا كان زائر، يذهب لصفحة الدخول، وإذا كان مسجلاً، يقوم بتسجيل الخروج
                onPressed: userRole == 'guest'
                    ? () => Navigator.pushNamed(context, AppRoutes.login)
                    : _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.card,
                  // ✅ تغيير اللون: أزرق للدخول، أحمر للخروج
                  foregroundColor: userRole == 'guest'
                      ? colors.text
                      : colors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color:
                          (userRole == 'guest' ? colors.primary : colors.error)
                              .withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Text(
                  userRole == 'guest'
                      ? AppLocalizations.of(context)!.login
                      : AppLocalizations.of(context)!.logout,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                AppLocalizations.of(context)!.settingsFooter,
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
            ),
            // مساحة إضافية في الأسفل لتجنب تغطية المحتوى بالـ NavBar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 🛠️ ودجت تظهر للزائر بدلاً من بيانات الملف الشخصي
  Widget _buildGuestCard(QSColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.account_circle, size: 50, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.welcomeGuest,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.guestLoginDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSub, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(
      height: 1.0,
      thickness: 1,
      color: color.withValues(alpha: 0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    final colors = context.qsColors;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(color: colors.textSub, fontSize: 14),
            ),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: colors.textSub),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.qsColors;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colors.primary,
      ),
    );
  }
}
