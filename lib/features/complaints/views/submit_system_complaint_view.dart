import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/system_complaints_viewmodel.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإرسال'),
        content: const Text('هل أنت متأكد من رغبتك في إرسال هذا البلاغ للدعم الفني؟'),
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
            child: const Text('تأكيد الإرسال', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
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
        'تم الإرسال بنجاح',
        'شكرًا لك، تم استلام بلاغك وسيقوم فريق الدعم الفني بمراجعته في أقرب وقت.',
        true,
      );
    } else if (viewModel.errorMessage != null) {
      _showResultDialog(
        'خطأ في الإرسال',
        'نعتذر، حدث خطأ أثناء محاولة إرسال البلاغ. يرجى المحاولة مرة أخرى.',
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
                Navigator.pop(context); // العودة لقائمة البلاغات
              } else {
                context.read<SystemComplaintsViewModel>().clearError();
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
    final viewModel = context.watch<SystemComplaintsViewModel>();
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('إبلاغ عن مشكلة نظام'),
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
            _buildFieldLabel('نوع البلاغ'),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            // 🏷️ العنوان
            _buildFieldLabel('عنوان البلاغ'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hintText: 'مثلاً: مشكلة في شحن النقاط، خطأ في تسجيل الدخول...',
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // 🏷️ التفاصيل
            _buildFieldLabel('تفاصيل البلاغ'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _contentController,
              hintText: 'يرجى كتابة تفاصيل المشكلة التي تواجهها بوضوح...',
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
                  : const Text(
                      'إرسال البلاغ الآن',
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
    SystemComplaintsViewModel viewModel,
  ) {
    final Map<String, String> typeLabels = {
      'type_technical': 'مشكلة تقنية',
      'type_account': 'الحساب والخصوصية',
      'type_financial_system': 'عمليات الدفع والنقاط',
      'type_suggestion': 'اقتراح أو تحسين',
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


