import 'package:flutter/material.dart';
import 'package:seeker/features/home/models/category_model.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/favorites/repositories/favorite_repository.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;

  FavoriteViewModel(this._repository) {
    _loadInitialData();
  }

  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedCategoryId = 0; // 0 تعني "الكل"

  List<CategoryModel> _filterCategories = [];
  List<ServiceModel> _allFavoriteServices = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedCategoryId => _selectedCategoryId;
  List<CategoryModel> get filterCategories => _filterCategories;

  /// 🎛️ جلب الخدمات المفضلة المفلترة حسب القسم المختار
  List<ServiceModel> get filteredFavorites {
    if (_selectedCategoryId == 0) {
      return _allFavoriteServices;
    }
    return _allFavoriteServices
        .where((s) => s.categoryId == _selectedCategoryId)
        .toList();
  }

  /// ✅ التحقق مما إذا كانت الخدمة مفضلة أم لا عبر معرفها (ID)
  bool isServiceFavorite(int serviceId) {
    return _allFavoriteServices.any((s) => s.id == serviceId);
  }

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 📥 تحميل البيانات الفعلية من الـ API
  Future<void> _loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // جلب الخدمات المفضلة من المستودع
      _allFavoriteServices = await _repository.getFavorites();

      // أقسام الفلترة العلوية (نضيف "الكل" يدوياً برقم 0)
      // ملاحظة: يمكن جلب هذه التصنيفات من السيرفر أيضاً إذا لزم الأمر
      _filterCategories = [
        CategoryModel(id: 0, name: 'الكل', iconPath: 'grid_view'),
        CategoryModel(id: 1, name: 'صيانة', iconPath: 'build_outlined'),
        CategoryModel(
          id: 2,
          name: 'تنظيف',
          iconPath: 'cleaning_services_outlined',
        ),
        CategoryModel(id: 3, name: 'نقل', iconPath: 'local_shipping_outlined'),
      ];
    } catch (e) {
      _errorMessage = 'حدث خطأ في جلب المفضلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 تحديث البيانات يدويًا
  Future<void> refreshFavorites() async {
    await _loadInitialData();
  }

  /// 🎯 تغيير الفلتر
  void selectCategory(int id) {
    if (_selectedCategoryId != id) {
      _selectedCategoryId = id;
      notifyListeners();
    }
  }

  /// ❤️ تبديل حالة المفضلة (إضافة/حذف)
  Future<void> toggleFavorite(ServiceModel service) async {
    final originalState = service.isFavorite;
    
    // التحديث المحلي الفوري (Optimistic UI)
    service.isFavorite = !service.isFavorite;
    if (!service.isFavorite) {
      _allFavoriteServices.removeWhere((s) => s.id == service.id);
    } else {
      // إذا تمت الإضافة، نحتاج لإضافته للقائمة المحلية (قد يتطلب جلب بياناته كاملة إذا لم تكن موجودة)
      // لكن غالباً يتم التفعيل من شاشة البحث/الرئيسية
      if (!_allFavoriteServices.any((s) => s.id == service.id)) {
        _allFavoriteServices.add(service);
      }
    }
    notifyListeners();

    try {
      final success = await _repository.toggleFavorite(service.id);
      if (!success) {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      // التراجع عن التغيير في حال فشل الـ API
      service.isFavorite = originalState;
      if (originalState) {
        if (!_allFavoriteServices.any((s) => s.id == service.id)) {
          _allFavoriteServices.add(service);
        }
      } else {
        _allFavoriteServices.removeWhere((s) => s.id == service.id);
      }
      _errorMessage = 'فشل تحديث المفضلة';
      notifyListeners();
    }
  }

  /// 💔 إزالة من المفضلة (دالة مساعدة للشاشة الحالية)
  Future<void> removeFromFavorites(int serviceId) async {
    final service = _allFavoriteServices.firstWhere((s) => s.id == serviceId);
    await toggleFavorite(service);
  }
}
