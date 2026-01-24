import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    // دالة بناء شريط التنقل
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
      height: 70,
      decoration: BoxDecoration(
        color: context.qsColors.primary,
        borderRadius: BorderRadius.circular(30), // حواف دائرية
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.01),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            0,
            Icons.home_filled,
            AppRoutes.home,
          ), // زر الصفحة الرئيسية
          _buildNavItem(
            context,
            1,
            Icons.assignment_outlined,
            AppRoutes.orders,
          ),
          _buildSearchItem(context, 2), // زر البحث في المنتصف
          _buildNavItem(context, 3, Icons.favorite_border, AppRoutes.favorites),
          _buildNavItem(
            context,
            4,
            Icons.settings_outlined,
            AppRoutes.settings,
          ),
        ],
      ),
    );
  }

  // دالة بناء عنصر التنقل
  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = currentIndex == index;
    final colors = context.qsColors;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colors.text : colors.textSub,
              size: 24, // حجم الأيقونة24
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.text : colors.textSub,
                fontSize: 12, //` حجم الخط 12
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة زر البحث
  Widget _buildSearchItem(BuildContext context, int index) {
    final colors = context.qsColors;
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.search,
          color: isSelected ? colors.text : colors.textSub,
          size: 28,
        ),
      ),
    );
  }
}
