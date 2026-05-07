/// 📂 اسم الملف: advertisement_model.dart
/// 📝 الوصف: نموذج بيانات الإعلان (Advertisement).
/// يحتوي على بيانات التوجيه (Deep Linking) ومقاييس الأداء.

import 'package:seeker/core/network/api_endpoints.dart';

class AdvertisementModel {
  final int id;
  final String title;
  final String imageUrl;
  final String type; // carousel, banner, etc.
  final String targetType; // service, category, external, none
  final int? targetId;
  final String? externalLink;
  final String? description;
  final AdMetrics metrics;

  AdvertisementModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.type,
    required this.targetType,
    this.targetId,
    this.externalLink,
    required this.metrics,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: ApiEndpoints.getImageUrl(json['image_url'] ?? json['image'] ?? json['image_path']),
      type: json['type'] ?? 'banner',
      targetType: json['target_type'] ?? 'none',
      targetId: json['target_id'] != null ? int.tryParse(json['target_id'].toString()) : null,
      externalLink: json['external_link'],
      metrics: AdMetrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class AdMetrics {
  final int views;
  final int clicks;

  AdMetrics({this.views = 0, this.clicks = 0});

  factory AdMetrics.fromJson(Map<String, dynamic> json) {
    return AdMetrics(
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
    );
  }
}
