import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

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
    _policyContent = null;
    _policyTitle = null;
    notifyListeners();

    try {
      final data = await _settingsRepository.getPolicy(role);
      
      // استخراج الكائن الداخلي (seeker_policy أو provider_policy)
      Map<String, dynamic>? policyData;
      
      if (data.containsKey('${role}_policy')) {
        policyData = data['${role}_policy'] as Map<String, dynamic>?;
      } else if (data.containsKey('policy')) {
        policyData = data['policy'] as Map<String, dynamic>?;
      } else {
        // البحث عن أي مفتاح يحتوي على 'display_name' و 'value'
        final nestedKey = data.keys.firstWhere(
          (k) => data[k] is Map && (data[k] as Map).containsKey('value'),
          orElse: () => '',
        );
        if (nestedKey.isNotEmpty) {
          policyData = data[nestedKey] as Map<String, dynamic>?;
        }
      }

      // استخراج النواتج النهائية
      final finalData = policyData ?? data;
      _policyTitle = finalData['display_name']?.toString() ?? 'سياسة الخصوصية';
      _policyContent = finalData['value']?.toString() ?? '';
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
