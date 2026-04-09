import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import '../models/category_model.dart';
import '../services/models/service_model.dart';
import '../repositories/home_repository.dart';
import '../viewmodels/category_details_view_model.dart';

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

                // 3️⃣ الخدمات (Services) بتصميم screen.png المطابق
                if (data.services.isNotEmpty) ...[
                  _buildSectionTitle('الخدمات المتاحة', colors),
                  const SizedBox(height: 12),
                  // 🚀 مررنا الـ ViewModel (vm) هنا لكي تستخدمه الدالة
                  _buildServicesList(data.services, colors, vm),
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
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cat.iconPath.isNotEmpty
                    ? Image.network(cat.iconPath, width: 30, height: 30)
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
              color: Theme.of(context).cardColor, // 🎨 يتكيف مع الثيم
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.text.withOpacity(0.05), // 🎨 ظل ديناميكي
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.textSub.withOpacity(0.1), // 🎨
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
                    const Icon(Icons.star, size: 14, color: Colors.amber),
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

  /// 🛠️ قائمة الخدمات (Vertical) بتصميم الكرت المطابق للصورة (تدعم المفضلة MVVM)
  Widget _buildServicesList(
    List<ServiceModel> services,
    dynamic colors,
    CategoryDetailsViewModel vm, // 🚀 استقبال الـ ViewModel
  ) {
    return Column(
      children: services.map((service) {
        return GestureDetector(
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // 🎨 يتكيف مع الثيم
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.text.withOpacity(0.04), // 🎨 ظل ديناميكي
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 🔵 الجزء العلوي: الصورة + التفاصيل
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1️⃣ الصورة
                    Stack(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.05), // 🎨
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: service.imageUrl.isNotEmpty
                                ? Image.network(
                                    service.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.cleaning_services,
                                    color: colors.primary.withOpacity(0.5),
                                  ),
                          ),
                        ),
                        // بادج التقييم
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor, // 🎨
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  service.rating > 0
                                      ? service.rating.toString()
                                      : 'جديد',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.text, // 🎨
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // 2️⃣ التفاصيل
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // التاق والقلب التفاعلي
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.category.name,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 💖 أيقونة المفضلة المرتبطة بالـ ViewModel
                              GestureDetector(
                                onTap: () {
                                  vm.toggleFavorite(service.id);
                                },
                                child: Icon(
                                  vm.isFavorite(service.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: vm.isFavorite(service.id)
                                      ? Colors.redAccent
                                      : colors.textSub.withOpacity(0.5), // 🎨
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // العنوان والمزود
                          Text(
                            service.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: colors.text, // 🎨
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.providerName,
                            style: TextStyle(
                              color: colors.textSub,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // السعر والحالة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: colors.textSub,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'متاح الآن',
                                    style: TextStyle(
                                      color: colors.textSub,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${service.price.toInt()} ر.س',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / خدمة',
                                      style: TextStyle(
                                        color: colors.textSub,
                                        fontSize: 9,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 🔴 الجزء السفلي: زر حجز موعد
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.textSub.withOpacity(
                      0.05,
                    ), // 🎨 خلفية الزر تتكيف
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'حجز موعد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colors.text, // 🎨
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: colors.text,
                      ), // 🎨
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
