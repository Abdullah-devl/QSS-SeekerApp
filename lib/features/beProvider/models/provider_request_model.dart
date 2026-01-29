import 'dart:io';
import 'package:dio/dio.dart';

/// 📂 اسم الملف: provider_request_model.dart
/// 📝 الوصف: نموذج بيانات لطلب الانضمام كمزود خدمة.
class ProviderRequestModel {
  final String name;
  final String requestContent;
  final String location;
  final File idCardImage;

  ProviderRequestModel({
    required this.name,
    required this.requestContent,
    required this.location,
    required this.idCardImage,
  });

  /// تحويل البيانات إلى FormData لإرسالها عبر Dio
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'requestContent': requestContent,
      'location': location,
      'id_card': await MultipartFile.fromFile(idCardImage.path),
    });
  }
}
