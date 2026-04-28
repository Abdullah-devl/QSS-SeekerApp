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
  Position? _currentPosition;
  bool _shouldOpenFilters = false; // 🚩 علم لفتح الفلاتر تلقائياً

  // Getters
  List<ServiceModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  int? get selectedCategoryId => _selectedCategoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
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

  /// إعادة تعيين كافة الفلاتر
  void resetFilters() {
    _query = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// 🚀 تنفيذ عملية البحث
  Future<void> performSearch() async {
    // إذا لم يكن هناك استعلام ولا فلاتر، نكتفي بمسح النتائج
    if (_query.isEmpty && _selectedCategoryId == null && _minPrice == null && _maxPrice == null) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // محاولة جلب الموقع قبل البحث لحساب المسافات
      await _fetchCurrentLocation();

      // تنظيف قيم السعر قبل الإرسال (إذا كانت تغطي النطاق الكامل لا نرسلها لتقليل القيود)
      double? finalMin = _minPrice == 0 ? null : _minPrice;
      double? finalMax = (_maxPrice == null || _maxPrice == 100000) ? null : _maxPrice;

      _results = await _repository.searchServices(
        query: _query,
        categoryId: _selectedCategoryId,
        minPrice: finalMin,
        maxPrice: finalMax,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
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
