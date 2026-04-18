import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (vm.errorMessage != null && vm.profile == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(vm.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.fetchProfile(),
                  child: const Text('إعادة المحاولة'),
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
      backgroundColor: bgColor,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSub,
                  ),
                ),
                const SizedBox(height: 12),

                // 🏷️ الدور (طالب خدمة / مزود خدمة)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.primary.withAlpha(30)),
                  ),
                  child: Text(
                    profile.role == 'seeker' ? 'طالب خدمة' : 'مزود خدمة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Divider(height: 40),

                // 4. أرقام الجوال
                _buildInfoSection(
                  icon: Icons.phone_android_rounded,
                  label: l10n.phoneNumber,
                  content: profile.phones.isNotEmpty
                      ? profile.phones.map((p) => p.phone).join('\n')
                      : 'لا يوجد أرقام مضافة',
                  colors: colors,
                ),

                const SizedBox(height: 24),

                // 5. الموقع (العنوان)
                _buildInfoSection(
                  icon: Icons.location_on_rounded,
                  label: l10n.address,
                  content: vm.address ??
                      ((profile.latitude != null && profile.longitude != null)
                          ? 'جاري جلب العنوان...'
                          : 'الموقع غير محدد'),
                  colors: colors,
                ),
                
                const SizedBox(height: 48),
                
                // زر تسجيل الخروج
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: تنفيذ تسجيل الخروج
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: Text(
                      l10n.logout,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
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
        color: colors.primary.withAlpha(25),
        border: Border.all(color: colors.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withAlpha(50),
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
    return Icon(
      Icons.person_rounded,
      size: 70,
      color: colors.primary,
    );
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
          style: TextStyle(
            fontSize: 16,
            color: colors.text,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
