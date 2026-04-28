// lib/features/profile/models/profile_model.dart
import 'package:seeker/core/network/api_endpoints.dart';
import 'phone_model.dart';
import 'bank_model.dart';
import 'work_model.dart';
import 'dart:developer' as developer;
import 'package:seeker/features/home/services/models/service_model.dart';

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
  final List<WorkModel> previousWorks;
  final bool isAvailable;
  final List<ServiceModel> mainServices;

  // 📞 بيانات التواصل الإضافية والحسابات البنكية من الباك إند
  final List<PhoneModel> phones;
  final List<BankModel> banks;

  // 📍 الموقع الجغرافي
  final double? latitude;
  final double? longitude;

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
    this.previousWorks = const [],
    this.isAvailable = true,
    this.mainServices = const [],
    this.phones = const [],
    this.banks = const [],
    this.latitude,
    this.longitude,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // 🚀 جلب البيانات بناءً على هيكل السيرفر الملاحظ في السجلات
    // السيرفر يرسل: { "profile": { "user": { ... }, "profile_phones": [...], ... } }
    final profileData = json['profile'] ?? json;
    final userJson = profileData['user'] ?? json['user'] ?? profileData;
    
    // 🔍 البحث عن الاسم في كل الأماكن الممكنة
    String findName() {
      return userJson['name'] ?? 
             profileData['name'] ?? 
             json['name'] ?? 
             userJson['full_name'] ?? 
             'مستخدم غير معروف';
    }

    // 🔍 البحث عن الصورة في كل الأماكن الممكنة
    String findAvatar() {
      final val = profileData['image_url'] ?? 
                  profileData['image_path'] ?? 
                  profileData['avatar'] ?? 
                  userJson['image_url'] ?? 
                  userJson['avatar'] ?? '';
      if (val == null || val.toString().isEmpty || val.toString() == 'null') return '';
      final url = val.toString();
      return url.startsWith('http') ? url : '${ApiEndpoints.domain}$url';
    }

    // 🔍 البحث عن المعرف (ID) - الأولوية لمعرف المستخدم الفعلي
    final int parsedId = int.tryParse((
      userJson['id'] ?? 
      profileData['user_id'] ?? 
      json['user_id'] ?? 
      profileData['id'] ?? 
      json['id'] ?? 
      '0'
    ).toString()) ?? 0;

    final double? lat = (profileData['latitude'] is num) 
        ? (profileData['latitude'] as num).toDouble() 
        : double.tryParse(profileData['latitude']?.toString() ?? '');
        
    final double? lng = (profileData['longitude'] is num) 
        ? (profileData['longitude'] as num).toDouble() 
        : double.tryParse(profileData['longitude']?.toString() ?? '');

    developer.log('🔍 [ProfileModel.fromJson] Parsed ID: $parsedId, Name: ${findName()}, Lat: $lat, Lng: $lng', name: 'ProfileModel');

    return ProfileModel(
      id: parsedId,
      name: findName(),
      email: userJson['email'] ?? json['email'] ?? '',
      role: userJson['role'] ?? json['role'] ?? 'provider',
      ratingAvg:
          double.tryParse(userJson['rating_avg']?.toString() ?? profileData['rating_avg']?.toString() ?? '0') ?? 0.0,
      noCommission:
          userJson['no_commission'] == 1 || userJson['no_commission'] == true || profileData['no_commission'] == 1,
      commission:
          double.tryParse(userJson['commission']?.toString() ?? profileData['commission']?.toString() ?? '0') ?? 0.0,
      seekerPolicy:
          userJson['seeker_policy'] == 1 || userJson['seeker_policy'] == true || profileData['seeker_policy'] == 1,
      providerPolicy:
          userJson['provider_policy'] == 1 || userJson['provider_policy'] == true,
      verificationProvider:
          userJson['verification_provider'] == 1 || userJson['verification_provider'] == true || userJson['is_verified'] == 1,
      providerVerifiedUntil: () {
        final dateStr = (userJson['provider_verified_until']?.toString() ?? 
                         userJson['verified_until']?.toString() ?? '');
        if (dateStr.isEmpty || dateStr.contains('0000-00-00')) return null;
        return DateTime.tryParse(dateStr);
      }(),
      bonusPoints:
          double.tryParse(userJson['bonus_points']?.toString() ?? '0') ?? 0.0,
      paidPoints:
          double.tryParse(userJson['paid_points']?.toString() ?? '0') ?? 0.0,

      jobTitle: profileData['job_title'] ?? userJson['job_title'] ?? 'فني محترف',
      bio: profileData['bio'] ?? userJson['bio'] ?? '',
      avatarUrl: findAvatar(),
      completedJobs: profileData['completed_jobs'] ?? 0,
      yearsExperience: profileData['years_experience'] ?? 0,
      previousWorks: () {
        final List<WorkModel> works = [];
        final dynamic rawWorks = profileData['previous_works'] ?? 
                                 profileData['previousWorks'] ?? 
                                 profileData['works'];
        if (rawWorks is List) {
          for (final work in rawWorks) {
            if (work is Map) {
              works.add(WorkModel.fromJson(Map<String, dynamic>.from(work)));
            }
          }
        }
        return works;
      }(),
      mainServices: () {
        final List<ServiceModel> services = [];
        final dynamic rawServices = profileData['main_services'] ?? 
                                    profileData['mainServices'] ?? 
                                    profileData['services'] ??
                                    userJson['main_services'] ??
                                    userJson['services'] ??
                                    json['main_services'] ??
                                    json['services'];
        if (rawServices is List) {
          for (final s in rawServices) {
            if (s is Map) {
              services.add(ServiceModel.fromJson(Map<String, dynamic>.from(s)));
            }
          }
        }
        return services;
      }(),
      isAvailable: profileData['is_available'] == 1 || profileData['is_available'] == true,
      phones: () {
        final List<PhoneModel> list = [];
        final dynamic raw = profileData['profile_phones'] ?? profileData['phones'] ?? json['phones'];
        if (raw is List) {
          for (final p in raw) {
            if (p is Map) list.add(PhoneModel.fromJson(Map<String, dynamic>.from(p)));
          }
        }
        return list;
      }(),
      banks: () {
        final List<BankModel> list = [];
        final dynamic raw = userJson['banks'] ?? json['banks'];
        if (raw is List) {
          for (final b in raw) {
            if (b is Map) list.add(BankModel.fromJson(Map<String, dynamic>.from(b)));
          }
        }
        return list;
      }(),
      latitude: lat,
      longitude: lng,
    );
  }
}
