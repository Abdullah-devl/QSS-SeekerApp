import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../home/services/models/service_model.dart';
import '../repositories/search_repository.dart';

/// 📂 اسم الملف: search_viewmodel.dart
/// 📝 الوصف: إدارة حالة صفحة البحث المتقدم والفلترة.

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository;

  SearchViewModel(this._repository);

  // ---------------------------------------------------------------------------
  // 📊 الحالة (State)
  // ---------------------------------------------------------------------------
  List<ServiceModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  // فلاتر البحث
  String _query = '';
  int? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  bool _isVerifiedOnly = false; // ✅ فلتر الموثقين
  bool _isLocationFilterEnabled = false; // 📍 فلتر الموقع المفعّل
  
  // الموقع الجغرافي
  Position? _currentPosition; // الموقع التلقائي (GPS)
  double? _pickedLat;        // الموقع المختار يدوياً من الخريطة
  double? _pickedLng;
  String? _pickedAddress;
  
  bool _shouldOpenFilters = false; // 🚩 علم لفتح الفلاتر تلقائياً

  // Getters
  List<ServiceModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  int? get selectedCategoryId => _selectedCategoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool get isVerifiedOnly => _isVerifiedOnly;
  bool get isLocationFilterEnabled => _isLocationFilterEnabled;
  double? get pickedLat => _pickedLat;
  double? get pickedLng => _pickedLng;
  String? get pickedAddress => _pickedAddress;
  bool get shouldOpenFilters => _shouldOpenFilters;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// تفعيل فتح الفلاتر تلقائياً عند الانتقال للصفحة
  void triggerFilters() {
    _shouldOpenFilters = true;
    notifyListeners();
  }

  /// مسح طلب فتح الفلاتر
  void clearFiltersTrigger() {
    _shouldOpenFilters = false;
    notifyListeners();
  }

  /// تحديث النص المراد البحث عنه
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  /// تحديث القسم المختار
  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// تحديث نطاق السعر
  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }
  
  /// تحديث فلتر الموثقين
  void setVerifiedOnly(bool value) {
    _isVerifiedOnly = value;
    notifyListeners();
  }

  /// تحديث تفعيل فلتر الموقع
  void setLocationFilterEnabled(bool value) {
    _isLocationFilterEnabled = value;
    notifyListeners();
  }

  /// تحديث الموقع المختار يدوياً من الخريطة
  void setPickedLocation(double? lat, double? lng, String? address) {
    _pickedLat = lat;
    _pickedLng = lng;
    _pickedAddress = address;
    // عند اختيار موقع يدوياً، نقوم بتفعيل فلتر الموقع تلقائياً
    if (lat != null && lng != null) {
      _isLocationFilterEnabled = true;
    }
    notifyListeners();
  }

  /// إعادة تعيين كافة الفلاتر
  void resetFilters() {
    _query = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _isVerifiedOnly = false;
    _isLocationFilterEnabled = false;
    _pickedLat = null;
    _pickedLng = null;
    _pickedAddress = null;
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// 🚀 تنفيذ عملية البحث
  Future<void> performSearch() async {
    // إذا لم يكن هناك استعلام ولا فلاتر، نكتفي بمسح النتائج
    if (_query.isEmpty &&
        _selectedCategoryId == null &&
        _minPrice == null &&
        _maxPrice == null &&
        !_isVerifiedOnly &&
        !_isLocationFilterEnabled) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // محاولة جلب الموقع قبل البحث لحساب المسافات إذا كان فلتر الموقع مفعلاً
      if (_isLocationFilterEnabled) {
        await _fetchCurrentLocation();
      }

      // تنظيف قيم السعر قبل الإرسال (إذا كانت تغطي النطاق الكامل لا نرسلها لتقليل القيود)
      double? finalMin = _minPrice == 0 ? null : _minPrice;
      double? finalMax = (_maxPrice == null || _maxPrice == 100000) ? null : _maxPrice;

      _results = await _repository.searchServices(
        query: _query,
        categoryId: _selectedCategoryId,
        minPrice: finalMin,
        maxPrice: finalMax,
        isVerified: _isVerifiedOnly,
        lat: _isLocationFilterEnabled ? (_pickedLat ?? _currentPosition?.latitude) : null,
        lng: _isLocationFilterEnabled ? (_pickedLng ?? _currentPosition?.longitude) : null,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📍 جلب الموقع الجغرافي الحالي بشكل صامت
  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      // Logic remains
    }
  }
}
