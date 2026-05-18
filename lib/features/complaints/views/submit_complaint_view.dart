import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/submit_complaint_viewmodel.dart';
import 'package:seeker/l10n/app_localizations.dart';

class SubmitComplaintView extends StatefulWidget {
  final String orderId;

  const SubmitComplaintView({super.key, required this.orderId});

  @override
  State<SubmitComplaintView> createState() => _SubmitComplaintViewState();
}

class _SubmitComplaintViewState extends State<SubmitComplaintView> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmComplaintTitle),
        content: Text(l10n.confirmComplaintMsg),
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
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<SubmitComplaintViewModel>();
    final success = await viewModel.submit(
      widget.orderId,
      _subjectController.text,
      _messageController.text,
    );

    if (!mounted) return;

    if (success) {
      _showResultDialog(
        l10n.sentSuccessfully,
        l10n.complaintSubmitSuccessMsg,
        true,
      );
    } else if (viewModel.errorMessage != null) {
      _showResultDialog(
        l10n.error_loading_orders, // reusable error title
        l10n.complaintSubmitFailedMsg,
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
                Navigator.pop(context); // العودة لتفاصيل الطلب
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
    final viewModel = context.watch<SubmitComplaintViewModel>();
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.submitComplaintTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ نوع الشكوى (Dropdown)
            _buildFieldLabel(l10n.complaintCategory),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            _buildFieldLabel(l10n.complaintSubject),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _subjectController,
              hintText: l10n.complaintSubjectHint,
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(l10n.complaintDetails),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _messageController,
              hintText: l10n.complaintDetailsHint,
              maxLines: 6,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.sendComplaint,
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
    SubmitComplaintViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> types = {
      'type_payment': l10n.typePayment,
      'type_behavior': l10n.typeBehavior,
      'type_requirements': l10n.typeRequirements,
      'type_location': l10n.typeLocation,
      'type_no_show': l10n.typeNoShow,
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
          items: types.entries.map((entry) {
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


