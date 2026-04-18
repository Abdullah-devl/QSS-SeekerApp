import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../viewmodels/policy_view_model.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = context.read<HomeViewModel>().role;
      // إذا كان زائر أو طالب خدمة، نطلب سياسة الـ seeker، وإذا كان مزود نطلب provider
      final effectiveRole = (role == 'guest' || role == 'seeker') ? 'seeker' : 'provider';
      context.read<PolicyViewModel>().fetchPolicy(effectiveRole);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PolicyViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.privacyPolicy,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(vm, colors, l10n),
    );
  }

  Widget _buildBody(PolicyViewModel vm, dynamic colors, dynamic l10n) {
    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 20),
            Text(context.tr('loading_policy'), style: TextStyle(color: colors.textSub)),
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
                style: TextStyle(color: colors.text, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final role = context.read<HomeViewModel>().role;
                  final effectiveRole = (role == 'guest' || role == 'seeker') ? 'seeker' : 'provider';
                  vm.fetchPolicy(effectiveRole);
                },
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                child: Text(context.tr('retry'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.policyContent == null || vm.policyContent!.isEmpty) {
      return Center(
        child: Text(context.tr('no_policy_available'), style: TextStyle(color: colors.textSub)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ العنوان (Title)
          if (vm.policyTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 4),
              child: Text(
                vm.policyTitle!,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // 📄 المحتوى (Content)
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
              vm.policyContent!,
              style: TextStyle(
                color: colors.text,
                fontSize: 15,
                height: 1.8,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '${context.tr('last_update')}: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
              style: TextStyle(color: colors.textSub, fontSize: 12),
            ),
          ),
          const SizedBox(height: 120), // مساحة إضافية للأسفل
        ],
      ),
    );
  }
}
