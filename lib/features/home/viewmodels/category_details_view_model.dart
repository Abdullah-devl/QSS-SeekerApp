import 'dart:math'; // ✅ تمت الإضافة
import 'package:flutter/material.dart';
import 'package:seeker/core/errors/failure.dart';
import '../repositories/home_repository.dart';
import '../models/category_details_model.dart';
import '../services/models/service_model.dart';
import '../models/advertisement_model.dart';
import '../repositories/advertisement_repository.dart';
import 'package:seeker/core/storage/token_storage.dart';

/// 📂 اسم الملف: category_details_view_model.dart
/// 📝 الوصف: نموذج العرض (ViewModel) لصفحة تفاصيل التصنيف.
/// مسؤول عن جلب البيانات وإدارة حالة التحميل والمفضلة.
class CategoryDetailsViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;
  final AdvertisementRepository _advertisementRepository;

  CategoryDetailsViewModel(this._homeRepository, this._advertisementRepository);

  // ---------------------------------------------------------------------------
  // 📊 الحالة (State)
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String _errorMessage = '';
  CategoryDetailsModel _data = CategoryDetailsModel();
  List<AdvertisementModel> _advertisements = []; // جميع إعلانات القسم
  AdvertisementModel? _sectionAd; // الإعلان المختار للعرض داخل القائمة
  int _adPosition = -1; // موقعه العشوائي داخل أول 5 خدمات

  // 💖 إدارة حالة المفضلة محلياً (MVVM)
  final Set<int> _favoriteServices = {};

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  CategoryDetailsModel get data => _data;
  List<AdvertisementModel> get advertisements => _advertisements;
  AdvertisementModel? get sectionAd => _sectionAd;
  int get adPosition => _adPosition;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// ✨ التحقق مما إذا كانت الخدمة في المفضلة
  bool isFavorite(int serviceId) => _favoriteServices.contains(serviceId);

  /// ✨ تغيير حالة المفضلة للخدمة
  void toggleFavorite(int serviceId) {
    if (_favoriteServices.contains(serviceId)) {
      _favoriteServices.remove(serviceId);
    } else {
      _favoriteServices.add(serviceId);
    }
    notifyListeners(); // 🚀 تحديث الواجهة فوراً
  }

  /// 🚀 جلب تفاصيل التصنيف بناءً على [categoryId].
  Future<void> fetchCategoryDetails(int categoryId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // جلب تفاصيل القسم والإعلانات بالتوازي
      final role = await TokenStorage().getRole() ?? 'guest';
      final userType = role == 'guest' ? 'all' : (role == 'provider' ? 'provider' : 'client');

      final results = await Future.wait([
        _homeRepository.fetchCategoryDetails(categoryId),
        _advertisementRepository.fetchAdvertisements(userType, categoryId: categoryId),
      ]);

      _data = results[0] as CategoryDetailsModel;
      _advertisements = results[1] as List<AdvertisementModel>;

      // 🎯 منطق الإعلان العشوائي (Section Ad)
      final sectionAds = _advertisements.where((ad) => ad.type == 'section' || ad.type == 'banner').toList();
      if (sectionAds.isNotEmpty && _data.services.isNotEmpty) {
        // اختيار إعلان عشوائي
        _sectionAd = sectionAds[Random().nextInt(sectionAds.length)];
        
        // اختيار موضع عشوائي بين أول 5 خدمات (0 إلى 4)
        final maxPos = _data.services.length > 5 ? 5 : _data.services.length;
        _adPosition = Random().nextInt(maxPos);
      } else {
        _sectionAd = null;
        _adPosition = -1;
      }

      // 🛡️ جلب بيانات المزودين (الاسم + التوثيق) لكل خدمة
      await _enrichServicesWithProviderData(_data.services);

    } catch (e) {
      // ✅ التقاط الفشل الموحد وعرض رسالته العربية
      if (e is Failure) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'حدث خطأ غير متوقع أثناء تحميل البيانات';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🛡️ جلب بيانات المزودين لكل خدمة (الاسم + التوثيق)
  Future<void> _enrichServicesWithProviderData(List services) async {
    // جمع الـ provider IDs الفريدة
    final uniqueIds = <int>{};
    for (final service in services) {
      if (service.providerId > 0) {
        uniqueIds.add(service.providerId);
      }
    }

    // جلب بيانات كل مزود (مع تخزين مؤقت لعدم التكرار)
    final Map<int, Map<String, dynamic>> providerCache = {};
    for (final id in uniqueIds) {
      try {
        final profile = await _homeRepository.fetchUserProfile(id);
        providerCache[id] = {
          'name': profile.name,
          'isVerified': profile.verificationProvider,
          'verifiedUntil': profile.providerVerifiedUntil,
        };
      } catch (_) {
        // فشل جلب بيانات مزود معين — نتجاهل ونكمل
      }
    }

    // تحديث كل خدمة ببيانات مزودها
    for (final service in services) {
      final providerData = providerCache[service.providerId];
      if (providerData != null) {
        service.updateProviderInfo(
          name: providerData['name'],
          verified: providerData['isVerified'],
          verifiedDate: providerData['verifiedUntil'],
        );
      }
    }
  }

  // 📢 تتبع الإعلانات
  void trackAdView(int adId) => _advertisementRepository.trackView(adId);
  void trackAdClick(int adId) => _advertisementRepository.trackClick(adId);
}
