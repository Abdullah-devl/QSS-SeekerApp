import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import '../../../core/errors/api_error_handler.dart';

class PolicyViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  PolicyViewModel(this._settingsRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _policyContent;
  String? get policyContent => _policyContent;

  String? _policyTitle;
  String? get policyTitle => _policyTitle;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// جلب سياسة الخصوصية بناءً على الدور.
  Future<void> fetchPolicy(String role) async {
    _isLoading = true;
    _errorMessage = null;
    _policyContent = '';
    _policyTitle = null;
    notifyListeners();

    try {
      final data = await _settingsRepository.getPolicy(role);

      final dynamic rawData = data['${role}_policy'] ?? data['policy'];

      if (rawData is Map<String, dynamic>) {
        _policyTitle = rawData['display_name']?.toString() ?? 'سياسة الخصوصية';
        _policyContent = rawData['value']?.toString() ?? '';
      } else if (rawData is String) {
        _policyTitle = 'سياسة الخصوصية';
        _policyContent = rawData;
      } else {
        // إذا لم نجد مفتاحاً صريحاً، نبحث عن أي مفتاح يحتوي على 'value' داخل data نفسها
        final nestedKey = data.keys.firstWhere(
          (k) => data[k] is Map && (data[k] as Map).containsKey('value'),
          orElse: () => '',
        );

        if (nestedKey.isNotEmpty) {
          final nestedData = data[nestedKey] as Map<String, dynamic>;
          _policyTitle =
              nestedData['display_name']?.toString() ?? 'سياسة الخصوصية';
          _policyContent = nestedData['value']?.toString() ?? '';
        } else {
          // محاولة أخيرة: إذا كانت الـ data نفسها تحتوي على display_name أو value
          _policyTitle = data['display_name']?.toString() ?? 'سياسة الخصوصية';
          _policyContent =
              data['value']?.toString() ?? (rawData?.toString() ?? '');
        }
      }

      // إذا ظل المحتوى فارغاً والـ data تحتوي على نص مباشر تحت المفتاح المطلوب
      if ((_policyContent?.isEmpty ?? true) &&
          data.containsKey('${role}_policy')) {
        _policyContent = data['${role}_policy'].toString();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// الموافقة على السياسة.
  Future<bool> agreeToPolicy(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _settingsRepository.agreeToPolicy(role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
