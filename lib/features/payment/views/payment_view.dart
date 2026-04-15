import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../orders/Models/order_model.dart';
import '../viewmodels/payment_viewmodel.dart';

/// 📂 اسم الملف: payment_view.dart
/// 📝 الوصف: واجهة الدفع (سداد عبر النقاط أو السند البنكي).

class PaymentView extends StatefulWidget {
  final OrderModel order;

  const PaymentView({super.key, required this.order});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // جلب الرصيد عند فتح الصفحة
    Future.microtask(() => context.read<PaymentViewModel>().fetchBalance());
    // تعيين المبلغ الافتراضي للسند هو سعر الخدمة
    _amountController.text = widget.order.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<PaymentViewModel>().setSelectedImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FB),
        appBar: AppBar(
          title: Text(context.tr('payment_page_title')),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Consumer<PaymentViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 💳 بطاقة سعر الخدمة
                      _buildPriceCard(context),
                      const SizedBox(height: 24),

                      // 🌟 بطاقة رصيد النقاط
                      _buildPointsBalanceCard(context, viewModel),
                      const SizedBox(height: 24),

                      // 🔘 خيارات الدفع
                      _buildPaymentMethodSelector(context, viewModel),
                      const SizedBox(height: 24),

                      // 🏗️ واجهة الخيار المحدد
                      if (viewModel.selectedMethod == PaymentMethod.points)
                        _buildPointsPaymentForm(context, viewModel)
                      else
                        _buildBondPaymentForm(context, viewModel),

                      const SizedBox(height: 40),

                      // 🚀 زر التأكيد النهائي
                      _buildSubmitButton(context, viewModel),
                    ],
                  ),
                ),

                // مؤشر التحميل
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB0F6), Color(0xFF0089D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            context.tr('service_price'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.remainingAmount.toInt()} ${context.tr('currency_sar')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBalanceCard(BuildContext context, PaymentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Color(0xFFFFB300), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('available_points'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${viewModel.balance.bonusPoints.toInt()} ${context.tr('points')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => viewModel.fetchBalance(),
            icon: const Icon(Icons.refresh, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(BuildContext context, PaymentViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('payment_confirm'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildMethodTile(
          context,
          PaymentMethod.points,
          context.tr('pay_by_points'),
          Icons.account_balance_wallet_outlined,
          viewModel,
        ),
        const SizedBox(height: 12),
        _buildMethodTile(
          context,
          PaymentMethod.bond,
          context.tr('pay_by_bond'),
          Icons.receipt_long_outlined,
          viewModel,
        ),
      ],
    );
  }

  Widget _buildMethodTile(
    BuildContext context,
    PaymentMethod method,
    String title,
    IconData icon,
    PaymentViewModel viewModel,
  ) {
    bool isSelected = viewModel.selectedMethod == method;
    return GestureDetector(
      onTap: () => viewModel.setPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF8FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF1CB0F6) : Colors.grey),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? const Color(0xFF1CB0F6) : Colors.black87,
              ),
            ),
            const Spacer(),
            Radio<PaymentMethod>(
              value: method,
              groupValue: viewModel.selectedMethod,
              activeColor: const Color(0xFF1CB0F6),
              onChanged: (v) => viewModel.setPaymentMethod(v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsPaymentForm(BuildContext context, PaymentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            context.tr('confirm_points_payment_msg'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.order.remainingAmount.toInt()} ${context.tr('points')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1CB0F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBondPaymentForm(BuildContext context, PaymentViewModel viewModel) {
    return Column(
      children: [
        // حقل المبلغ
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: context.tr('amount_to_pay'),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        // اختيار الصورة
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: viewModel.selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(viewModel.selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(context.tr('upload_receipt')),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, PaymentViewModel viewModel) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1CB0F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: viewModel.isLoading ? null : () => _handlePayment(context, viewModel),
      child: Text(
        context.tr('payment_confirm'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }

  void _handlePayment(BuildContext context, PaymentViewModel viewModel) async {
    if (viewModel.selectedMethod == PaymentMethod.points) {
      // التحقق من الرصيد
      if (viewModel.balance.bonusPoints < widget.order.remainingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('no_points_balance')), backgroundColor: Colors.red),
        );
        return;
      }

      // تأكيد
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.tr('confirm_points_payment')),
          content: Text(context.tr('confirm_points_payment_msg')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('confirm'))),
          ],
        ),
      );

      if (confirm == true) {
        final success = await viewModel.payByPoints(widget.order.id, widget.order.remainingAmount);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('points_payment_success')), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage ?? context.tr('points_payment_error')), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // سداد بسند
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إدخال مبلغ صحيح")),
        );
        return;
      }

      final success = await viewModel.payByBond(widget.order.id, amount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('bond_payment_success')), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? context.tr('bond_payment_error')), backgroundColor: Colors.red),
        );
      }
    }
  }
}
