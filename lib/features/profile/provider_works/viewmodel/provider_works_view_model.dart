import 'package:flutter/material.dart';
import '../../models/work_model.dart';
import '../../repositories/profile_repository.dart';

/// 📂 اسم الملف: provider_works_view_model.dart
/// 📝 الوصف: لإدارة حالة جلب وعرض الأعمال السابقة لمزود معين.
class ProviderWorksViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final int userId;

  ProviderWorksViewModel(
    this._repository, {
    required this.userId,
    List<WorkModel>? initialWorks,
  }) {
    if (initialWorks != null && initialWorks.isNotEmpty) {
      _works = initialWorks;
      _isLoading = false;
    } else {
      fetchWorks();
    }
  }

  List<WorkModel> _works = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WorkModel> get works => _works;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 📸 جلب الأعمال السابقة للمزود من السيرفر.
  Future<void> fetchWorks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _works = await _repository.fetchProviderWorks(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
