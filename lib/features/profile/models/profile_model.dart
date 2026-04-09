// lib/features/profile/models/profile_model.dart
import 'package:seeker/core/network/api_endpoints.dart';
import 'phone_model.dart';
import 'bank_model.dart';

/// 📂 اسم الملف: profile_model.dart
/// 📝 الوصف: نموذج بيانات الملف الشخصي (Profile) متوافق مع استجابة الباك إند.
class ProfileModel {
  // 🗄️ حقول جدول users
  final int id;
  final String name;
  final String email;
  final String role;
  final double ratingAvg;
  final bool noCommission;
  final double commission;
  final bool seekerPolicy;
  final bool providerPolicy;
  final bool verificationProvider;
  final DateTime? providerVerifiedUntil;
  final double bonusPoints;
  final double paidPoints;

  // 🎨 حقول جدول profiles
  final String jobTitle;
  final String bio;
  final String avatarUrl;
  final int completedJobs;
  final int yearsExperience;
  final List<String> worksImages;
  final bool isAvailable;

  // 📞 بيانات التواصل الإضافية والحسابات البنكية من الباك إند
  final List<PhoneModel> phones;
  final List<BankModel> banks;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.ratingAvg,
    required this.noCommission,
    required this.commission,
    required this.seekerPolicy,
    required this.providerPolicy,
    required this.verificationProvider,
    this.providerVerifiedUntil,
    required this.bonusPoints,
    required this.paidPoints,
    this.jobTitle = '',
    this.bio = '',
    this.avatarUrl = '',
    this.completedJobs = 0,
    this.yearsExperience = 0,
    this.worksImages = const [],
    this.isAvailable = true,
    this.phones = const [],
    this.banks = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // 🚀 جلب بيانات المستخدم الأساسية (الاسم، الإيميل، إلخ)
    final userJson = json['user'] ?? json;
    
    // 🎨 جلب بيانات البروفايل (النبذة، المسمى الوظيفي، الصورة)
    final profileData = json['profile'] ?? (json.containsKey('job_title') || json.containsKey('bio') ? json : userJson);

    // 🔍 البحث عن الاسم في كل الأماكن الممكنة
    String findName() {
      return userJson['name'] ?? 
             json['name'] ?? 
             profileData['name'] ?? 
             userJson['full_name'] ?? 
             json['full_name'] ?? 
             'مستخدم غير معروف';
    }

    // 🔍 البحث عن الصورة في كل الأماكن الممكنة
    String findAvatar() {
      final val = profileData['image_url'] ?? 
                  profileData['avatar'] ?? 
                  json['image_url'] ?? 
                  json['avatar'] ?? 
                  userJson['image_url'] ?? 
                  userJson['avatar'] ?? '';
      if (val == null || val.toString().isEmpty) return '';
      final url = val.toString();
      return url.startsWith('http') ? url : '${ApiEndpoints.domain}$url';
    }

    return ProfileModel(
      id: userJson['id'] ?? json['user_id'] ?? userJson['user_id'] ?? json['id'] ?? 0,
      name: findName(),
      email: userJson['email'] ?? json['email'] ?? '',
      role: userJson['role'] ?? json['role'] ?? 'seeker',
      ratingAvg:
          double.tryParse(userJson['rating_avg']?.toString() ?? json['rating_avg']?.toString() ?? '0') ?? 0.0,
      noCommission:
          userJson['no_commission'] == 1 || userJson['no_commission'] == true || json['no_commission'] == 1,
      commission:
          double.tryParse(userJson['commission']?.toString() ?? json['commission']?.toString() ?? '0') ?? 0.0,
      seekerPolicy:
          userJson['seeker_policy'] == 1 || userJson['seeker_policy'] == true,
      providerPolicy:
          userJson['provider_policy'] == 1 ||
          userJson['provider_policy'] == true,
      verificationProvider:
          userJson['verification_provider'] == 1 ||
          userJson['verification_provider'] == true ||
          userJson['is_verified'] == 1 ||
          userJson['is_verified'] == true ||
          json['is_verified'] == 1,
      providerVerifiedUntil: () {
        final dateStr = (userJson['provider_verified_until']?.toString() ?? 
                         userJson['verified_until']?.toString() ?? 
                         json['verified_until']?.toString() ?? '');
        if (dateStr.isEmpty || dateStr.contains('0000-00-00')) return null;
        return DateTime.tryParse(dateStr);
      }(),
      bonusPoints:
          double.tryParse(userJson['bonus_points']?.toString() ?? '0') ?? 0.0,
      paidPoints:
          double.tryParse(userJson['paid_points']?.toString() ?? '0') ?? 0.0,

      // 🎨 بيانات البروفايل من 'profileData' مع بدائل للمفاتيح
      jobTitle: profileData['job_title'] ?? profileData['profession'] ?? userJson['job_title'] ?? 'فني محترف',
      bio: profileData['bio'] ?? profileData['description'] ?? userJson['bio'] ?? '',
      avatarUrl: findAvatar(),
      completedJobs: profileData['completed_jobs'] ?? json['completed_jobs'] ?? 0,
      yearsExperience: profileData['years_experience'] ?? json['years_experience'] ?? 0,
      worksImages: profileData['works'] != null
          ? (profileData['works'] as List).map((work) {
              if (work is String) return work;
              if (work is Map && work['image_url'] != null) {
                final url = work['image_url'].toString();
                return url.startsWith('http') ? url : '${ApiEndpoints.domain}$url';
              }
              return '';
            }).where((url) => url.isNotEmpty).toList().cast<String>()
          : [],
      isAvailable: profileData['is_available'] == 1 || profileData['is_available'] == true || json['is_available'] == 1,
      // 📞 بيانات التواصل من الـ JSON (ندعم المعالجة للأرقام والبنوك)
      phones: json['phones'] != null
          ? (json['phones'] as List).map((p) => PhoneModel.fromJson(Map<String, dynamic>.from(p))).toList()
          : [],
      banks: json['banks'] != null
          ? (json['banks'] as List).map((b) => BankModel.fromJson(Map<String, dynamic>.from(b))).toList()
          : [],
    );
  }
}
