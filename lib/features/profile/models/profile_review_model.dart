import 'package:seeker/core/network/api_endpoints.dart';

/// 📂 اسم الملف: profile_review_model.dart
/// 📝 الوصف: نموذج التقييمات في الملف الشخصي (سواء التقييمات التي حصل عليها مقدم الخدمة، أو التي كتبها العميل).
class ProfileReviewModel {
  final int rating;
  final String comment;
  final String userName;
  final String userImageUrl;
  final String createdAt;
  final bool isHidden;

  ProfileReviewModel({
    required this.rating,
    required this.comment,
    required this.userName,
    required this.userImageUrl,
    required this.createdAt,
    required this.isHidden,
  });

  factory ProfileReviewModel.fromJson(Map<String, dynamic> json) {
    final ratingVal = int.tryParse(json['rating']?.toString() ?? '0') ?? 0;
    final commentVal = json['comment']?.toString() ?? '';
    final createdAtVal = json['created_at']?.toString() ?? '';
    final isHiddenVal = json['is_hidden'] == true || json['is_hidden'] == 1 || json['hidden'] == true || json['hidden'] == 1;

    // قراءة بيانات المستخدم بشكل مرن
    final userObj = json['user'] ?? json['provider'] ?? {};
    final userNameVal = userObj['name']?.toString() ?? 'مستخدم';
    
    final rawImg = userObj['image_url'] ?? userObj['image_path'] ?? userObj['avatar'] ?? '';
    final userImageUrlVal = ApiEndpoints.getImageUrl(rawImg.toString());

    return ProfileReviewModel(
      rating: ratingVal,
      comment: commentVal,
      userName: userNameVal,
      userImageUrl: userImageUrlVal,
      createdAt: createdAtVal,
      isHidden: isHiddenVal,
    );
  }
}
