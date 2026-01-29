import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seeker/core/storage/token_storage.dart';
import '../repositories/home_repository.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

/// 🧠 اسم الملف: home_view_model.dart
/// 📝 الوصف: مسؤول عن إدارة حالة ومنطق الصفحة الرئيسية.
/// يقوم بربط واجهة المستخدم (HomeView) مع مستودع البيانات (HomeRepository).
/// يتعامل مع تحميل البيانات، تحديث الموقع، وإدارة حالات التحميل والأخطاء.

class HomeViewModel extends ChangeNotifier {
  final HomeRepository
  _homeRepository; // مستودع البيانات لجلب التصنيفات والخدمات
  final TokenStorage _tokenStorage; // للوصول لبيانات المستخدم المخزنة محلياً

  HomeViewModel(this._homeRepository, this._tokenStorage);

  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------

  // قوائم البيانات
  List<CategoryModel> _categories = [];
  List<ServiceModel> _popularServices = [];

  // حالات التحميل والأخطاء
  bool _isLoading = false;
  String _errorMessage = '';

  // بيانات المستخدم والموقع
  String _userName = 'زائر';
  String _role = 'زائر';
  String _currentAddress = 'اليمن التعيس';
  bool _isLocationLoading = false;

  // Getters للوصول للمتغيرات من الواجهة
  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get popularServices => _popularServices;
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
        _userName = 'زائر';
        _role = 'زائر';
      }

      // 2. جلب التصنيفات والخدمات من السيرفر بالتوازي لتقليل وقت الانتظار
      final results = await Future.wait([
        _homeRepository.fetchCategories(),
        _homeRepository.fetchPopularServices(),
      ]);
      // print(results);

      // 3. تحديث القوائم بالبيانات القادمة
      _categories = results[0] as List<CategoryModel>;
      _popularServices = results[1] as List<ServiceModel>;
    } catch (e) {
      _errorMessage = e.toString();
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
        return 'خدمة الموقع غير مفعلة، يرجى تفعيل GPS';
      }

      // 2. التحقق من الصلاحيات وطلبها إذا لزم الأمر
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'تم رفض إذن الوصول للموقع';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'إذن الموقع مرفوض بشكل دائم، يرجى تفعيله من الإعدادات';
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
          if (city.isEmpty) city = 'موقع غير معروف';

          _currentAddress = city;
        } else {
          _currentAddress = 'موقع غير معروف';
        }
      } catch (e) {
        // في حال فشل تحويل الإحداثيات لاسم، نعرض الإحداثيات كنص
        _currentAddress =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      return null; // نجاح (لا يوجد خطأ لعرضه)
    } catch (e) {
      debugPrint('Location Error: $e');
      return 'فشل تحديد الموقع: $e';
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }
}
