import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/system_complaints_viewmodel.dart';
import 'package:seeker/l10n/app_localizations.dart';

class SubmitSystemComplaintView extends StatefulWidget {
  const SubmitSystemComplaintView({super.key});

  @override
  State<SubmitSystemComplaintView> createState() => _SubmitSystemComplaintViewState();
}

class _SubmitSystemComplaintViewState extends State<SubmitSystemComplaintView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmSystemReportTitle),
        content: Text(l10n.confirmSystemReportMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel_order), // reusable cancel string
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.qsColors.primary),
            child: Text(l10n.confirmSend, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    // ⏳ إظهار نافذة التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: context.qsColors.primary),
      ),
    );

    final viewModel = context.read<SystemComplaintsViewModel>();
    final success = await viewModel.submitComplaint(
      _titleController.text,
      _contentController.text,
    );

    if (!mounted) return;
    Navigator.pop(context); // إغلاق نافذة التحميل

    if (success) {
      _showResultDialog(
        l10n.sentSuccessfully,
        l10n.systemComplaintSubmitSuccessMsg,
        true,
      );
    } else if (viewModel.errorMessage != null) {
      _showResultDialog(
        l10n.systemReportFailedTitle,
        l10n.systemComplaintSubmitFailedMsg,
        false,
      );
    }
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.pop(context); // العودة لقائمة البلاغات
              } else {
                context.read<SystemComplaintsViewModel>().clearError();
              }
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SystemComplaintsViewModel>();
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.submitSystemComplaintTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ نوع المشكلة (Dropdown)
            _buildFieldLabel(l10n.systemComplaintType),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            // 🏷️ العنوان
            _buildFieldLabel(l10n.systemComplaintSubject),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hintText: l10n.systemComplaintSubjectHint,
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // 🏷️ التفاصيل
            _buildFieldLabel(l10n.systemComplaintDetails),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _contentController,
              hintText: l10n.systemComplaintDetailsHint,
              maxLines: 6,
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: viewModel.isSubmitting ? null : _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.sendReport,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: context.qsColors.textSub,
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    SystemComplaintsViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> typeLabels = {
      'type_technical': l10n.typeTechnical,
      'type_account': l10n.typeAccount,
      'type_financial_system': l10n.typeFinancialSystem,
      'type_suggestion': l10n.typeSuggestion,
      'type_other': l10n.typeOther,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.qsColors.textSub.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: viewModel.selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: typeLabels.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              viewModel.setSelectedType(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.qsColors.textSub),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintStyle: TextStyle(color: context.qsColors.textSub, fontSize: 14),
        ),
      ),
    );
  }
}


