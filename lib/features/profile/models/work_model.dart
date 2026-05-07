// lib/features/profile/models/work_model.dart
import '../../../../core/network/api_endpoints.dart';

class WorkModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;

  WorkModel({required this.id, required this.title, required this.description, required this.imageUrl});

  factory WorkModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(parsedJson);
    String parsedImageUrl = '';
    final rawImage = json['image_url'] ?? json['image'] ?? json['image_path'];
    if (rawImage != null && rawImage.toString().isNotEmpty) {
      final String imageStr = rawImage.toString();
      parsedImageUrl = ApiEndpoints.getImageUrl(imageStr);
    }

    return WorkModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      // إضافة رابط السيرفر
      imageUrl: parsedImageUrl,
    );
  }
}