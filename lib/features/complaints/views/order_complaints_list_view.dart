import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/features/orders/Models/order_model.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/orders/Repository/orders_repository.dart';
import '../viewmodels/order_complaints_viewmodel.dart';
import '../models/request_complaint_model.dart';
import '../../orders/views/order_detail_view.dart';
import '../../orders/viewmodels/orders_viewmodel.dart';
import 'package:seeker/l10n/app_localizations.dart';

class OrderComplaintsListView extends StatefulWidget {
  const OrderComplaintsListView({super.key});

  @override
  State<OrderComplaintsListView> createState() =>
      _OrderComplaintsListViewState();
}

class _OrderComplaintsListViewState extends State<OrderComplaintsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderComplaintsViewModel>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderComplaintsViewModel>();
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.orderComplaintsTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.card,
        foregroundColor: colors.text,
      ),
      body: _buildBody(context, vm, colors),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderComplaintsViewModel vm,
    dynamic colors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                vm.errorMessage!,
                style: TextStyle(color: colors.error, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.fetchComplaints(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                ),
                child: Text(
                  l10n.retry,
                  style: TextStyle(color: colors.card),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.complaints.isEmpty) {
      return Center(
        child: Text(
          l10n.noOrderComplaints,
          style: TextStyle(color: colors.textSub, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.card,
      onRefresh: () async => await vm.fetchComplaints(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.complaints.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final complaint = vm.complaints[index];
          return _buildComplaintCard(context, complaint, colors);
        },
      ),
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    RequestComplaintModel complaint,
    dynamic colors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // تحديد لون وحالة الشكوى بناءً على الحالة
    final String statusText;
    final Color statusColor;

    final String statusKey = complaint.status.toLowerCase();
    if (statusKey == 'resolved' || statusKey == 'solved') {
      statusColor = colors.success;
    } else if (statusKey == 'closed') {
      statusColor = colors.textSub;
    } else if (statusKey == 'rejected' || statusKey == 'cancelled' || statusKey == 'canceled') {
      statusColor = colors.error;
    } else if (statusKey == 'in_progress' || statusKey == 'processing') {
      statusColor = colors.primary;
    } else {
      statusColor = colors.warning;
    }

    if (complaint.statusLabel != null && complaint.statusLabel!.isNotEmpty) {
      statusText = complaint.statusLabel!;
    } else {
      if (statusKey == 'resolved' || statusKey == 'solved') {
        statusText = l10n.statusResolved;
      } else if (statusKey == 'closed') {
        statusText = l10n.statusClosed;
      } else if (statusKey == 'rejected') {
        statusText = l10n.statusRejected;
      } else if (statusKey == 'in_progress' || statusKey == 'processing') {
        statusText = l10n.statusInProgress;
      } else {
        statusText = l10n.statusPending;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.orderNo} #${complaint.orderId ?? "N/A"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            complaint.content,
            style: TextStyle(color: colors.textSub, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(complaint.createdAt),
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
              if (complaint.orderId != null)
                TextButton.icon(
                  onPressed: () {
                    // الانتقال إلى شاشة تفاصيل الطلب مع تمرير ViewModel إذا لزم الأمر
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (ctx) => OrdersViewModel(
                            OrdersRepository(ctx.read<ApiService>()),
                          ),
                          child: OrderDetailView(
                            order: OrderModel(
                              id: complaint.orderId.toString(),
                              customerName: l10n.loading,
                              serviceName: l10n.loading,
                              customerImage: '',
                              customerPhone: '',
                              price: 0,
                              location: '',
                              timeAgo: '',
                              subServices: [],
                              status: 'pending',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: colors.primary,
                  ),
                  label: Text(
                    l10n.viewOrder,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: colors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
