import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
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
        title: const Text('باقاتي', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final String name = package['package']?['name'] ?? 'باقة نقاط';
    final String status = package['status'] ?? 'pending';
    final String date = package['created_at']?.toString().split('T').first ?? '';
    final String price = package['package']?['price']?.toString() ?? '0';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'مقبول';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
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
            child: Icon(Icons.history_edu_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'التاريخ: $date',
                  style: TextStyle(fontSize: 12, color: colors.textSub),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$price ر.س',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
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
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
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
          Icon(Icons.inventory_2_outlined, size: 64, color: colors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'لا توجد باقات مشتراة حالياً',
            style: TextStyle(color: colors.textSub, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
