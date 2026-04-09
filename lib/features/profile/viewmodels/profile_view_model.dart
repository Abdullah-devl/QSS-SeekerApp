import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../models/profile_model.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: profile_view_model.dart
/// 📝 الوصف: مسؤول عن إدارة حالة صفحة الملف الشخصي (Instagram-style).
/// يقوم بجلب بيانات الملف الشخصي والأعمال المرتبطة به.
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final int? targetUserId;

  ProfileViewModel(this._repository, {this.targetUserId}) {
    if (targetUserId != null) {
      fetchProfile();
    }
  }

  bool _isLoading = false;
  String? _errorMessage;
  ProfileModel? _profile;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;
  
  /// 🖼️ جلب الصور من البروفايل (أو يمكن جلب قائمة موديلات كاملة إذا لزم الأمر)
  List<String> get works => _profile?.worksImages ?? [];

  /// 🚀 جلب بيانات الملف الشخصي بالكامل من الـ API
  Future<void> fetchProfile() async {
    if (targetUserId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.fetchUserProfile(targetUserId!);
      developer.log('✅ ProfileViewModel: Profile loaded for ${_profile?.name}');
    } catch (e) {
      _errorMessage = e.toString();
      developer.log('❌ ProfileViewModel: Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
