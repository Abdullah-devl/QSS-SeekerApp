import 'package:flutter/material.dart';
import '../../repository/request_repository.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: custom_request_view_model.dart
/// 📝 الوصف: لإدارة حالة صفحة "الطلب المخصص".
class CustomRequestViewModel extends ChangeNotifier {
  final RequestRepository _repository;
  final int providerId;

  CustomRequestViewModel(this._repository, {required this.providerId});

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _address;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get address => _address;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();

  /// 📍 تحديث الموقع والعنوان من الخريطة أو GPS
  void updateLocation(double lat, double lng, String addr) {
    latController.text = lat.toString();
    longController.text = lng.toString();
    _address = addr;
    notifyListeners();
  }

  /// 🚀 إرسال الطلب إلى السيرفر.
  Future<void> sendRequest() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      _errorMessage = 'الرجاء كتابة تفاصيل الطلب';
      notifyListeners();
      return;
    }

    if (providerId == 0) {
      _errorMessage = 'معرف مقدم الخدمة غير صحيح، يرجى إعادة تحميل الصفحة';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    developer.log(
      '🚀 [CustomRequestViewModel] Starting submission for provider: $providerId',
      name: 'CustomRequestViewModel',
    );

    try {
      final lat = double.tryParse(latController.text);
      final long = double.tryParse(longController.text);

      final successMsg = await _repository.sendCustomRequest(
        providerId: providerId,
        message: messageController.text.trim(),
        latitude: lat,
        longitude: long,
      );

      if (successMsg != null) {
        developer.log(
          '✨ [CustomRequestViewModel] Submission Success!',
          name: 'CustomRequestViewModel',
        );
        _successMessage = successMsg;
        messageController.clear();
        latController.clear();
        longController.clear();
      } else {
        developer.log(
          '⚠️ [CustomRequestViewModel] Submission failed but no error thrown',
          name: 'CustomRequestViewModel',
        );
        _errorMessage = 'حدث خطأ غير متوقع أثناء إرسال الطلب';
      }
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().split('Exception:').last.trim()
          : e.toString();
      developer.log(
        '❌ [CustomRequestViewModel] Submission Error: $_errorMessage',
        name: 'CustomRequestViewModel',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    latController.dispose();
    longController.dispose();
    super.dispose();
  }
}
