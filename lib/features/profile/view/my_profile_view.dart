import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import '../viewmodels/profile_view_model.dart';
import '../viewmodels/parts/edit_profile_view_model.dart'; // ✅ تمت الإضافة
import 'edit_profile_view.dart'; // ✅ تمت الإضافة

/// 📂 اسم الملف: my_profile_view.dart
/// 📝 الوصف: صفحة الملف الشخصي الخاصة بالمستخدم الحالي بتصميم بسيط ومركز.
class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ProfileViewModel>();
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final l10n = AppLocalizations.of(context)!;

    if (vm.isLoading && vm.profile == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (vm.errorMessage != null && vm.profile == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.text),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.fetchProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                  ),
                  child: Text(
                    context.tr('retry'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = vm.profile;
    if (profile == null) return const Scaffold();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.profile,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.primary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => EditProfileViewModel(
                      context.read<ProfileRepository>(),
                      profile,
                    ),
                    child: const EditProfileView(),
                  ),
                ),
              );

              if (result == true) {
                vm.fetchProfile(); // تحديث البيانات بعد العودة من التعديل
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.fetchProfile(),
        color: colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. الصورة الدائرية في المنتصف
                _buildAvatar(profile.avatarUrl, colors),
                const SizedBox(height: 24),

                // 2. الاسم تحت الصورة
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. البريد الإلكتروني (إيميله)
                Text(
                  profile.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: colors.textSub),
                ),
                const SizedBox(height: 12),

                // 🏷️ الدور (طالب خدمة / مزود خدمة)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    profile.role == 'seeker'
                        ? context.tr('seeker_role')
                        : context.tr('provider_role'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 💰 عرض رصيد النقاط
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPointsStat(
                      label: l10n.available_points,
                      value: profile.bonusPoints.toStringAsFixed(0),
                      icon: Icons.stars_rounded,
                      colors: colors,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Divider(height: 40),

                // 4. أرقام الجوال
                _buildInfoSection(
                  icon: Icons.phone_android_rounded,
                  label: l10n.phoneNumber,
                  content: profile.phones.isNotEmpty
                      ? profile.phones
                            .map((p) => '${p.countryCode ?? ''} ${p.phone}')
                            .join('\n')
                      : context.tr('no_phones_added'),
                  colors: colors,
                ),

                const SizedBox(height: 24),

                // 5. الموقع (العنوان)
                _buildInfoSection(
                  icon: Icons.location_on_rounded,
                  label: l10n.address,
                  content:
                      vm.address ??
                      ((profile.latitude != null && profile.longitude != null)
                          ? context.tr('fetching_address')
                          : context.tr('location_not_set')),
                  colors: colors,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, dynamic colors) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.1),
        border: Border.all(color: colors.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
              )
            : _buildPlaceholder(colors),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic colors) {
    return Icon(Icons.person_rounded, size: 70, color: colors.primary);
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String content,
    required dynamic colors,
  }) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: colors.text, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPointsStat({
    required String label,
    required String value,
    required IconData icon,
    required dynamic colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: colors.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
