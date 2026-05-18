import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../viewmodel/change_password_view_model.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ChangePasswordViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.changePassword,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: vm.isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_reset_rounded,
                        color: colors.primary, size: 60),
                  ),
                ),
                const SizedBox(height: 40),
                _buildField(
                  context: context,
                  controller: vm.oldPasswordController,
                  label: l10n.currentPassword,
                  obscure: vm.obscureOld,
                  toggle: vm.toggleOld,
                  colors: colors,
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: 20),
                _buildField(
                  context: context,
                  controller: vm.newPasswordController,
                  label: l10n.newPassword,
                  obscure: vm.obscureNew,
                  toggle: vm.toggleNew,
                  colors: colors,
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: 20),
                _buildField(
                  context: context,
                  controller: vm.confirmPasswordController,
                  label: l10n.confirmNewPassword,
                  obscure: vm.obscureConfirm,
                  toggle: vm.toggleConfirm,
                  colors: colors,
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        vm.isLoading ? null : () => _handleUpdate(context, vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.updatePassword,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 🛡️ طبقة حماية تمنع اللمس وتظهر علامة التحميل
          if (vm.isLoading)
            Container(
              color: colors.background.withOpacity(0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: colors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.updating,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required dynamic colors,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: colors.text, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: '********',
            filled: true,
            fillColor: colors.text.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20, color: colors.textSub),
              onPressed: enabled ? toggle : null,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdate(BuildContext context, ChangePasswordViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    // 1. طلب التأكيد أولاً
    final bool confirmed = await QSAlerts.showConfirm(
      context,
      title: l10n.changePassword,
      message: l10n.confirmChangePasswordMsg,
    );

    if (confirmed) {
      final success = await vm.changePassword(context);
      if (success && context.mounted) {
        // نجاح التغيير
        await QSAlerts.showSuccess(context, l10n.changePasswordSuccess);
        if (context.mounted) Navigator.pop(context); // العودة للإعدادات
      } else if (vm.errorMessage != null && context.mounted) {
        // فشل التغيير
        await QSAlerts.showError(context, vm.errorMessage!);
      }
    }
  }
}
