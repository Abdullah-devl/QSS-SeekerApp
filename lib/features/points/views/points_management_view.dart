import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/localization/app_localizations.dart';

class PointsManagementView extends StatelessWidget {
  const PointsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.tr('pointsManagementTitle'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildOptionCard(
              context: context,
              title: context.tr('myPackages'),
              subtitle: context.tr('myPackagesSubtitle'),
              icon: Icons.inventory_2_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.myPackages),
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context: context,
              title: context.tr('pointsPackages'),
              subtitle: context.tr('pointsPackagesSubtitle'),
              icon: Icons.grid_view_rounded,
              onTap: () => Navigator.pushNamed(context, AppRoutes.availablePackages),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.qsColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.text.withValues(alpha: 0.05),
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
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.textSub),
          ],
        ),
      ),
    );
  }
}
