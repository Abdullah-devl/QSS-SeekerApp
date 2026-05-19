import 'package:flutter/material.dart';
import '../../repository/request_repository.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: meeting_request_view_model.dart
/// 📝 الوصف: لإدارة حالة صفحة "طلب الحضور" (Meeting Request).
class MeetingRequestViewModel extends ChangeNotifier {
  final RequestRepository _repository;
  final int providerId;

  MeetingRequestViewModel(this._repository, {required this.providerId});

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _address;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get address => _address;

  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();

  /// 📍 تحديث الموقع والعنوان من الخريطة أو GPS
  void updateLocation(double lat, double lng, String addr) {
    latController.text = lat.toString();
    longController.text = lng.toString();
    _address = addr;
    notifyListeners();
  }

  /// 🚀 إرسال طلب الحضور.
  Future<void> sendRequest() async {
    final lat = double.tryParse(latController.text);
    final long = double.tryParse(longController.text);

    if (lat == null || long == null) {
      _errorMessage = 'الرجاء اختيار الموقع الجغرافي للطلب';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final successMsg = await _repository.sendMeetingRequest(
        providerId: providerId,
        latitude: lat,
        longitude: long,
      );

      if (successMsg != null) {
        _successMessage = successMsg;
        latController.clear();
        longController.clear();
      } else {
        _errorMessage = 'حدث خطأ غير متوقع أثناء إرسال الطلب';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      developer.log('❌ Error: $_errorMessage', name: 'MeetingRequestViewModel');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    latController.dispose();
    longController.dispose();
    super.dispose();
  }
}
