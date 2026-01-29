import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../models/category_model.dart';
import '../models/category_details_model.dart';
import '../viewmodels/category_details_view_model.dart';

/// 📂 اسم الملف: category_details_view.dart
/// 📝 الوصف: صفحة تفاصيل التصنيف.
/// تعرض التصنيفات الفرعية، الموصى بهم، والخدمات المتاحة تحت هذا التصنيف.
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
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: BackButton(color: colors.text),
      ),
      body: Consumer<CategoryDetailsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage.isNotEmpty) {
            return Center(child: Text(vm.errorMessage));
          }

          final data = vm.data;

          // if (data.subCategories.isEmpty &&
          //     data.services.isEmpty &&
          //     data.recommendedProviders.isEmpty) {
          //   return Center(
          //     child: Text(
          //       'لا توجد بيانات متاحة لهذا التصنيف حالياً',
          //       style: TextStyle(color: colors.textSub),
          //     ),
          //   );
          // }

          return SingleChildScrollView(
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

                // 3️⃣ الخدمات (Services)
                if (data.services.isNotEmpty) ...[
                  _buildSectionTitle('الخدمات المتاحة', colors),
                  const SizedBox(height: 12),
                  _buildServicesList(data.services, colors),
                ],
              ],
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
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
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
                Icon(
                  Icons.category,
                  color: colors.primary,
                  size: 30,
                ), // يمكن استبداله بالصورة
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
        itemCount: providers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final provider = providers[index];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                  backgroundColor: Colors.grey[200],
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
                    Icon(Icons.star, size: 14, color: Colors.amber),
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

  /// 🛠️ قائمة الخدمات (Vertical)
  Widget _buildServicesList(List<dynamic> services, dynamic colors) {
    return Column(
      children: services.map((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: service.imageUrl.isNotEmpty
                    ? Image.network(
                        service.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(Icons.construction, color: colors.primary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSub, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${service.price} ر.س',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'حجز',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
