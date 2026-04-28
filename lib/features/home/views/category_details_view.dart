import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/core/widgets/service_card.dart';
import '../models/category_model.dart';
import '../services/models/service_model.dart';
import '../repositories/home_repository.dart';
import '../viewmodels/category_details_view_model.dart';
import 'package:seeker/core/routes/app_routes.dart'; // ✅ إضافة الاستيراد المفقود

/// 📂 اسم الملف: category_details_view.dart
/// 📝 الوصف: صفحة تفاصيل التصنيف بالتصميم الأفقي الأنيق ومتوافقة مع الثيم الخاص (qsColors).
class CategoryDetailsView extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailsView({super.key, required this.category});

  @override
  State<CategoryDetailsView> createState() => _CategoryDetailsViewState();
}

class _CategoryDetailsViewState extends State<CategoryDetailsView> {
  @override
  void initState() {
    super.initState();
    // 🚀 جلب البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryDetailsViewModel>().fetchCategoryDetails(
        widget.category.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background, // 🎨 لون الخلفية من الثيم الخاص بك
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.background, // 🎨 لون الـ AppBar من الثيم
        elevation: 0,
        leading: BackButton(color: colors.text),
      ),
      body: Consumer<CategoryDetailsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (vm.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                vm.errorMessage,
                style: TextStyle(color: colors.text),
              ),
            );
          }

          final data = vm.data;

          return RefreshIndicator(
            onRefresh: () => vm.fetchCategoryDetails(widget.category.id),
            color: colors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ التصنيفات الفرعية (Sub Categories)
                  if (data.subCategories.isNotEmpty) ...[
                    _buildSectionTitle('التصنيفات الفرعية', colors),
                    const SizedBox(height: 12),
                    _buildSubCategoriesList(data.subCategories, colors),
                    const SizedBox(height: 24),
                  ],

                  // 2️⃣ الموصى بهم (Recommended Providers)
                  if (data.recommendedProviders.isNotEmpty) ...[
                    _buildSectionTitle('الموصى بهم', colors),
                    const SizedBox(height: 12),
                    _buildProvidersList(data.recommendedProviders, colors),
                    const SizedBox(height: 24),
                  ],

                  // 3️⃣ الخدمات (Services) بتصميم screen.png المطابق
                  if (data.services.isNotEmpty) ...[
                    _buildSectionTitle('الخدمات المتاحة', colors),
                    const SizedBox(height: 12),
                    _buildServicesList(data.services, colors),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'لا توجد بيانات متاحة لهذا التصنيف حالياً',
                          style: TextStyle(color: colors.textSub),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🏷️ عنوان القسم
  Widget _buildSectionTitle(String title, dynamic colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
    );
  }

  /// 📦 قائمة التصنيفات الفرعية
  Widget _buildSubCategoriesList(
    List<CategoryModel> categories,
    dynamic colors,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL support
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.categoryDetails,
                arguments: cat,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  cat.iconPath.isNotEmpty
                      ? (cat.iconPath.startsWith('http') 
                          ? Image.network(cat.iconPath, width: 30, height: 30)
                          : Image.asset(cat.iconPath, width: 30, height: 30))
                      : Icon(Icons.category, color: colors.primary, size: 30),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 👨‍🔧 قائمة مقدمي الخدمات الموصى بهم
  Widget _buildProvidersList(List<dynamic> providers, dynamic colors) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL support
        itemCount: providers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final provider = providers[index];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.text.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.textSub.withValues(alpha: 0.1),
                  backgroundImage: provider.imageUrl.isNotEmpty
                      ? NetworkImage(provider.imageUrl)
                      : null,
                  child: provider.imageUrl.isEmpty
                      ? Icon(Icons.person, color: colors.textSub)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                Text(
                  provider.specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSub, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 14, color: colors.warning),
                    const SizedBox(width: 2),
                    Text(
                      provider.rating.toString(),
                      style: TextStyle(fontSize: 12, color: colors.text),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🛠️ قائمة الخدمات (Vertical) باستخدام ServiceCard
  Widget _buildServicesList(
    List<ServiceModel> services,
    dynamic colors,
  ) {
    return Column(
      children: services.map((service) {
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
          onFavoriteToggle: () {
            context.read<FavoriteViewModel>().toggleFavorite(service);
          },
        );
      }).toList(),
    );
  }
}
