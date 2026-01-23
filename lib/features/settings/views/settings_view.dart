import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
// import 'package:seeker/core/storage/token_storage.dart'; // Unused
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/auth/repositories/auth_repository.dart';
import 'package:seeker/features/provider/theme_provider.dart';
import 'package:seeker/features/settings/viewmodels/settings_view_model.dart'; // Added

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

  /// 🏗️ دالة بناء الواجهة
  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    // مراقبة حالة الوضع الداكن فقط
    final isDark = context.select<ThemeProvider, bool>((p) => p.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.text),
          onPressed: widget.onMenuTap,
        ),
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 20,
          fontFamily: 'Cairo',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =================================================================
            // 1. بطاقة المستخدم (User Profile Card)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.text.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Selector<SettingsViewModel, ({String name, String email})>(
                selector: (context, vm) =>
                    (name: vm.userName, email: vm.userEmail),
                builder: (context, data, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textSub,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1), // Light Green
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'عميل موثوق',
                                style: TextStyle(
                                  color: Color(0xFF00796B), // Dark Green
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: colors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // 2. إعدادات الحساب (Account Settings)
            // =================================================================
            _buildSectionTitle('الحساب', colors.textSub),
            _buildSettingsContainer(context, [
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'تعديل الملف الشخصي',
                onTap: () {},
              ),
              _buildDivider(colors.textSub),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'تغيير كلمة المرور',
                onTap: () {},
              ),
              _buildDivider(colors.textSub),
              _buildSettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'طرق الدفع',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // =================================================================
            // 3. إعدادات التطبيق (App Settings)
            // =================================================================
            _buildSectionTitle('التطبيق', colors.textSub),
            _buildSettingsContainer(context, [
              // مفتاح الإشعارات مربوط بالـ ViewModel
              Selector<SettingsViewModel, bool>(
                selector: (context, vm) => vm.notificationsEnabled,
                builder: (context, notificationsEnabled, child) {
                  return _buildSwitchTile(
                    icon: Icons.notifications_none,
                    title: 'الإشعارات',
                    value: notificationsEnabled,
                    onChanged: (val) {
                      context.read<SettingsViewModel>().toggleNotifications(
                        val,
                      );
                    },
                  );
                },
              ),
              _buildDivider(colors.textSub),
              _buildSwitchTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'الوضع الداكن',
                value: isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
              ),
              _buildDivider(colors.textSub),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'اللغة',
                trailingText: 'العربية',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // =================================================================
            // 4. الدعم والمساعدة (Support Settings)
            // =================================================================
            _buildSectionTitle('الدعم والمساعدة', colors.textSub),
            _buildSettingsContainer(context, [
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'مركز المساعدة',
                onTap: () {},
              ),
              _buildDivider(colors.textSub),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'سياسة الخصوصية',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 30),

            // =================================================================
            // 5. زر تسجيل الخروج (Logout Button)
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.1)),
                  ),
                ),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'QuickServe v2.4.0',
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
            ),
          ],
        ),
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
        color: context.qsColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.1),
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
      height: 1,
      thickness: 0.5,
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
