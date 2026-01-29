import 'package:flutter/material.dart';
import 'package:seeker/core/errors/failure.dart';
import '../repositories/home_repository.dart';
import '../models/category_details_model.dart';

/// 📂 اسم الملف: category_details_view_model.dart
/// 📝 الوصف: نموذج العرض (ViewModel) لصفحة تفاصيل التصنيف.
/// مسؤول عن جلب البيانات (تصنيفات فرعية، خدمات، موصى بهم) وإدارة حالة التحميل.
class CategoryDetailsViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  CategoryDetailsViewModel(this._homeRepository);

  // ---------------------------------------------------------------------------
  // 📊 الحالة (State)
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String _errorMessage = '';
  CategoryDetailsModel _data = CategoryDetailsModel();

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  CategoryDetailsModel get data => _data;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 🚀 جلب تفاصيل التصنيف بناءً على [categoryId].
  // category_details_view_model.dart
  Future<void> fetchCategoryDetails(int categoryId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _data = await _homeRepository.fetchCategoryDetails(categoryId);
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
}
