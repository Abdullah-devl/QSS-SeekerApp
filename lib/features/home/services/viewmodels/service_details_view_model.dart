//   ServiceDetailsViewModel();

//   bool _isLoading = false;
//   String _errorMessage = '';
//   ServiceModel? _service;
//   bool _isFavorite = false;

//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   ServiceModel? get service => _service;
//   bool get isFavorite => _isFavorite;

//   /// 🚀 جلب بيانات الخدمة التفصيلية من الـ API
//   Future<void> fetchServiceDetails(
//     int serviceId,
//     ServiceModel initialData,
//   ) async {
//     _isLoading = true;
//     _service =
//         initialData; // نضع البيانات الأولية حتى يكتمل التحميل لكي لا تنتظر الشاشة
//     notifyListeners();

//     try {
//       // 💡 هنا سيتم استدعاء الـ API الفعلي لجلب باقي التفاصيل (الصور، التقييمات، البنوك)
//       // _service = await _repository.fetchServiceDetails(serviceId);

//       // محاكاة تأخير الشبكة للتجربة
//       await Future.delayed(const Duration(milliseconds: 500));

//       // _isFavorite = await _repository.checkFavoriteStatus(serviceId);
//     } catch (e) {
//       if (e is Failure) {
//         _errorMessage = e.message;
//       } else {
//         _errorMessage = 'حدث خطأ غير متوقع';
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// 💖 تغيير حالة المفضلة
//   void toggleFavorite() {
//     _isFavorite = !_isFavorite;
//     notifyListeners();
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import 'package:seeker/features/profile/models/profile_model.dart';
import '../../repositories/home_repository.dart';

/// 📂 اسم الملف: service_details_view_model.dart
/// 📝 الوصف: مسؤول عن إدارة حالة صفحة تفاصيل الخدمة.
/// يقوم بجلب تفاصيل الخدمة وبيانات المزود (النبذة والأعمال) من السيرفر.
class ServiceDetailsViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  ServiceDetailsViewModel(this._repository);

  bool _isLoading = false;
  String _errorMessage = '';
  ServiceModel? _service;
  ProfileModel? _providerProfile; // 👤 ملف المزود
  bool _isFavorite = false;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ServiceModel? get service => _service;
  ProfileModel? get providerProfile => _providerProfile;
  bool get isFavorite => _isFavorite;

  /// 🚀 جلب بيانات الخدمة وتفاصيل المزود من الـ API
  Future<void> fetchServiceDetails(int serviceId, ServiceModel initialData) async {
    // 1️⃣ تعيين البيانات الأولية (Optimistic UI)
    _service = initialData;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // 2️⃣ جلب تفاصيل الخدمة الكاملة (للحصول على الخدمات الفرعية)
      _service = await _repository.fetchServiceById(serviceId);
      
      developer.log('🔍 ServiceDetails: Loaded service $serviceId, ProviderId: ${_service?.providerId}', name: 'ServiceDetails');

      // 3️⃣ جلب ملف المزود (باستخدام معرف المزود المستخرج من الخدمة)
      if (_service != null && _service!.providerId != 0) {
        developer.log('👤 ServiceDetails: Fetching profile for Provider ID: ${_service!.providerId}', name: 'ServiceDetails');
        _providerProfile = await _repository.fetchUserProfile(_service!.providerId);
        developer.log('✅ ServiceDetails: Profile loaded for ${_providerProfile?.name}. Banks: ${_providerProfile?.banks.length}', name: 'ServiceDetails');
      } else {
        developer.log('⚠️ ServiceDetails: No ProviderId found or Id is 0 for service $serviceId', name: 'ServiceDetails');
      }
      
    } catch (e) {
      // لا نعين خطأ فادحاً لأننا نملك البيانات الأولية على الأقل
      _errorMessage = 'تعذر تحديث بعض البيانات من الخادم.';
      developer.log('❌ ServiceDetails: ViewModel Error: $e', name: 'ServiceDetails', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 💖 تغيير حالة المفضلة
  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
    // TODO: ربطها بـ API المفضلة مستقبلاً
  }
}