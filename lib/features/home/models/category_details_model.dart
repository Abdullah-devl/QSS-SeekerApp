import 'category_model.dart';
import 'service_model.dart';
import 'provider_model.dart';

// / 📂 اسم الملف: category_details_model.dart
// / 📝 الوصف: نموذج تجميعي لبيانات تفاصيل التصنيف.
// / يحتوي على:
// / 1. التصنيفات الفرعية (SubCategories).
// / 2. الخدمات المتاحة (Services).
// / 3. مقدمي الخدمة الموصى بهم (Recommended Providers).
class CategoryDetailsModel {
  final List<CategoryModel> subCategories;
  final List<ServiceModel> services;
  final List<ProviderModel> recommendedProviders;

  CategoryDetailsModel({
    this.subCategories = const [],
    this.services = const [],
    this.recommendedProviders = const [],
  });

  factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return CategoryDetailsModel(
      subCategories:
          ((json['sub_categories'] ?? json['sub_categories']) as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      recommendedProviders:
          (json['recommended_providers'] as List<dynamic>?)
              ?.map((e) => ProviderModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}


// class CategoryDetailsModel {
//   final List<CategoryModel> subCategories;
//   final List<ServiceModel> services;
//   final List<ProviderModel> recommendedProviders;

//   CategoryDetailsModel({
//     this.subCategories = const [],
//     this.services = const [],
//     this.recommendedProviders = const [],
//   });

//   factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
//     final category = (json['category'] as Map<String, dynamic>?) ?? {};

//     return CategoryDetailsModel(
//       subCategories:
//           (category['children'] as List<dynamic>?)
//               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       services:
//           (category['services'] as List<dynamic>?)
//               ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       // مافيه recommended_providers في ردّك الحالي، فخله فاضي
//       recommendedProviders:
//           (json['recommended_providers'] as List<dynamic>?)
//               ?.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }
