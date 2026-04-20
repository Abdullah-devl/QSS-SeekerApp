import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';
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
  String? _errorMessage;
  ProfileModel? _profile;
  String? _address; // ✅ تمت الإضافة

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;
  String? get address => _address; // ✅ تمت الإضافة
  
  List<String> get works => _profile?.previousWorks.map((w) => w.imageUrl).toList() ?? [];

  /// 🚀 جلب بيانات الملف الشخصي بالكامل من الـ API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
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
  }

  Future<void> _updateAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _address = "${place.street != null && place.street!.isNotEmpty ? place.street : ''} ${place.locality}, ${place.country}";
        _address = _address!.trim();
      }
    } catch (e) {
      developer.log('⚠️ ProfileViewModel Geocoding Error: $e');
      _address = null; // فشل الجلب
    }
  }
}
