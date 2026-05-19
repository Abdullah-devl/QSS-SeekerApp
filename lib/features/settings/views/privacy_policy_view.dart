import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../viewmodels/policy_view_model.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  bool _isAlreadyAgreed = true;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final tokenStorage = context.read<TokenStorage>();
    _isAlreadyAgreed = await tokenStorage.isPolicyAgreed();
    
    if (mounted) {
      final role = context.read<HomeViewModel>().role;
      final effectiveRole = (role == 'guest' || role == 'seeker') ? 'seeker' : 'provider';
      context.read<PolicyViewModel>().fetchPolicy(effectiveRole);
      setState(() {});
    }
  }

  /// إظهار رسالة التأكيد قبل الموافقة
  Future<void> _showConfirmDialog(PolicyViewModel vm, String role) async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool fromRegister = args?['fromRegister'] ?? false;

    final confirmed = await QSAlerts.showConfirm(
      context,
      title: context.tr('confirm_completion_title'),
      message: 'هل أنت موافق على جميع الشروط والسياسات المذكورة؟',
    );

    if (confirmed && mounted) {
      if (fromRegister) {
        Navigator.pop(context, true);
        return;
      }
      final success = await vm.agreeToPolicy(role);
      if (success && mounted) {
        // حفظ الحالة محلياً
        await context.read<TokenStorage>().savePolicyAgreement(true);
        if (mounted) {
          await QSAlerts.showSuccess(context, 'مرحباً بك في تطبيق Seeker!');
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        }
      } else if (mounted) {
        await QSAlerts.showError(
          context,
          vm.errorMessage != null
              ? (vm.errorMessage!.contains(' ') ? vm.errorMessage! : context.tr(vm.errorMessage!))
              : 'حدث خطأ أثناء إرسال الموافقة',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PolicyViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final role = context.read<HomeViewModel>().role;
    final effectiveRole = (role == 'guest' || role == 'seeker') ? 'seeker' : 'provider';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.privacyPolicy,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(vm, colors, l10n, effectiveRole),
    );
  }

  Widget _buildBody(PolicyViewModel vm, dynamic colors, dynamic l10n, String role) {
    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 20),
            Text(context.tr('loading_policy'), style: TextStyle(color: colors.textSub, fontFamily: 'Cairo')),
          ],
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
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
                style: TextStyle(color: colors.text, fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.fetchPolicy(role),
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                child: Text(context.tr('retry'), style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.policyTitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 4),
                  child: Text(
                    vm.policyTitle!,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SelectableText(
                  vm.policyContent ?? '',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    height: 1.8,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  '${context.tr('last_update')}: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                  style: TextStyle(color: colors.textSub, fontSize: 12, fontFamily: 'Cairo'),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
        // زر الموافقة يظهر فقط إذا لم يوافق المستخدم بعد أو كان قادماً من صفحة التسجيل
        if (!_isAlreadyAgreed || (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['fromRegister'] == true)
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showConfirmDialog(vm, role),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text(
                  'الموافقة والمتابعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
