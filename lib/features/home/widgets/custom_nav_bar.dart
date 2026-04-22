import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';

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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: colors.background.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.text.withValues(alpha: 0.05),
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
                    AppLocalizations.of(context)!.home,
                  ), // زر الصفحة الرئيسية
                  _buildNavItem(
                    context,
                    1,
                    Icons.assignment_outlined,
                    AppLocalizations.of(context)!.myOrders,
                  ),
                  _buildSearchItem(context, 2), // زر البحث في المنتصف
                  _buildNavItem(
                    context,
                    3,
                    Icons.favorite_border,
                    AppLocalizations.of(context)!.favorites,
                  ),
                  _buildNavItem(
                    context,
                    4,
                    Icons.settings_outlined,
                    AppLocalizations.of(context)!.settings,
                  ),
                ],
              ),
            ),
          ),
        ),
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
