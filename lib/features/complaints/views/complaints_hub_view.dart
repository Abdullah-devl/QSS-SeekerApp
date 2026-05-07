import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'system_complaints_list_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../repositories/complaints_repository.dart';
import '../viewmodels/order_complaints_viewmodel.dart';
import 'order_complaints_list_view.dart';

class ComplaintsView extends StatelessWidget {
  const ComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          'مركز الشكاوى والبلاغات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHubCard(
              context,
              title: 'شكاوى النظام',
              description: 'أبلغ عن مشكلة تقنية أو قدم اقتراحاً لتحسين التطبيق',
              icon: Icons.settings_suggest_rounded,
              color: colors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SystemComplaintsListView()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildHubCard(
              context,
              title: 'شكاوى الطلبات',
              description: 'لديك مشكلة في طلب معين؟ قدم بلاغاً وسنقوم بمساعدتك',
              icon: Icons.assignment_rounded,
              color: Colors.orange.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider(
                      create: (c) => OrderComplaintsViewModel(
                        ComplaintsRepository(c.read<ApiService>()),
                      ),
                      child: const OrderComplaintsListView(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.qsColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.qsColors.text.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.qsColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: context.qsColors.textSub, size: 16),
          ],
        ),
      ),
    );
  }
}


