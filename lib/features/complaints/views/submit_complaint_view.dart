import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/submit_complaint_viewmodel.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تقديم الشكوى'),
        content: const Text('هل أنت متأكد من رغبتك في تقديم بلاغ بخصوص هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.qsColors.primary),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final viewModel = context.read<SubmitComplaintViewModel>();
    final success = await viewModel.submit(
      widget.orderId,
      _subjectController.text,
      _messageController.text,
    );

    if (!mounted) return;

    if (success) {
      _showResultDialog(
        'تم الإرسال',
        'تم إرسال شكواك بنجاح، سنقوم بمراجعة الطلب والتواصل معك.',
        true,
      );
    } else if (viewModel.errorMessage != null) {
      _showResultDialog(
        'خطأ',
        'حدث خطأ أثناء الإرسال، يرجى المحاولة لاحقاً.',
        false,
      );
    }
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
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
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SubmitComplaintViewModel>();
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('تقديم شكوى على طلب'),
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
            _buildFieldLabel('فئة المشكلة'),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            _buildFieldLabel('عنوان الشكوى'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _subjectController,
              hintText: 'مثلاً: تأخر المزود، سوء التعامل، اختلاف السعر...',
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('تفاصيل الشكوى'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _messageController,
              hintText: 'يرجى كتابة ما حدث معك بالتفصيل...',
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
                  : const Text(
                      'إرسال الشكوى',
                      style: TextStyle(
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
    final Map<String, String> types = {
      'type_payment': 'مشكلة في الدفع',
      'type_behavior': 'سوء تعامل من المزود',
      'type_requirements': 'عدم الالتزام بالمتطلبات',
      'type_location': 'مشكلة في الموقع',
      'type_no_show': 'عدم حضور المزود',
      'type_other': 'أخرى',
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


