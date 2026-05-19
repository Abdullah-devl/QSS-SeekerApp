import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
import '../viewmodels/parts/edit_profile_view_model.dart';

/// 📂 اسم الملف: edit_profile_view.dart
/// 📝 الوصف: صفحة تعديل الملف الشخصي (الاسم، النبذة، الصورة، الموقع، الهواتف).
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<EditProfileViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('edit_profile_title'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
            color: colors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. اختيار الصورة الشخصية
                _buildImagePicker(vm, colors),
                const SizedBox(height: 32),

                // 2. حقل الاسم
                _buildTextField(
                  controller: vm.nameController,
                  label: l10n.fullName,
                  icon: Icons.person_outline,
                  colors: colors,
                  enabled: vm.profile.role != 'provider',
                ),
                const SizedBox(height: 16),

                // 3. النبذة التعريفية
                _buildTextField(
                  controller: vm.bioController,
                  label: context.tr('bio_label'),
                  icon: Icons.info_outline,
                  maxLines: 3,
                  colors: colors,
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),

                // 4. الموقع الجغرافي
                _buildLocationSection(context, vm, colors),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),

                // 5. أرقام الهاتف المتعددة
                _buildPhonesSection(context, vm, colors, l10n),
                const SizedBox(height: 40),

                // 6. زر الحفظ
                _buildSaveButton(context, vm, colors),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (vm.isLoading)
            Container(
              color: colors.text.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator(color: colors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(EditProfileViewModel vm, dynamic colors) {
    return GestureDetector(
      onTap: vm.pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 3),
              image: vm.selectedImage != null
                  ? DecorationImage(image: FileImage(vm.selectedImage!), fit: BoxFit.cover)
                  : (vm.profile.avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(vm.profile.avatarUrl), fit: BoxFit.cover)
                      : null),
            ),
            child: vm.selectedImage == null && vm.profile.avatarUrl.isEmpty
                ? Icon(Icons.camera_alt_outlined, size: 40, color: colors.primary)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required dynamic colors,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, EditProfileViewModel vm, dynamic colors) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, color: colors.primary),
            const SizedBox(width: 8),
            Text(context.tr('geo_location'), style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  vm.address ??
                      (vm.latitude != null
                          ? context.tr('fetching_address')
                          : context.tr('location_not_set')),
                  style: TextStyle(color: colors.textSub, fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: vm.updateLocation,
                icon: const Icon(Icons.my_location),
                label: Text(context.tr('update_label')),
                style: TextButton.styleFrom(foregroundColor: colors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhonesSection(
      BuildContext context, EditProfileViewModel vm, dynamic colors, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.phone_android_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text(l10n.phoneNumber,
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
              ],
            ),
            IconButton(
              onPressed: () => vm.addPhoneField(),
              icon: Icon(Icons.add_circle_outline, color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(vm.phoneEntries.length, (index) {
          final entry = vm.phoneEntries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌍 كود الدولة
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: entry.countryCodeController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '+967',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                // 📱 رقم الهاتف
                Expanded(
                  child: TextFormField(
                    controller: entry.controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: context.tr('enter_phone_number'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (vm.phoneEntries.length > 1)
                  IconButton(
                    onPressed: () => vm.removePhoneField(index),
                    icon: Icon(Icons.remove_circle_outline, color: colors.error),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, EditProfileViewModel vm, dynamic colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final success = await vm.saveChanges();
          if (success && context.mounted) {
            await QSAlerts.showSuccess(context, context.tr('profile_updated_success'));
            if (context.mounted) Navigator.pop(context, true); 
          } else if (vm.errorMessage != null && context.mounted) {
            await QSAlerts.showError(
              context,
              vm.errorMessage!.contains(' ')
                  ? vm.errorMessage!
                  : context.tr(vm.errorMessage!),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(context.tr('save_changes'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
