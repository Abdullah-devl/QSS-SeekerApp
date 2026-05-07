import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
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
        const SnackBar(content: Text('خطأ في اختيار الصورة')),
      );
    }
  }

  Future<void> _submit(PointsViewModel viewModel) async {
    if (_bondNumberController.text.isEmpty) {
      _showError('يرجى إدخال رقم السند');
      return;
    }
    if (_bankNameController.text.isEmpty) {
      _showError('يرجى إدخال اسم البنك');
      return;
    }
    if (_selectedImage == null) {
      _showError('يرجى إرفاق صورة السند');
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
          title: const Text('تم بنجاح'),
          content: const Text('تم إرسال طلب الشحن بنجاح، سيتم مراجعته قريباً'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      _showError(viewModel.errorMessage ?? 'فشلت عملية الإرسال');
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
        title: const Text(
          'تأكيد عملية الشحن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPackageSummary(colors),
            const SizedBox(height: 32),
            _buildLabel('رقم السند / الحوالة'),
            const SizedBox(height: 8),
            _buildTextField(_bondNumberController, 'أدخل رقم السند هنا', colors),
            const SizedBox(height: 24),
            _buildLabel('اسم البنك المحول منه'),
            const SizedBox(height: 8),
            _buildTextField(_bankNameController, 'مثال: مصرف الراجحي', colors),
            const SizedBox(height: 24),
            _buildLabel('صورة إيصال التحويل'),
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
                    : const Text(
                        'إرسال الطلب',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                  const Text('اضغط لرفع صورة الإيصال'),
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
            '${widget.package.price.toInt()} ر.س',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'سوف تحصل على ${widget.package.points} نقطة',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
