import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/core/widgets/service_card.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون رمادي فاتح مريح للخلفية
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المفضلة',
          style: TextStyle(
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
                    child: const Text('إعادة المحاولة'),
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
                          'لا توجد خدمات في المفضلة هنا',
                          style: TextStyle(color: colors.textSub),
                        ),
                      )
                    : RefreshIndicator(
                        color: colors.primary,
                        onRefresh: () => vm.refreshFavorites(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        reverse: true, // RTL support
        itemCount: vm.filterCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final category = vm.filterCategories[index];
          final isSelected = vm.selectedCategoryId == category.id;

          // تحويل النص إلى أيقونة
          IconData getIcon(String name) {
            switch (name) {
              case 'grid_view': return Icons.grid_view_rounded;
              case 'build_outlined': return Icons.build_outlined;
              case 'cleaning_services_outlined': return Icons.cleaning_services_outlined;
              case 'local_shipping_outlined': return Icons.local_shipping_outlined;
              default: return Icons.category_outlined;
            }
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
                    color: isSelected ? colors.primary : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Icon(
                    getIcon(category.iconPath),
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