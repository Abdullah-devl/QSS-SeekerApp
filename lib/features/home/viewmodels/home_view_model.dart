import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seeker/core/services/notification_service.dart';
import 'package:seeker/core/storage/token_storage.dart';
import '../repositories/home_repository.dart';
import '../models/category_model.dart';
import '../services/models/service_model.dart';
import '../models/advertisement_model.dart';
import '../repositories/advertisement_repository.dart';
import '../../../core/errors/api_error_handler.dart';

/// 🧠 اسم الملف: home_view_model.dart
/// 📝 الوصف: مسؤول عن إدارة حالة ومنطق الصفحة الرئيسية.
/// يقوم بربط واجهة المستخدم (HomeView) مع مستودع البيانات (HomeRepository).
/// يتعامل مع تحميل البيانات، تحديث الموقع، وإدارة حالات التحميل والأخطاء.

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;
  final AdvertisementRepository
  _advertisementRepository; // المستودع الخاص بالإعلانات
  final TokenStorage _tokenStorage; // للوصول لبيانات المستخدم المخزنة محلياً

  HomeViewModel(
    this._homeRepository,
    this._advertisementRepository,
    this._tokenStorage,
  );

  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------

  // قوائم البيانات
  List<CategoryModel> _categories = [];
  List<ServiceModel> _recommendedServices = [];
  List<AdvertisementModel> _carouselAds = []; // إعلانات البانر المتحرك
  List<AdvertisementModel> _popupAds = []; // الإعلانات المنبثقة

  // حالات التحميل والأخطاء
  bool _isLoading = false;
  String _errorMessage = '';

  // بيانات المستخدم والموقع
  String _userName = 'Guest';
  String _role = 'guest';
  String _currentAddress = 'Yemen';
  bool _isLocationLoading = false;

  // Getters للوصول للمتغيرات من الواجهة
  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get recommendedServices => _recommendedServices;
  List<AdvertisementModel> get carouselAds => _carouselAds;
  List<AdvertisementModel> get popupAds => _popupAds;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get userName => _userName;
  String get role => _role;
  String get currentAddress => _currentAddress;
  bool get isLocationLoading => _isLocationLoading;

  // حالة التنقل (Navigation State)
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// 🔄 تحديث مؤشر الصفحة الحالية (Tab Index)
  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 🚀 دالة لجلب البيانات عند فتح الصفحة.
  /// تقوم بتحميل اسم المستخدم، التصنيفات، والخدمات الشائعة بالتوازي.
  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // تنبيه الواجهة لبدء عرض مؤشر التحميل

    try {
      // 1. جلب بيانات المستخدم المحفوظة محلياً
      final userData = await _tokenStorage.getUserData();

      if (userData != null &&
          userData['name'] != null &&
          userData['role'] != null) {
        _userName = userData['name']!;
        _role = userData['role']!;
      } else {
        _userName = 'Guest';
        _role = 'guest';
      }

      // 2. جلب التصنيفات والخدمات والإعلانات من السيرفر بالتوازي
      String userType = _role == 'guest'
          ? 'all'
          : (_role == 'provider' ? 'provider' : 'client');

      final results = await Future.wait([
        _homeRepository.fetchCategories(),
        _homeRepository.fetchRecommendedServices(),
        _advertisementRepository.fetchAdvertisements(userType),
      ]);

      // 3. تحديث القوائم بالبيانات القادمة وتصنيف الإعلانات
      _categories = results[0] as List<CategoryModel>;
      _recommendedServices = results[1] as List<ServiceModel>;

      final allAds = results[2] as List<AdvertisementModel>;
      _carouselAds = allAds
          .where((ad) => ad.type == 'carousel' || ad.type == 'banner')
          .toList();
      _popupAds = allAds.where((ad) => ad.type == 'popup').toList();

      // 🔔 إرسال توكن الإشعارات للسيرفر لضمان المزامنة
      print('🔔 [HOME VM]: User Role is: $_role');
      if (_role != 'guest' && _role != 'زائر') {
        print('🚀 [HOME VM]: Triggering token update...');
        NotificationService().updateTokenToServer();
      } else {
        print('ℹ️ [HOME VM]: Token update skipped (Guest Mode)');
      }
    } catch (e) {
      print('❌ [HOME VM]: Error loading home data: $e');
      _errorMessage = ApiErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners(); // تحديث الواجهة لعرض البيانات أو الخطأ
    }
  }

  /// 📍 تحديث الموقع الجغرافي للمستخدم.
  /// يطلب صلاحيات الموقع، يجلب الإحداثيات، ثم يحولها إلى اسم مدينة (Reverse Geocoding).
  /// يرجع `null` في حال النجاح، أو رسالة خطأ نصية في حال الفشل.
  Future<String?> updateLocation() async {
    _isLocationLoading = true;
    notifyListeners();

    try {
      // 1. التحقق من تفعيل خدمة الموقع (GPS)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'locationServiceDisabled';
      }

      // 2. التحقق من الصلاحيات وطلبها إذا لزم الأمر
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'locationPermissionDenied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'locationPermissionForeverDenied';
      }

      // 3. جلب الإحداثيات الحالية
      // نستخدم دقة متوسطة للسرعة وضمان العمل على معظم الأجهزة
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // 4. تحويل الإحداثيات لاسم مدينة (Reverse Geocoding)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // نأخذ المدينة (locality) أو المنطقة (administrativeArea) كبديل
          String city = place.locality ?? '';
          String area =
              place.subAdministrativeArea ?? place.administrativeArea ?? '';

          // منطق عرض الاسم الأنسب
          if (city.isEmpty) city = area;
          if (city.isEmpty) city = 'unknownLocation';

          _currentAddress = city;
        } else {
          _currentAddress = 'unknownLocation';
        }
      } catch (e) {
        // في حال فشل تحويل الإحداثيات لاسم، نعرض الإحداثيات كنص
        _currentAddress =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      return null; // نجاح (لا يوجد خطأ لعرضه)
    } catch (e) {
      debugPrint('Location Error: $e');
      return 'locationUpdateFailed';
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // 📢 تتبع الإعلانات (Ad Tracking)
  // ---------------------------------------------------------------------------

  /// تتبع مشاهدة الإعلان
  void trackAdView(int adId) {
    _advertisementRepository.trackView(adId);
  }

  /// تتبع النقر على الإعلان
  void trackAdClick(int adId) {
    _advertisementRepository.trackClick(adId);
  }
}
