// مسار الملف: lib/features/orders/views/orders_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../ViewModels/orders_viewmodel.dart';
import '../Models/order_model.dart';
import 'order_detail_view.dart';
import '../../../core/utils/qs_alerts.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  @override
  void initState() {
    super.initState();
    // جلب الطلبات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚀 📦 OrdersView: استدعاء fetchOrders...');
      context.read<OrdersViewModel>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _OrdersBody();
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrdersViewModel>(context);
    final colors = context.qsColors;
    final userRole = context.select<HomeViewModel, String>((vm) => vm.role);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('myOrders'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: userRole == 'guest'
          ? _buildGuestPrompt(context, colors)
          : Column(
              children: [
                _buildTabs(context, viewModel),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.textSub.withOpacity(0.1),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
                          ),
                        )
                      : viewModel.errorMessage != null
                      ? _buildErrorWidget(context, viewModel)
                      : RefreshIndicator(
                          color: colors.primary,
                          onRefresh: () => viewModel.fetchOrders(),
                          child: viewModel.filteredOrders.isEmpty
                              ? _buildEmptyState(context)
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 100,
                                  ),
                                  itemCount: viewModel.filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    return _OrderCardWidget(
                                      order: viewModel.filteredOrders[index],
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
    );
  }

  /// 🛠️ واجهة تظهر للزائر تطلب منه تسجيل الدخول
  Widget _buildGuestPrompt(BuildContext context, dynamic colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 80, color: colors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'سجل دخولك الآن',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'يرجى تسجيل الدخول لمتابعة طلباتك والوصول إلى سجل العمليات الخاصة بك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.textSub,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, OrdersViewModel viewModel) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: colors.error),
          const SizedBox(height: 16),
          Text(
            context.tr('error_loading_orders'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => viewModel.fetchOrders(),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            child: Text(context.tr('retry'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: colors.textSub.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_orders_yet'),
            style: TextStyle(fontSize: 18, color: colors.textSub, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, OrdersViewModel viewModel) {
    final colors = context.qsColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(viewModel.tabs.length, (index) {
          final isSelected = viewModel.selectedTabIndex == index;
          return GestureDetector(
            onTap: () => viewModel.changeTab(index),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : colors.textSub.withOpacity(0.2),
                ),
              ),
              child: Text(
                context.tr(viewModel.tabs[index]),
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.textSub,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  const _OrderCardWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Status and Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(context, order.status).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, order.status),
                Row(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      size: 16,
                      color: _getStatusColor(context, order.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.timeAgo,
                      style: TextStyle(
                        color: _getStatusColor(context, order.status),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Client and Service Info
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: colors.background,
                          backgroundImage: order.providerImage.isNotEmpty
                              ? NetworkImage(order.providerImage)
                              : null,
                          child: order.providerImage.isEmpty
                              ? Icon(
                                  Icons.person_outline,
                                  color: colors.textSub.withOpacity(0.5),
                                  size: 36,
                                )
                              : null,
                        ),
                        if (order.isVerified)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: colors.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: colors.primary,
                                size: 20,
                              ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.textSub.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.serviceName,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Price and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: colors.textSub.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textSub,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('total_price_label'),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSub.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${order.price.toInt()}',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              TextSpan(
                                text: ' ${context.tr('currency_sar')}',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(height: 1, color: colors.textSub.withOpacity(0.1)),
                const SizedBox(height: 24),

                // 4. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colors.textSub.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colors.textSub.withOpacity(0.1)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailView(order: order),
                            ),
                          );
                        },
                        child: Text(
                          context.tr('details'),
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    if (order.status != 'canceled' &&
                        order.status != 'cancelled' &&
                        order.status != 'completed')
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final viewModel = context.read<OrdersViewModel>();
                            
                            // 1️⃣ إظهار تنبيه تأكيد قبل الإلغاء
                            final confirmed = await QSAlerts.showConfirm(
                              context,
                              title: context.tr('confirm_cancel_title'),
                              message: context.tr('confirm_cancel_message'),
                            );

                            if (!confirmed) return;

                            // 2️⃣ تنفيذ عملية الإلغاء
                            final success = await viewModel.updateStatus(
                              order.id,
                              'cancelled',
                            );

                            if (success) {
                              // 3️⃣ الانتظار حتى يرى المستخدم رسالة النجاح ويضغط موافق
                              if (context.mounted) {
                                await QSAlerts.showSuccess(
                                  context,
                                  context.tr('order_cancelled_success'),
                                );
                              }
                            } else {
                              // إظهار رسالة الخطأ والانتظار
                              if (context.mounted) {
                                await QSAlerts.showError(
                                  context, 
                                  viewModel.errorMessage ?? context.tr('order_cancelled_error'),
                                );
                              }
                            }
                          },
                          child: Text(
                            context.tr('cancel_order'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
      case 'new_order':
        return context.qsColors.primary;
      case 'accepted':
      case 'in_progress':
      case 'accepted_initial':
      case 'accepted_partial_paid':
        return context.qsColors.warning;
      case 'completed':
      case 'finished':
        return context.qsColors.success;
      case 'canceled':
      case 'cancelled':
      case 'rejected':
        return context.qsColors.error;
      case 'suspended':
        return context.qsColors.textSub;
      default:
        return context.qsColors.primary;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    String textKey;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
      case 'new_order':
        textKey = 'new_order';
        break;
      case 'accepted':
      case 'accepted_initial':
        textKey = 'accepted_initial';
        break;
      case 'in_progress':
      case 'accepted_partial_paid':
        textKey = 'in_progress';
        break;
      case 'completed':
      case 'finished':
        textKey = 'completed';
        break;
      case 'canceled':
      case 'cancelled':
      case 'rejected':
        textKey = 'canceled';
        break;
      default:
        textKey = 'status_$status';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(context, status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.tr(textKey).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
