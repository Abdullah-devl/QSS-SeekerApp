import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/utils/qs_alerts.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import '../viewmodels/system_complaints_view_model.dart';

import 'package:seeker/l10n/app_localizations.dart';

class CreateSystemComplaintView extends StatefulWidget {
  const CreateSystemComplaintView({super.key});

  @override
  State<CreateSystemComplaintView> createState() =>
      _CreateSystemComplaintViewState();
}

class _CreateSystemComplaintViewState extends State<CreateSystemComplaintView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedType;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || _selectedType == null) {
      if (_selectedType == null) {
        QSAlerts.showError(context, l10n.pleaseSelectType);
      }
      return;
    }

    final confirmed = await QSAlerts.showConfirm(
      context,
      title: l10n.confirmSend,
      message: l10n.confirmSendMsg,
    );

    if (confirmed == true) {
      final role = context.read<HomeViewModel>().role;
      final success = await context
          .read<SystemComplaintsViewModel>()
          .createComplaint(
            title: _titleController.text,
            type: _selectedType!,
            content: _contentController.text,
            appSource: role,
          );

      if (success) {
        await QSAlerts.showSuccess(
          context,
          l10n.complaintSentSuccess,
        );
        if (mounted) Navigator.pop(context);
      } else {
        final error = context.read<SystemComplaintsViewModel>().errorMessage;
        QSAlerts.showError(context, error ?? l10n.complaintSentError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<SystemComplaintsViewModel>().isSaving;

    final List<String> complaintTypes = [
      l10n.typeBug,
      l10n.typePerformance,
      l10n.typePayment,
      l10n.typeAccount,
      l10n.typeSuggestion,
      l10n.typeOther,
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              l10n.addSystemComplaint,
              style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios,
                color: colors.text,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.complaintTitle, colors),
                  _buildTextFormField(
                    controller: _titleController,
                    hint: l10n.complaintTitleHint,
                    validator: (v) => v!.isEmpty ? l10n.pleaseEnterTitle : null,
                    colors: colors,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel(l10n.complaintType, colors),
                  _buildDropdown(colors, complaintTypes),
                  const SizedBox(height: 20),

                  _buildLabel(l10n.complaintDetails, colors),
                  _buildTextFormField(
                    controller: _contentController,
                    hint: l10n.complaintDetailsHint,
                    maxLines: 5,
                    validator: (v) =>
                        v!.isEmpty ? l10n.pleaseEnterDetails : null,
                    colors: colors,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.send_complaint,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 35,
                          width: 35,
                          child: CircularProgressIndicator(
                            color: colors.primary,
                            strokeWidth: 3.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.sending,
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text, dynamic colors) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4),
      child: Text(
        text,
        style: TextStyle(
          color: colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required dynamic colors,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.textSub.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.textSub.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.textSub.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildDropdown(dynamic colors, List<String> types) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.textSub.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          hint: Text(
            l10n.selectComplaintType,
            style: TextStyle(
              color: colors.textSub.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          items: types.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: TextStyle(color: colors.text)),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedType = value;
            });
          },
        ),
      ),
    );
  }
}
