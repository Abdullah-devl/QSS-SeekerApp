// // import 'category_model.dart';
// // import 'service_model.dart';
// // import 'provider_model.dart';

// // // / 📂 اسم الملف: category_details_model.dart
// // // / 📝 الوصف: نموذج تجميعي لبيانات تفاصيل التصنيف.
// // // / يحتوي على:
// // // / 1. التصنيفات الفرعية (SubCategories).
// // // / 2. الخدمات المتاحة (Services).
// // // / 3. مقدمي الخدمة الموصى بهم (Recommended Providers).
// // class CategoryDetailsModel {
// //   final List<CategoryModel> subCategories;
// //   final List<ServiceModel> services;
// //   final List<ProviderModel> recommendedProviders;

// //   CategoryDetailsModel({
// //     this.subCategories = const [],
// //     this.services = const [],
// //     this.recommendedProviders = const [],
// //   });

// //   //  factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
// //   //     // 1. أحياناً يرسل الباك اند البيانات داخل مفتاح اسمه 'category' وأحياناً مباشرة
// //   //     final Map<String, dynamic> coreData = json.containsKey('category') ? json['category'] : json;

// //   //     // 2. البحث عن الأبناء (لارافيل غالباً يستخدم كلمة children)
// //   //     final List rawSubCategories = coreData['children'] ?? coreData['sub_categories'] ?? json['sub_categories'] ?? [];

// //   //     // 3. البحث عن الخدمات
// //   //     final List rawServices = coreData['services'] ?? json['services'] ?? [];

// //   //     // 4. البحث عن الموصى بهم
// //   //     final List rawProviders = coreData['recommended_providers'] ?? json['recommended_providers'] ?? [];

// //   //     return CategoryDetailsModel(
// //   //       subCategories: rawSubCategories.map((e) => CategoryModel.fromJson(e)).toList(),
// //   //       services: rawServices.map((e) => ServiceModel.fromJson(e)).toList(),
// //   //       recommendedProviders: rawProviders.map((e) => ProviderModel.fromJson(e)).toList(),
// //   //     );
// //   //   }
// //   // factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
// //   //   return CategoryDetailsModel(
// //   //     // 🚀 البحث عن 'children' بدلاً من sub_categories
// //   //     subCategories:
// //   //         (json['children'] as List<dynamic>?)
// //   //             ?.map((e) => CategoryModel.fromJson(e))
// //   //             .toList() ??
// //   //         [],

// //   //     // 🚀 جلب الخدمات
// //   //     services:
// //   //         (json['services'] as List<dynamic>?)
// //   //             ?.map((e) => ServiceModel.fromJson(e))
// //   //             .toList() ??
// //   //         [],

// //   //     // 🚀 جلب الموصى بهم (إذا لم تكن موجودة نعطيها مصفوفة فارغة)
// //   //     recommendedProviders:
// //   //         (json['recommended_providers'] as List<dynamic>?)
// //   //             ?.map((e) => ProviderModel.fromJson(e))
// //   //             .toList() ??
// //   //         [],
// //   //   );
// //   // }
// //   factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
// //     // 🚀 الحل الذكي: استخراج البيانات الحقيقية سواء وضعها الباك اند داخل 'category' أو مباشرة
// //     final Map<String, dynamic> coreData = json.containsKey('category')
// //         ? json['category']
// //         : json;

// //     return CategoryDetailsModel(
// //       // نقرأ البيانات الآن من coreData بدلاً من json مباشرة
// //       subCategories:
// //           (coreData['children'] as List<dynamic>?)
// //               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
// //               .toList() ??
// //           [],

// //       services:
// //           (coreData['services'] as List<dynamic>?)
// //               ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
// //               .toList() ??
// //           [],

// //       recommendedProviders:
// //           (coreData['recommended_providers'] as List<dynamic>?)
// //               ?.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
// //               .toList() ??
// //           [],
// //     );
// //   }
// // }

// // // class CategoryDetailsModel {
// // //   final List<CategoryModel> subCategories;
// // //   final List<ServiceModel> services;
// // //   final List<ProviderModel> recommendedProviders;

// // //   CategoryDetailsModel({
// // //     this.subCategories = const [],
// // //     this.services = const [],
// // //     this.recommendedProviders = const [],
// // //   });

// // //   factory CategoryDetailsModel.fromJson(Map<String, dynamic> json) {
// // //     final category = (json['category'] as Map<String, dynamic>?) ?? {};

// // //     return CategoryDetailsModel(
// // //       subCategories:
// // //           (category['children'] as List<dynamic>?)
// // //               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
// // //               .toList() ??
// // //           [],
// // //       services:
// // //           (category['services'] as List<dynamic>?)
// // //               ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
// // //               .toList() ??
// // //           [],
// // //       // مافيه recommended_providers في ردّك الحالي، فخله فاضي
// // //       recommendedProviders:
// // //           (json['recommended_providers'] as List<dynamic>?)
// // //               ?.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
// // //               .toList() ??
// // //           [],
// // //     );
// // //   }
// // // }
// // import 'category_model.dart';
// import 'package:seeker/features/home/models/category_model.dart';

// import 'service_model.dart';
// import 'provider_model.dart';

// /// 📂 اسم الملف: category_details_model.dart
// /// 📝 الوصف: نموذج تجميعي لبيانات تفاصيل التصنيف.
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
//     // 1. تحديد مكان البيانات الأساسي
//     final Map<String, dynamic> coreData = json.containsKey('category')
//         ? json['category']
//         : json;

//     // 2. استخراج كل الخدمات القادمة من الـ API
//     final List<dynamic> rawServices = coreData['services'] ?? [];

//     // 3. تحويل الخدمات إلى كائنات (ServiceModel)
//     List<ServiceModel> allServices = rawServices
//         .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
//         .toList();

//     // 🚀 4. التصفية الذكية (Smart Filter):
//     // هنا نأخذ فقط الخدمات التي (ليس لها أب) أي أنها خدمات رئيسية!
//     // (بافتراض أن الخدمة الفرعية تأتي بـ parentId في المودل)
//     List<ServiceModel> mainServicesOnly = allServices.where((service) {
//       // إذا كان للمودل الخاص بك متغير يعبر عن الأب (مثل parentId أو isChild)
//       // استخدمه هنا. على سبيل المثال:
//       // return service.parentId == null;

//       // إذا لم يكن لديك parentId في المودل، لكنك تعلم أن الخدمات الفرعية
//       // تأتي دائماً بسعر 0 أو اسم معين، يمكنك الفلترة بها.
//       // مبدئياً، إذا كان لديك parent_id في الـ Json، تأكد من إضافته للـ ServiceModel.

//       // سنفترض مؤقتاً أن الخدمة الرئيسية هي التي لا تحتوي على parent_id
//       return true; // ⚠️ ضع شرط الفلترة الصحيح هنا بناءً على مودل ServiceModel الخاص بك.
//     }).toList();

//     return CategoryDetailsModel(
//       subCategories:
//           (coreData['children'] as List<dynamic>?)
//               ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],

//       // 🚀 نرسل الخدمات الرئيسية المفلترة فقط للواجهة!
//       services: mainServicesOnly,

//       recommendedProviders:
//           (coreData['recommended_providers'] as List<dynamic>?)
//               ?.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

import 'category_model.dart';
import 'provider_model.dart';
import '../services/models/service_model.dart';

/// 📂 اسم الملف: category_details_model.dart
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
    final Map<String, dynamic> coreData = json.containsKey('category')
        ? json['category']
        : json;

    final List<dynamic> rawServices = coreData['services'] ?? [];
    List<ServiceModel> allServices = rawServices
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // 🚀 الفلترة القاطعة: الخدمة الرئيسية هي التي (ليس) لها أب
    List<ServiceModel> mainServicesOnly = allServices.where((service) {
      return service.parentServiceId == null || service.parentServiceId == 0;
    }).toList();

    return CategoryDetailsModel(
      subCategories:
          (coreData['children'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      // 🚀 نرسل الخدمات الرئيسية فقط!
      services: mainServicesOnly,

      recommendedProviders:
          (coreData['recommended_providers'] as List<dynamic>?)
              ?.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
