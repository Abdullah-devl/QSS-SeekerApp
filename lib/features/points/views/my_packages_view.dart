import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../viewmodels/points_viewmodel.dart';

class MyPackagesView extends StatefulWidget {
  const MyPackagesView({super.key});

  @override
  State<MyPackagesView> createState() => _MyPackagesViewState();
}

class _MyPackagesViewState extends State<MyPackagesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsViewModel>().fetchMyPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PointsViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.tr('myPackages'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.fetchMyPackages(),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.myPackages.isEmpty
            ? _buildEmptyState(colors)
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: vm.myPackages.length,
                itemBuilder: (context, index) {
                  final package = vm.myPackages[index];
                  return _buildPackageItem(package, colors);
                },
              ),
      ),
    );
  }

  Widget _buildPackageItem(Map<String, dynamic> package, dynamic colors) {
    // استخراج البيانات بناءً على هيكل الـ API المتوقع
    final String name =
        package['package']?['name'] ?? context.tr('defaultPackageName');
    final String status = package['status'] ?? 'pending';
    final String date =
        package['created_at']?.toString().split('T').first ?? '';
    final String price = package['package']?['price']?.toString() ?? '0';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = colors.success;
        statusText = context.tr('approved');
        break;
      case 'rejected':
        statusColor = colors.error;
        statusText = context.tr('rejected');
        break;
      default:
        statusColor = colors.warning;
        statusText = context.tr('pendingStatus');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_edu_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('dateLabel')}: $date',
                  style: TextStyle(fontSize: 12, color: colors.textSub),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$price ${context.tr('currency_sar')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: colors.textSub.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('noPurchasedPackages'),
            style: TextStyle(color: colors.textSub, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
