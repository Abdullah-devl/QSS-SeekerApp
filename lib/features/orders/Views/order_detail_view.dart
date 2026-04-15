import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';
import '../Models/order_model.dart';
import '../ViewModels/orders_viewmodel.dart';
import '../../../core/network/api_endpoints.dart';
import '../../payment/views/payment_view.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إحداثيات افتراضية
    final double lat = widget.order.latitude ?? 24.7136;
    final double lng = widget.order.longitude ?? 46.6753;
    final bool hasCoordinates =
        widget.order.latitude != null && widget.order.longitude != null;

    final viewModel = Provider.of<OrdersViewModel>(context);
    // البحث عن أحدث نسخة من الطلب في القائمة الكلية لضمان تحديث البيانات
    final currentOrder = viewModel.allOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // 🕵️ طباعة بيانات التشخيص عند بناء الصفحة
    debugPrint(
      '🔍 [VIEW] Displaying OrderDetailView for ID: ${currentOrder.id}',
    );
    if (currentOrder.rawJson != null) {
      debugPrint('📦 [VIEW] Raw JSON for this Order: ${currentOrder.rawJson}');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            context.tr('details'),
            style: const TextStyle(
              color: Color(0xFF1D2126),
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => viewModel.refreshOrderDetail(currentOrder.id),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUnifiedRequestCard(context, currentOrder),
                    const SizedBox(height: 32),

                    // 📂 قسم السندات (Receipts)
                    if (currentOrder.bonds.isNotEmpty) ...[
                      _buildSectionHeader(context, 'order_bonds'),
                      const SizedBox(height: 12),
                      _buildReceiptsList(currentOrder),
                      const SizedBox(height: 32),
                    ],

                    // 💰 قسم إدارة الدفع والحالة (تتبع الحالة والمبالغ)
                    Column(
                      key: ValueKey('payment_section_${currentOrder.status}'),
                      children: [
                        _buildPaymentManagerSection(
                          context,
                          viewModel,
                          currentOrder,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                    _buildComplaintButton(context, viewModel, currentOrder),
                    const SizedBox(height: 32),

                    _buildLocationSectionHeader(context, currentOrder),
                    const SizedBox(height: 12),
                    _buildLocationMapCard(
                      context,
                      lat,
                      lng,
                      hasCoordinates,
                      currentOrder,
                    ),
                    const SizedBox(height: 24),
                    _buildInlineCompleteOrderButton(context, viewModel, currentOrder),
                    const SizedBox(height: 48),

                    _buildTotalPriceSection(context, currentOrder),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black26.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActions(
          context,
          viewModel,
          currentOrder,
        ),
      ),
    );
  }

  // --- المكونات الفرعية (Sub-widgets) ---

  Widget _buildSectionHeader(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6E7C87),
      ),
    );
  }

  Widget _buildReceiptsList(OrderModel order) {
    return SizedBox(
      height: 140, // زيادة الارتفاع قليلًا للمبلغ
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: order.bonds.length,
        itemBuilder: (context, index) {
          final bond = order.bonds[index];
          return Container(
            width: 120, // زيادة العرض
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: bond.imagePath.isNotEmpty
                        ? Image.network(
                            bond.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : const Icon(Icons.receipt_long, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Text(
                        bond.bondNumber,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${bond.amount.toInt()} ${context.tr('currency_sar')}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1CB0F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentManagerSection(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    final bool isCompleted = order.status == 'completed';
    final bool isCancelled = order.status == 'cancelled' || order.status == 'canceled';
    final bool isRejected = order.status == 'rejected';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // 1. بطاقات الإحصاءات (Cards Row)
          Row(
            children: [
              _buildSummaryCard(
                context,
                context.tr('paid_amount'),
                '${order.paidAmount}',
                const Color(0xFFE8F6FF),
                const Color(0xFF1CB0F6),
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                context.tr('currently_paid_percent'), // Actual Paid %
                '${((order.paidAmount / order.price) * 100).toStringAsFixed(0)}%',
                const Color(0xFFE8F5E9),
                const Color(0xFF2ECC71),
                hasBorder: true,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                context.tr('remaining_amount'),
                '${order.remainingAmount}',
                const Color(0xFFFFF1F1),
                const Color(0xFFFF5252),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // عرض النسبة المطلوبة (التعميد) بشكل منفصل وأنيق
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('required_partial_percentage_label', args: {'percentage': order.requiredPartialPercentage}),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. شيبس تتبع الحالة (Status Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  'pending',
                  context.tr('status_pending'),
                  order.status,
                  const Color(0xFFFF9800),
                  const Color(0xFFFFF3E0),
                ),
                _buildStatusChip(
                  'accepted_initial',
                  context.tr('accepted_initial'),
                  order.status,
                  const Color(0xFF1E88E5),
                  const Color(0xFFE3F2FD),
                ),
                _buildStatusChip(
                  'accepted_partial_paid',
                  context.tr('in_progress'),
                  order.status,
                  const Color(0xFF673AB7),
                  const Color(0xFFEDE7F6),
                ),
                _buildStatusChip(
                  'completed',
                  context.tr('completed'),
                  order.status,
                  const Color(0xFF43A047),
                  const Color(0xFFE8F5E9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. زر دفع تكاليف الخدمة أو رسالة الحالة
          if (isCancelled || isRejected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isCancelled ? const Color(0xFFFFF5F5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCancelled ? const Color(0xFFFFE0E0) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCancelled ? Icons.cancel_rounded : Icons.block_flipped,
                    color: isCancelled ? const Color(0xFFFF4757) : const Color(0xFF64748B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCancelled ? context.tr('order_cancelled_msg') : context.tr('order_rejected_msg'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isCancelled ? const Color(0xFFFF4757) : const Color(0xFF64748B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            )
          else if (!isCompleted)
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB0F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentView(order: order),
                          ),
                        );
                      },
                icon: const Icon(Icons.payment_rounded, size: 24),
                label: Text(
                  context.tr('pay_service_costs'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color bg,
    Color textColor, {
    bool hasBorder = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: hasBorder ? Border.all(color: const Color(0xFFE8F6FF)) : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            if (!label.contains('%'))
              Text(
                context.tr('currency_sar'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  int currentStatusIndex(String status) {
    switch (status) {
      case 'pending':
      case 'new':
        return 0;
      case 'accepted':
      case 'accepted_initial':
        return 1;
      case 'in_progress':
      case 'accepted_partial_paid':
        return 2;
      case 'completed':
      case 'finished':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildStatusChip(
    String code,
    String label,
    String currentStatus,
    Color color,
    Color bgColor,
  ) {
    bool isActive = false;
    bool isPast = false;

    int currentIndex = currentStatusIndex(currentStatus);
    int chipIndex = currentStatusIndex(code);

    if (currentIndex == chipIndex) isActive = true;
    if (currentIndex > chipIndex) isPast = true;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? bgColor
            : (isPast ? bgColor.withOpacity(0.4) : const Color(0xFFF9FAFB)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? color
              : (isPast ? color.withOpacity(0.5) : const Color(0xFFF1F5F9)),
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.stars, color: color, size: 16),
            ),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? color.withOpacity(0.9)
                  : (isPast ? color.withOpacity(0.7) : const Color(0xFF94A3B8)),
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              fontSize: isActive ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    // 🚦 التحقق من الحالة: لا يمكن إضافة مبلغ إذا كان الطلب لا يزال "في الانتظار"
    final bool canPay = currentStatusIndex(order.status) > 0;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: canPay
            ? const Color(0xFF1CB0F6)
            : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: viewModel.isLoading ? 0 : 0,
      ),
      onPressed: (viewModel.isLoading || !canPay)
          ? null
          : () async {
              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('enter_correct_amount'))),
                );
                return;
              }
              debugPrint(
                '🎯 [VIEW] User clicked Add Amount for Order ID: ${order.id}',
              );
              final success = await viewModel.addPaidAmount(order.id, amount);
              if (success) {
                _amountController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('amount_updated_success'))),
                );
              }
            },
      icon: viewModel.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(canPay ? Icons.send_rounded : Icons.lock_outline, size: 20),
      label: Text(
        viewModel.isLoading
            ? context.tr('loading')
            : (canPay ? context.tr('send_amount') : context.tr('accept_first')),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUnifiedRequestCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👨‍🔧 1. رأس البطاقة: بيانات مزود الخدمة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFF1F5F9),
                        image: order.providerImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(order.providerImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: order.providerImage.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF90A4AE),
                            )
                          : null,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.providerName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D2126),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.providerPhone.isNotEmpty
                                ? order.providerPhone
                                : '---',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                          if (order.providerPhone.isNotEmpty) ...[
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              icon: Icon(
                                Icons.copy,
                                size: 16,
                                color: Colors.blue.shade300,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: order.providerPhone),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.tr('copySuccess')),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.providerEmail.isNotEmpty
                                  ? order.providerEmail
                                  : '---',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF90A4AE),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  Icons.phone_in_talk_outlined,
                  const Color(0xFFE8F5E9),
                  const Color(0xFF2ECC71),
                  onTap: () async {
                    if (order.providerPhone.isNotEmpty) {
                      final Uri url = Uri.parse('tel:${order.providerPhone}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  Icons.chat_bubble_outline,
                  const Color(0xFFE8F6FF),
                  const Color(0xFF1CB0F6),
                ),
              ],
            ),
          ),

          // 🏦 2. بيانات الحسابات البنكية
          if (order.providerBanks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('provider_bank_accounts_label'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.providerBanks.map(
                    (bank) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            size: 20,
                            color: Color(0xFF1CB0F6),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.bankName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  bank.iban,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: bank.iban));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم نسخ رقم الآيبان'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 📝 2. وصف الطلب
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'description_label'),
                const SizedBox(height: 8),
                Text(
                  order.description ?? '---',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A6B7A),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 🛠️ 3. تفاصيل الخدمة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'service_details_title'),
                const SizedBox(height: 20),
                
                // 🏷️ الخدمة الأساسية
                Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        image: (order.mainServiceImage != null && order.mainServiceImage!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage("${ApiEndpoints.storageBaseUrl}${order.mainServiceImage}"),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (order.mainServiceImage == null || order.mainServiceImage!.isEmpty)
                          ? const Icon(Icons.miscellaneous_services, color: Color(0xFF1CB0F6), size: 28)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1D2126),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${context.tr('main_service')} • 1 x ${order.mainServicePrice.toInt()} ${context.tr('currency_sar')}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${order.mainServicePrice.toInt()} ${context.tr('currency_sar')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1CB0F6),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 🌿 الخدمات الفرعية
                if (order.subServices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        "لا توجد خدمات فرعية",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...order.subServices.map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1CB0F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                                Text(
                                  "${sub.quantity} x ${sub.price.toInt()} ${context.tr('currency_sar')}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(sub.price * sub.quantity).toInt()} ${context.tr('currency_sar')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 🏁 المجموع الكلي للقسم
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "المجموع الإجمالي",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D2126),
                        ),
                      ),
                      Text(
                        '${order.price.toInt()} ${context.tr('currency_sar')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1CB0F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSectionTitle(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Color(0xFF90A4AE),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    Color bg,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildLocationSectionHeader(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader(context, 'location_label'),
        Row(
          children: [
            const Icon(Icons.near_me, color: Color(0xFF1CB0F6), size: 16),
            const SizedBox(width: 6),
            Text(
              context.tr('distance_away', args: {'distance': order.distance}),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationMapCard(
    BuildContext context,
    double lat,
    double lng,
    bool hasCoordinates,
    OrderModel order,
  ) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(
            'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/pin-s+ff4d4d($lng,$lat)/$lng,$lat,13/600x400?access_token=pk.placeholder',
          ),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Color(0xFFFF4D4D), size: 40),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Text(
                order.location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D2126),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPriceSection(BuildContext context, OrderModel order) {
    return Column(
      children: [
        Text(
          context.tr('total_order_price'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF90A4AE),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${order.price.toInt()}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('currency_sar'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget? _buildBottomActions(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    // 🚦 زر الإلغاء (يظهر فقط إذا لم يكتمل الطلب ولم يُلغى)
    final bool canCancel =
        order.status != 'canceled' &&
        order.status != 'cancelled' &&
        order.status != 'completed' &&
        order.status != 'rejected';

    if (!canCancel) return null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF5A6B7A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final success = await viewModel.updateStatus(
                    order.id,
                    'cancelled',
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('order_cancelled_success')),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
          icon: viewModel.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFF5A6B7A),
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.cancel_outlined, size: 24),
          label: Text(
            viewModel.isLoading ? context.tr('loading') : context.tr('cancel_order'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineCompleteOrderButton(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    if (!order.providerFinished || order.status == 'completed' || order.status == 'finished') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          onPressed: viewModel.isLoading
              ? null
              : () {
                  if (order.status == 'accepted_partial_paid') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(context.tr('alert')),
                          ],
                        ),
                        content: Text(
                          context.tr('must_complete_payment'),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(context.tr('ok')),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  _showConfirmationDialog(context, viewModel, order);
                },
          icon: viewModel.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle_outline, size: 24),
          label: Text(
            viewModel.isLoading ? context.tr('loading') : context.tr('complete_order'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }

  // 🚀 نافذة تأكيد إكمال الطلب الكبرى
  void _showConfirmationDialog(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirm_completion_title')),
        content: Text(context.tr('confirm_completion_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel_order')), // استخدام كلمة إلغاء العامة
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق التنبيه
              _showReviewDialog(context, viewModel, order); // الانتقال للتقييم
            },
            child: Text(context.tr('ok')),
          ),
        ],
      ),
    );
  }

  // 🚀 نافذة التقييم والتعليق (The Feedback UI)
  void _showReviewDialog(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    double selectedRating = 5.0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن الإغلاق إلا بالإرسال أو الإلغاء
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFA502)),
                const SizedBox(width: 8),
                Text(context.tr('rate_service_title')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.tr('rate_service_message')),
                  const SizedBox(height: 24),
                  // اختيار النجوم (Rating Stars)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFFA502),
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // حقل التعليق
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.tr('comment_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: viewModel.isLoading ? null : () => Navigator.pop(context),
                child: Text(context.tr('cancel_order')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB0F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.completeOrderWithReview(
                          id: order.id,
                          rating: selectedRating,
                          comment: commentController.text,
                        );

                        if (success) {
                          Navigator.pop(dialogCtx); // إغلاق النافذة
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.tr('order_completed_success'))),
                          );
                        } else {
                          // يبقى داخل الأليرت ويعرض الخطأ إذا وجد
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.tr('review_submitted_error'))),
                          );
                        }
                      },
                child: viewModel.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(context.tr('submit_review')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommissionCard(BuildContext context, OrderModel order) {
    // محاولة جلب قيمة العمولة من البيانات الخام، أو حسابها افتراضياً بنسبة 10%
    final double commissionAmount =
        double.tryParse(order.rawJson?['order_commission']?.toString() ?? '') ??
        (order.price * 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9DB), Color(0xFFFFF4D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFA502).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA502).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA502),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('platform_commission'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E00),
                  ),
                ),
              ),
              Text(
                '${commissionAmount.toInt()} ${context.tr('currency_sar')}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD48100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFFFA502), thickness: 0.5),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_order_value_label', args: {'price': order.price.toInt()}),
                style: const TextStyle(fontSize: 11, color: Color(0xFF8B5E00)),
              ),
              Text(
                context.tr('commission_percentage_label', args: {'percentage': '10'}),
                style: const TextStyle(fontSize: 11, color: Color(0xFF8B5E00)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚨 زر إرسال شكوى على الطلب
  Widget _buildComplaintButton(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    // يظهر الزر فقط إذا تم دفع المبلغ (جزئياً أو كلياً)
    final bool canComplain =
        order.status == 'accepted_partial_paid' ||
        order.status == 'accepted_full_paid';

    if (!canComplain) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showComplaintDialog(context, viewModel, order),
        icon: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
        label: Text(
          context.tr('send_complaint'),
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo',
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // 📝 واجهة إرسال الشكوى
  void _showComplaintDialog(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? selectedType;

    final List<Map<String, String>> complaintTypes = [
      {'key': 'delay', 'label': context.tr('type_delay')},
      {'key': 'quality', 'label': context.tr('type_quality')},
      {'key': 'behavior', 'label': context.tr('type_behavior')},
      {'key': 'price', 'label': context.tr('type_price')},
      {'key': 'other', 'label': context.tr('type_other')},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  const Icon(Icons.report, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('send_complaint'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // نوع الشكوى (Dropdown)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: context.tr('complaint_type'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: complaintTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['key'],
                          child: Text(type['label']!),
                        );
                      }).toList(),
                      onChanged: (value) => setDialogState(() => selectedType = value),
                    ),
                    const SizedBox(height: 16),
                    // عنوان الشكوى
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: context.tr('complaint_title'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // محتوى الشكوى
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: context.tr('complaint_content'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (selectedType == null ||
                              titleController.text.isEmpty ||
                              contentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                            );
                            return;
                          }

                          final success = await viewModel.submitComplaint(
                            requestId: order.id,
                            title: titleController.text,
                            type: selectedType!,
                            content: contentController.text,
                          );

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('complaint_success'))),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('complaint_error'))),
                            );
                          }
                        },
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(context.tr('complaint_submit')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
