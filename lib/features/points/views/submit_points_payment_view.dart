import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../models/points_package_model.dart';
import '../viewmodels/points_viewmodel.dart';

class SubmitPointsPaymentView extends StatefulWidget {
  final PointsPackageModel package;

  const SubmitPointsPaymentView({super.key, required this.package});

  @override
  State<SubmitPointsPaymentView> createState() => _SubmitPointsPaymentViewState();
}

class _SubmitPointsPaymentViewState extends State<SubmitPointsPaymentView> {
  final _bondNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('errorSelectingImage'))),
      );
    }
  }

  Future<void> _submit(PointsViewModel viewModel) async {
    if (_bondNumberController.text.isEmpty) {
      _showError(context.tr('enterBondNumberError'));
      return;
    }
    if (_bankNameController.text.isEmpty) {
      _showError(context.tr('enterBankNameError'));
      return;
    }
    if (_selectedImage == null) {
      _showError(context.tr('attachBondImageError'));
      return;
    }

    final success = await viewModel.subscribeToPackage(
      packageId: widget.package.id,
      bondNumber: _bondNumberController.text,
      bankName: _bankNameController.text,
      bondImage: _selectedImage!,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.tr('success')),
          content: Text(context.tr('rechargeRequestSubmittedSuccess')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(context.tr('ok')),
            ),
          ],
        ),
      );
    } else if (mounted) {
      _showError(
        viewModel.errorMessage != null
            ? context.tr(viewModel.errorMessage!)
            : context.tr('submitFailed'),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<PointsViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('confirmRechargeTitle'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPackageSummary(colors),
            const SizedBox(height: 32),
            _buildLabel(context.tr('bondOrTransferNumber')),
            const SizedBox(height: 8),
            _buildTextField(_bondNumberController, context.tr('enterBondNumberHint'), colors),
            const SizedBox(height: 24),
            _buildLabel(context.tr('senderBankName')),
            const SizedBox(height: 8),
            _buildTextField(_bankNameController, context.tr('bankNameExample'), colors),
            const SizedBox(height: 24),
            _buildLabel(context.tr('transferReceiptImage')),
            const SizedBox(height: 12),
            _buildImagePicker(colors),
            const SizedBox(height: 48),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _submit(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        context.tr('sendRequest'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, dynamic colors) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.card,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  Widget _buildImagePicker(dynamic colors) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2), width: 2),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, color: colors.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(context.tr('clickToUploadReceipt')),
                ],
              ),
      ),
    );
  }

  Widget _buildPackageSummary(dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(widget.package.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${widget.package.price.toInt()} ${context.tr('currency_sar')}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('pointsGainPrompt', args: {'count': widget.package.points}),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
