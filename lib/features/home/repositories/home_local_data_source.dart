// import 'package:flutter/foundation.dart';
// import 'package:seeker/features/home/models/category_model.dart';
// import 'package:seeker/features/home/models/service_model.dart';

// class HomeLocalDataSource {
//   final box = Hive.box('homeBox');

//   // Categories
//   Future<void> saveCategories(List<Category> list) async {
//     await box.put(
//       'categories',
//       list.map((e) => e.toJson()).toList(),
//     );
//   }

//   List<Category> getCategories() {
//     final data = box.get('categories');
//     if (data == null) return [];
//     return (data as List)
//         .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }

//   // Top Services
//   Future<void> saveTopServices(List<Service> list) async {
//     await box.put(
//       'top_services',
//       list.map((e) => e.toJson()).toList(),
//     );
//   }

//   List<Service> getTopServices() {
//     final data = box.get('top_services');
//     if (data == null) return [];
//     return (data as List)
//         .map((e) => Service.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }
// }
