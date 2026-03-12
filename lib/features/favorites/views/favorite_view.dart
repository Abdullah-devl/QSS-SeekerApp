import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/favorites/iewmodels/favorite_view_model.dart';
import 'package:seeker/features/home/models/service_model.dart';
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
        title: Text(
          'المفضلة',
          style: TextStyle(
            color: colors.text,
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
            return Center(child: Text(vm.errorMessage!));
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
                        onRefresh: () async {
                          // vm.refreshFavorites(); // أضف دالة التحديث في الـ ViewModel مستقبلاً
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: vm.filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final service = vm.filteredFavorites[index];
                            return _buildFavoriteCard(context, service, vm, colors);
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
        itemCount: vm.filterCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final category = vm.filterCategories[index];
          final isSelected = vm.selectedCategoryId == category.id;

          // تحويل النص إلى أيقونة (لأن الـ API قد لا يرسل IconData مباشرة)
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

  /// 💳 كرت الخدمة المفضلة (مطابق للتصميم)
  Widget _buildFavoriteCard(BuildContext context, ServiceModel service, FavoriteViewModel vm, dynamic colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔵 الجزء العلوي: التفاصيل يمين والصورة يسار (في واجهة RTL)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ التفاصيل والنصوص (يمين الكرت)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // القلب الأحمر + تاق القسم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => vm.removeFromFavorites(service.id),
                          child: const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service.categoryId == 1 ? 'صيانة منزلية' : 'تنظيف', // اسم تجريبي
                            style: TextStyle(color: colors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // العنوان والمزود
                    Text(
                      service.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.providerName,
                      style: TextStyle(color: colors.textSub, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // السعر والحالة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${service.price.toInt()} ر.س',
                                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                              ),
                              TextSpan(
                                text: ' / ساعة', // يمكن أن تأتي من المودل
                                style: TextStyle(color: colors.textSub, fontSize: 10, fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined, size: 12, color: colors.textSub),
                            const SizedBox(width: 4),
                            Text('متاح الآن', style: TextStyle(color: colors.textSub, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 2️⃣ الصورة والتقييم (يسار الكرت)
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EDE6), // لون بيج للصورة
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: service.imageUrl.isNotEmpty
                          ? Image.network(service.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox())
                          : Icon(Icons.home_repair_service, color: colors.primary.withOpacity(0.3), size: 30),
                    ),
                  ),
                  // بادج التقييم
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Text(
                            service.rating > 0 ? service.rating.toString() : 'جديد',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🔴 الجزء السفلي: زر حجز موعد
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // توجيه لشاشة تفاصيل الخدمة
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA), // رمادي فاتح جداً
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حجز موعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}