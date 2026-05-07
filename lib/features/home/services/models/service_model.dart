// // /// 📂 اسم الملف: service_model.dart
// // /// 📝 الوصف: نموذج بيانات الخدمة (Service).
// // /// يستخدم لعرض تفاصيل الخدمة مثل العنوان، السعر، والتقييم في قائمة "الأكثر طلباً".

// // class ServiceModel {
// //   final int id; // معرف الخدمة
// //   final String title; // عنوان الخدمة
// //   final String description; // وصف مختصر
// //   final double price; // السعر التقريبي
// //   final double rating; // التقييم (من 5)
// //   final String imageUrl; // رابط صورة الخدمة
// //   final String providerName; // اسم مقدم الخدمة

// //   ServiceModel({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.price,
// //     required this.rating,
// //     required this.imageUrl,
// //     required this.providerName,
// //     required int categoryId,
// //   });

// //   // /// 🔄 تحويل بيانات JSON إلى كائن ServiceModel.
// //   // factory ServiceModel.fromJson(Map<String, dynamic> json) {

// //   //   // معالجة مسار الصورة ليعمل سواء كان رابط كامل أو مسار محلي
// //   //   String rawImagePath = json['image_path'] ?? json['image_url'] ?? '';
// //   //   String finalImage = '';
// //   //   if (rawImagePath.isNotEmpty && rawImagePath != 'null') {
// //   //     finalImage = rawImagePath.startsWith('http') ? rawImagePath : 'http://127.0.0.1:8000/storage/$rawImagePath';
// //   //   }

// //   //   return ServiceModel(
// //   //     id: json['id'] ?? 0,
// //   //     title: json['name'] ?? json['title'] ?? 'بدون عنوان', // لارافيل يستخدم name
// //   //     description: json['description'] ?? 'لا يوجد وصف',
// //   //     price: (json['price'] as num?)?.toDouble() ?? 0.0,
// //   //     rating: (json['rating_avg'] ?? json['rating'] as num?)?.toDouble() ?? 0.0,
// //   //     imageUrl: finalImage, // المسار المعدل
// //   //     providerName: json['provider_name'] ?? json['provider']?['name'] ?? 'مزود خدمة',
// //   //   );
// //   // }

// //   /// 🔄 تحويل بيانات JSON إلى كائن ServiceModel بأمان تام.
// //   factory ServiceModel.fromJson(Map<String, dynamic> json) {
// //     // معالجة مسار الصورة ليعمل سواء كان رابط كامل أو مسار محلي
// //     String rawImagePath = json['image_path'] ?? json['image_url'] ?? '';
// //     String finalImage = '';
// //     if (rawImagePath.toString().trim().isNotEmpty &&
// //         rawImagePath.toString() != 'null') {
// //       finalImage = rawImagePath.startsWith('http')
// //           ? rawImagePath
// //           : 'http://127.0.0.1:8000/storage/$rawImagePath';
// //     }

// //     return ServiceModel(
// //       id: json['id'] ?? 0,
// //       title: json['name'] ?? json['title'] ?? 'بدون عنوان',
// //       description: json['description'] ?? 'لا يوجد وصف',
// //       categoryId: json['category_id'] ?? 0,

// //       // 🚀 الحل السحري للأرقام: تحويل آمن جداً للسعر والتقييم
// //       price: double.tryParse(json['price'].toString()) ?? 0.0,
// //       rating:
// //           double.tryParse((json['rating_avg'] ?? json['rating']).toString()) ??
// //           0.0,

// //       imageUrl: finalImage,
// //       providerName:
// //           json['provider_name'] ?? json['provider']?['name'] ?? 'مزود خدمة',
// //     );
// //   }

// //   get categoryId => null;
// // }

// /// 📂 اسم الملف: service_model.dart
// /// 📝 الوصف: نموذج بيانات الخدمة (Service).
// /// يستخدم لعرض تفاصيل الخدمة، ويدعم استلام الخدمات الفرعية المدمجة معها.

// class ServiceModel {
//   final int id; // معرف الخدمة
//   final String title; // عنوان الخدمة
//   final String description; // وصف مختصر
//   final double price; // السعر التقريبي
//   final double rating; // التقييم (من 5)
//   final String imageUrl; // رابط صورة الخدمة
//   final String providerName; // اسم مقدم الخدمة
//   final int categoryId; // ✅ تم إصلاح تعريف المتغير هنا

//   // 🚀 السحر هنا: قائمة تحفظ الخدمات الفرعية التابعة لهذه الخدمة الأساسية
//   final List<ServiceModel> subServices;

//   ServiceModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.price,
//     required this.rating,
//     required this.imageUrl,
//     required this.providerName,
//     required this.categoryId,
//     this.subServices = const [], // افتراضياً قائمة فارغة
//   });

//   /// 🔄 تحويل بيانات JSON إلى كائن ServiceModel بأمان تام.
//   factory ServiceModel.fromJson(Map<String, dynamic> json) {
//     // 1. معالجة مسار الصورة ليعمل سواء كان رابط كامل أو مسار محلي
//     String rawImagePath = json['image_path'] ?? json['image_url'] ?? '';
//     String finalImage = '';
//     if (rawImagePath.toString().trim().isNotEmpty &&
//         rawImagePath.toString() != 'null') {
//       finalImage = rawImagePath.startsWith('http')
//           ? rawImagePath
// import 'package:flutter/foundation.dart';
import 'package:seeker/core/network/api_endpoints.dart';

import '../../models/service_schedule_model.dart';

class ServiceModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String imageUrl;
  String providerName;
  final int providerId;
  final int categoryId;
  int? parentServiceId;
  bool isFavorite; // ❤️ حالة المفضلة
  final double? distance; // 📍 المسافة بالكيلومترات
  final bool isAvailableNow; // 🟢 متاح الآن
  bool isVerified; // ✅ هل المزود موثق؟
  DateTime? verifiedUntil; // 📅 تاريخ انتهاء التوثيق
  List<ServiceModel> subServices;
  final List<ServiceScheduleModel>
  schedules; // 📅 جدول المواعيد المتاح لهذه الخدمة

  /// 🛡️ Getter للتحقق من أن التوثيق لا يزال سارياً
  /// إذا كان تاريخ التوثيق ساري (اليوم أو مستقبلاً) فالمزود موثق
  bool get isProviderVerified {
    if (verifiedUntil == null) return isVerified;
    
    // مقارنة التاريخ (بدون الساعات) مع تاريخ اليوم
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return verifiedUntil!.isAtSameMomentAs(today) || verifiedUntil!.isAfter(today);
  }

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.providerName,
    required this.providerId,
    required this.categoryId,
    this.parentServiceId,
    this.isFavorite = false,
    this.distance,
    this.isAvailableNow = true,
    this.isVerified = false,
    this.verifiedUntil,
    this.subServices = const [],
    this.schedules = const [],
  });

  /// 🛡️ تحديث بيانات المزود (الاسم + التوثيق) بعد جلبها من السيرفر
  void updateProviderInfo({
    String? name,
    bool? verified,
    DateTime? verifiedDate,
  }) {
    if (name != null && name.isNotEmpty) providerName = name;
    if (verified != null) isVerified = verified;
    if (verifiedDate != null) verifiedUntil = verifiedDate;
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // 1. معالجة مسار الصورة
    String rawImagePath = (json['image_path'] ?? json['image_url'] ?? '')
        .toString()
        .trim();
    String finalImage = ApiEndpoints.getImageUrl(rawImagePath);

    // 2. استخراج الخدمات الفرعية
    var rawSubServices =
        json['children'] ?? json['sub_services'] ?? json['child_services'];
    List<ServiceModel> parsedSubServices = [];
    if (rawSubServices != null && rawSubServices is List) {
      parsedSubServices = rawSubServices
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 🕒 3. استخراج جدول المواعيد (Schedules)
    var rawSchedules = json['schedules'] ?? json['service_schedules'] ?? [];
    List<ServiceScheduleModel> parsedSchedules = [];
    if (rawSchedules is List) {
      parsedSchedules = rawSchedules
          .map((e) => ServiceScheduleModel.fromJson(e))
          .toList();
    }

    // 🚀 4. قراءة الـ parent_service_id بصرامة (الحل السحري)
    int? pId;
    var rawParent = json['parent_service_id'] ?? json['parent_id'];
    if (rawParent != null &&
        rawParent.toString().trim() != 'null' &&
        rawParent.toString().trim().isNotEmpty) {
      pId = int.tryParse(rawParent.toString());
    }

    return ServiceModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['name'] ?? json['title'] ?? 'بدون عنوان',
      description: json['description'] ?? 'لا يوجد وصف',
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,

      parentServiceId: pId, // إسناد القيمة الصارمة
      isFavorite:
          json['is_favorite'] == true ||
          json['is_favorite'] == 1, // قراءة حالة المفضلة

      price: double.tryParse(json['price'].toString()) ?? 0.0,
      rating: double.tryParse((json['avg_rating'] ??
              json['rating_avg'] ??
              json['rating'])
          .toString()) ??
          0.0,
      imageUrl: finalImage,
      providerName:
          json['provider_name'] ?? json['provider']?['name'] ?? 'مزود خدمة',
      providerId:
          int.tryParse(
            (json['user_id'] ??
                    json['provider_id'] ??
                    json['provider']?['id'] ??
                    json['user']?['id'] ??
                    '0')
                .toString(),
          ) ??
          0,

      distance: double.tryParse(json['distance']?.toString() ?? ''),
      isAvailableNow:
          json['is_available_now'] != false, // افتراضياً متاح إلا إذا ذكر العكس

      // 🛡️ استخراج بيانات التوثيق من كل الأماكن الممكنة
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['verification_provider'] == 1 ||
          json['verification_provider'] == true ||
          json['provider']?['verification_provider'] == 1 ||
          json['provider']?['verification_provider'] == true ||
          json['user']?['verification_provider'] == 1 ||
          json['user']?['verification_provider'] == true,
      verifiedUntil: () {
        final dateStr = (json['verified_until']?.toString() ??
            json['provider_verified_until']?.toString() ??
            json['provider']?['provider_verified_until']?.toString() ??
            json['user']?['provider_verified_until']?.toString() ??
            '');
        if (dateStr.isEmpty || dateStr.contains('0000-00-00')) return null;
        return DateTime.tryParse(dateStr);
      }(),

      subServices: parsedSubServices,
      schedules: parsedSchedules, // ✅ تم الإسناد هنا
    );
  }
}
