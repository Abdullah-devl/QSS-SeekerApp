import 'package:flutter/material.dart';
import '../models/system_complaint_model.dart';
import '../repositories/settings_repository.dart';

class SystemComplaintsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  SystemComplaintsViewModel(this._settingsRepository);

  List<SystemComplaintModel> _complaints = [];
  List<SystemComplaintModel> get complaints => _complaints;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// جلب قائمة الشكاوى بناءً على مصدر التطبيق.
  Future<void> fetchComplaints(String appSource) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final source = (appSource == 'guest' || appSource == 'seeker') ? 'seeker' : 'provider';
      _complaints = await _settingsRepository.getSystemComplaints(source);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إرسال شكوى جديدة.
  Future<bool> createComplaint({
    required String title,
    required String type,
    required String content,
    required String appSource,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final source = (appSource == 'guest' || appSource == 'seeker') ? 'seeker' : 'provider';
      
      final data = {
        'title': title,
        'type': type,
        'content': content,
        'app_source': source,
      };

      await _settingsRepository.createSystemComplaint(data);
      
      _isSaving = false;
      // تحديث القائمة بعد الإضافة الناجحة
      await fetchComplaints(source);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
