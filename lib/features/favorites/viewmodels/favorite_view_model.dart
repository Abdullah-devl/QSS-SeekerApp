import 'package:flutter/material.dart';
import 'package:seeker/features/home/models/category_model.dart';
import 'package:seeker/features/home/models/service_model.dart';

class FavoriteViewModel extends ChangeNotifier {
  FavoriteViewModel() {
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

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 📥 تحميل البيانات الأولية (محاكاة للـ API)
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 💡 هنا سيتم استدعاء الـ API الفعلي لجلب الفئات والخدمات المفضلة
      // _allFavoriteServices = await _repository.getFavorites();

      await Future.delayed(const Duration(milliseconds: 800)); // محاكاة

      // أقسام الفلترة العلوية (نضيف "الكل" يدوياً برقم 0)
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

      // محاكاة بيانات الخدمات المفضلة كما في التصميم
      _allFavoriteServices = [
        ServiceModel(
          id: 101,
          categoryId: 1,
          title: 'صيانة وإصلاح المكيفات',
          description: '',
          price: 50.0,
          rating: 4.8,
          imageUrl: 'https://example.com/ac.jpg', // ضع رابط حقيقي للتجربة
          providerName: 'شركة البركة للخدمات الفنية',
        ),
        ServiceModel(
          id: 102,
          categoryId: 2,
          title: 'تنظيف شامل للمنازل',
          description: '',
          price: 200.0,
          rating: 4.9,
          imageUrl: 'https://example.com/clean.jpg',
          providerName: 'خدمات النظافة الراقية',
        ),
      ];
    } catch (e) {
      _errorMessage = 'حدث خطأ في جلب المفضلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🎯 تغيير الفلتر
  void selectCategory(int id) {
    if (_selectedCategoryId != id) {
      _selectedCategoryId = id;
      notifyListeners();
    }
  }

  /// 💔 إزالة من المفضلة
  Future<void> removeFromFavorites(int serviceId) async {
    // 💡 هنا نرسل طلب للـ API للحذف
    // await _repository.toggleFavorite(serviceId);

    // التحديث المحلي الفوري (Optimistic UI)
    _allFavoriteServices.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }
}
