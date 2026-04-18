import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/core/widgets/service_card.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';

import 'package:seeker/l10n/app_localizations.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.favorites,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: colors.text),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FavoriteViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.refreshFavorites(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 1️⃣ شريط الفلترة العلوي (Categories Filter)
              _buildCategoriesFilter(vm, colors),
              
              const SizedBox(height: 16),
              
              // 2️⃣ قائمة الخدمات المفضلة
              Expanded(
                child: vm.filteredFavorites.isEmpty
                    ? Center(
                        child: Text(
                          l10n.no_results,
                          style: TextStyle(color: colors.textSub),
                        ),
                      )
                    : RefreshIndicator(
                        color: colors.primary,
                        onRefresh: () => vm.refreshFavorites(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                          itemCount: vm.filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final service = vm.filteredFavorites[index];
                            return ServiceCard(
                              service: service,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider(
                                      create: (context) => ServiceDetailsViewModel(
                                        context.read<HomeRepository>(),
                                      ),
                                      child: ServiceDetailsView(initialService: service),
                                    ),
                                  ),
                                );
                              },
                              onFavoriteToggle: () => vm.toggleFavorite(service),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // 🧩 المكونات (Widgets)
  // =========================================================================

  /// 🔘 شريط الفلترة العلوي
  Widget _buildCategoriesFilter(FavoriteViewModel vm, dynamic colors) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // تم إزالة reverse: true لجعل الاتجاه يعتمد على لوكال الجهاز تلقائياً
        itemCount: vm.filterCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final category = vm.filterCategories[index];
          final isSelected = vm.selectedCategoryId == category.id;
          final isArabic = Localizations.localeOf(context).languageCode == 'ar';

          // تحويل المسار أو الاسم إلى أيقونة مناسبة
          IconData getIcon(String? iconPath, String name) {
            final normalized = (iconPath ?? name).toLowerCase();
            if (normalized.contains('grid') || normalized.contains('الكل') || normalized == 'all' || name == vm.filterCategories.first.name) return Icons.grid_view_rounded;
            if (normalized.contains('build') || normalized.contains('صيانة')) return Icons.build_outlined;
            if (normalized.contains('clean') || normalized.contains('تنظيف')) return Icons.cleaning_services_outlined;
            if (normalized.contains('ship') || normalized.contains('نقل')) return Icons.local_shipping_outlined;
            if (normalized.contains('electric') || normalized.contains('كهربا')) return Icons.electrical_services_rounded;
            if (normalized.contains('plumb') || normalized.contains('سباكة')) return Icons.plumbing_rounded;
            if (normalized.contains('paint') || normalized.contains('دهان')) return Icons.format_paint_rounded;
            return Icons.category_outlined;
          }

          return GestureDetector(
            onTap: () => vm.selectCategory(category.id),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: colors.text.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Icon(
                    getIcon(category.iconPath, category.name),
                    color: isSelected ? Colors.white : colors.textSub,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colors.primary : colors.textSub,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}