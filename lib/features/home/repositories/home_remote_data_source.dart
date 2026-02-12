// import 'dart:developer';

// import 'package:flutter/foundation.dart';

// class HomeRemoteDataSource {
//   final DiagnosticPropertiesBuilder dio;

//   HomeRemoteDataSource(this.dio);

//   Future<List<Category>> getCategories() async {
//     final res = await dio.get('/categories');
//     return (res.data as List)
//         .map((e) => Category.fromJson(e))
//         .toList();
//   }

//   Future<List<Service>> getTopServices() async {
//     final res = await dio.get('/top-services');
//     return (res.data as List)
//         .map((e) => Service.fromJson(e))
//         .toList();
//   }

//   Future<List<Service>> search(String query) async {
//     final res = await dio.get('/search?q=$query');
//     return (res.data as List)
//         .map((e) => Service.fromJson(e))
//         .toList();
//   }
// }
