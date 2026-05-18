import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';
import '../models/profile_review_model.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: profile_view_model.dart
/// 📝 الوصف: مسؤول عن إدارة حالة صفحة الملف الشخصي.
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final int? targetUserId;

  ProfileViewModel(this._repository, {this.targetUserId}) {
    fetchProfile();
  }

  bool _isLoading = false;
  bool _isLoadingReviews = false;
  String? _errorMessage;
  ProfileModel? _profile;
  String? _address; // ✅ تمت الإضافة
  List<ProfileReviewModel> _reviews = [];
  bool _showHiddenReviews = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;
  String? get address => _address; // ✅ تمت الإضافة
  List<ProfileReviewModel> get reviews => _reviews;
  bool get showHiddenReviews => _showHiddenReviews;
  
  List<String> get works => _profile?.previousWorks.map((w) => w.imageUrl).toList() ?? [];

  void toggleHiddenReviews() {
    _showHiddenReviews = !_showHiddenReviews;
    notifyListeners();
  }

  /// 🚀 جلب بيانات الملف الشخصي بالكامل من الـ API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _isLoadingReviews = true;
    _errorMessage = null;
    _reviews = [];
    _showHiddenReviews = false;
    notifyListeners();

    try {
      if (targetUserId != null) {
        _profile = await _repository.fetchUserProfile(targetUserId!);
      } else {
        _profile = await _repository.fetchMyProfile();
      }

      // جلب العنوان النصي إذا وجدت إحداثيات
      if (_profile?.latitude != null && _profile?.longitude != null) {
        await _updateAddressFromCoords(_profile!.latitude!, _profile!.longitude!);
      }

      developer.log('✅ ProfileViewModel: Profile loaded for ${_profile?.name}');
    } catch (e) {
      _errorMessage = e.toString();
      developer.log('❌ ProfileViewModel: Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // جلب التقييمات/التعليقات
    try {
      if (targetUserId != null) {
        _reviews = await _repository.fetchProviderFeedback(targetUserId!);
      } else {
        _reviews = await _repository.fetchMyReviews();
      }
      developer.log('✅ ProfileViewModel: Loaded ${_reviews.length} reviews');
    } catch (e) {
      developer.log('❌ ProfileViewModel: Error loading reviews: $e');
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<void> _updateAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? '';
        String country = place.country ?? '';
        _address = city.isNotEmpty ? "$city, $country" : country;
        _address = _address!.trim();
      }
    } catch (e) {
      developer.log('⚠️ ProfileViewModel Geocoding Error: $e');
      _address = null; // فشل الجلب
    }
  }
}
