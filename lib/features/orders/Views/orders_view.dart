// مسار الملف: lib/features/orders/views/orders_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../ViewModels/orders_viewmodel.dart';
import '../Models/order_model.dart';
import 'order_detail_view.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import '../../../core/network/api_service.dart';
import '../../profile/viewmodels/profile_view_model.dart';
import '../../profile/view/profile_view.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../profile/models/profile_model.dart';

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
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('loginNowPrompt'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('ordersGuestMessage'),
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
                child: Text(
                  context.tr('login'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => viewModel.fetchOrders(),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            child: Text(
              context.tr('retry'),
              style: const TextStyle(color: Colors.white),
            ),
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
            style: TextStyle(
              fontSize: 18,
              color: colors.textSub,
              fontWeight: FontWeight.bold,
            ),
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
                  color: isSelected
                      ? Colors.transparent
                      : colors.textSub.withOpacity(0.2),
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

class _ProviderInfoRow extends StatefulWidget {
  final OrderModel order;
  final String displayServiceName;

  const _ProviderInfoRow({
    required this.order,
    required this.displayServiceName,
  });

  @override
  State<_ProviderInfoRow> createState() => _ProviderInfoRowState();
}

class _ProviderInfoRowState extends State<_ProviderInfoRow> {
  static final Map<int, ProfileModel> _profilesCache = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileIfNeeded();
  }

  void _loadProfileIfNeeded() async {
    final providerId = widget.order.providerId;
    if (providerId == null) return;
    if (_profilesCache.containsKey(providerId)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final repo = ProfileRepository(apiService);
      final profile = await repo.fetchUserProfile(providerId);

      _profilesCache[providerId] = profile;
    } catch (e) {
      debugPrint('❌ Error loading provider profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final providerId = widget.order.providerId;

    // استخدام البيانات المخبأة إن وجدت، وإلا نستخدم البيانات الحالية من الطلب
    final profile = providerId != null ? _profilesCache[providerId] : null;
    final String providerName = profile?.name ?? widget.order.providerName;
    final String providerImage =
        profile?.avatarUrl ?? widget.order.providerImage;

    return GestureDetector(
      onTap: providerId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => ProfileViewModel(
                      ProfileRepository(context.read<ApiService>()),
                      targetUserId: providerId,
                    ),
                    child: ProfileView(userId: providerId),
                  ),
                ),
              );
            }
          : null,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.background,
                ),
                child: ClipOval(
                  child: providerImage.isNotEmpty
                      ? Image.network(
                          providerImage,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_outline,
                              color: colors.textSub.withOpacity(0.5),
                              size: 36,
                            );
                          },
                        )
                      : Icon(
                          Icons.person_outline,
                          color: colors.textSub.withOpacity(0.5),
                          size: 36,
                        ),
                ),
              ),
              if (widget.order.isVerified ||
                  (profile?.verificationProvider ?? false))
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        providerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.text,
                        ),
                      ),
                    ),
                    if (providerId != null) ...[
                      if (_isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: colors.textSub.withOpacity(0.3),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.displayServiceName,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    // تحديد اسم الخدمة المعروض بناءً على الشروط المطلوبة
    final String displayServiceName;
    if (order.serviceName.trim() == '_custom') {
      displayServiceName = context.tr('custom_service');
    } else if (order.serviceName.trim() == '_meeting') {
      displayServiceName = context.tr('attendance_service');
    } else {
      displayServiceName = order.serviceName;
    }

    // تنسيق التاريخ فقط بدون الوقت
    final String displayDate = order.createdAt != null
        ? '${order.createdAt!.year}-${order.createdAt!.month.toString().padLeft(2, '0')}-${order.createdAt!.day.toString().padLeft(2, '0')}'
        : order.timeAgo;

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
          // 1. Header: Status and Time (تم مسح اللون الشفاف اللي خلفها)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, order.status),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined, // أيقونة التقويم
                      size: 16,
                      color: _getStatusColor(context, order.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayDate,
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
                // 2. Provider and Service Info (يعرض بيانات مزود الخدمة بشكل تفاعلي وديناميكي)
                _ProviderInfoRow(
                  order: order,
                  displayServiceName: displayServiceName,
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

                // 4. Action Buttons (تم الإبقاء على زر التفاصيل وتوسيعه ليكون ملائماً ومضبوطاً)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.textSub.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colors.textSub.withOpacity(0.1),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailView(order: order),
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
      case 'accepted_full_paid':
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
        textKey = 'in_progress';
        break;
      case 'accepted_partial_paid':
        textKey = 'accepted_partial_paid';
        break;
      case 'accepted_full_paid':
        textKey = 'accepted_full_paid';
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
