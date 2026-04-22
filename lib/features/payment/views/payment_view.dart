import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
// import 'package:seeker/core/theme/qs_colors.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
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
    final colors = context.qsColors;
    return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(context.tr('payment_page_title')),
          centerTitle: true,
          backgroundColor: colors.background,
          foregroundColor: colors.text,
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
                    color: colors.text.withValues(alpha: 0.3),
                    child: Center(child: CircularProgressIndicator(color: colors.primary)),
                  ),
              ],
            );
          },
        ),
      );
  }

  Widget _buildPriceCard(BuildContext context) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            context.tr('service_price'),
            style: TextStyle(color: colors.background.withValues(alpha: 0.7), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.remainingAmount.toInt()} ${context.tr('currency_sar')}',
            style: TextStyle(
              color: colors.background,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBalanceCard(BuildContext context, PaymentViewModel viewModel) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: colors.warning, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('available_points'),
                  style: TextStyle(fontSize: 12, color: colors.textSub),
                ),
                Text(
                  '${viewModel.balance.bonusPoints.toInt()} ${context.tr('points')}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colors.text,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => viewModel.fetchBalance(),
            icon: Icon(Icons.refresh, color: colors.primary),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.qsColors.text),
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
    final colors = context.qsColors;
    bool isSelected = viewModel.selectedMethod == method;
    return GestureDetector(
      onTap: () => viewModel.setPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.textSub.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.primary : colors.textSub),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? colors.primary : colors.text,
              ),
            ),
            const Spacer(),
            Radio<PaymentMethod>(
              value: method,
              groupValue: viewModel.selectedMethod,
              activeColor: colors.primary,
              onChanged: (v) => viewModel.setPaymentMethod(v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsPaymentForm(BuildContext context, PaymentViewModel viewModel) {
    final colors = context.qsColors;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),    
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('confirm_points_payment_msg'),
                  style: TextStyle(fontSize: 13, color: colors.textSub),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: context.tr('points_to_pay'),
            hintText: '${context.tr('max_limit')}: ${widget.order.remainingAmount.toInt()}',
            labelStyle: TextStyle(color: colors.textSub),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            prefixIcon: Icon(Icons.stars_rounded, color: colors.warning),
            suffixText: context.tr('points'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.textSub.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBondPaymentForm(BuildContext context, PaymentViewModel viewModel) {
    final colors = context.qsColors;
    return Column(
      children: [
        // حقل المبلغ
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            labelText: context.tr('amount_to_pay'),
            labelStyle: TextStyle(color: colors.textSub),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            prefixIcon: Icon(Icons.attach_money, color: colors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colors.textSub.withValues(alpha: 0.2))),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
            ),
            child: viewModel.selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(viewModel.selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40, color: colors.textSub.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text(context.tr('upload_receipt'), style: TextStyle(color: colors.textSub)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, PaymentViewModel viewModel) {
    final colors = context.qsColors;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
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
    // final colors = context.qsColors;
    
    // 1. استخراج المبلغ المدفوع (سواء نقاط أو سند)
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      QSAlerts.showWarning(context, context.tr('enter_correct_amount'));
      return;
    }

    if (viewModel.selectedMethod == PaymentMethod.points) {
      // --- التحقق من النقاط ---
      
      // لا يقل عن 1
      if (amount < 1) {
        QSAlerts.showWarning(context, context.tr('min_points_error'));
        return;
      }

      // لا يتجاوز الرصيد
      if (amount > viewModel.balance.bonusPoints) {
        QSAlerts.showError(context, context.tr('no_points_balance'));
        return;
      }

      // لا يتجاوز المبلغ المتبقي
      if (amount > widget.order.remainingAmount) {
        QSAlerts.showWarning(context, context.tr('exceed_order_amount_error'));
        return;
      }

      // تأكيد
      final bool confirm = await QSAlerts.showConfirm(
        context,
        title: context.tr('confirm_points_payment'),
        message: '${context.tr('confirm_points_payment_msg')} ($amount ${context.tr('points')})',
      );

      if (confirm) {
        final success = await viewModel.payByPoints(widget.order.id, amount);
        if (success) {
          await QSAlerts.showSuccess(context, context.tr('points_payment_success'));
          if (context.mounted) Navigator.pop(context);
        } else {
          await QSAlerts.showError(context, viewModel.errorMessage ?? context.tr('points_payment_error'));
        }
      }
    } else {
      // --- سداد بسند ---
      
      final success = await viewModel.payByBond(widget.order.id, amount);
      if (success) {
        await QSAlerts.showSuccess(context, context.tr('bond_payment_success'));
        if (context.mounted) Navigator.pop(context);
      } else {
        await QSAlerts.showError(context, viewModel.errorMessage ?? context.tr('bond_payment_error'));
      }
    }
  }
}
