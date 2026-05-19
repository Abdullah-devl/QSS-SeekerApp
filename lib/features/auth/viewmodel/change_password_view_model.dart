import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ChangePasswordViewModel(this._authRepository);

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _obscureOld = true;
  bool get obscureOld => _obscureOld;

  bool _obscureNew = true;
  bool get obscureNew => _obscureNew;

  bool _obscureConfirm = true;
  bool get obscureConfirm => _obscureConfirm;

  void toggleOld() { _obscureOld = !_obscureOld; notifyListeners(); }
  void toggleNew() { _obscureNew = !_obscureNew; notifyListeners(); }
  void toggleConfirm() { _obscureConfirm = !_obscureConfirm; notifyListeners(); }

  Future<bool> changePassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _errorMessage = l10n.pleaseFillFields;
      notifyListeners();
      return false;
    }

    if (newPass.length < 8) {
      _errorMessage = l10n.passwordMinLength;
      notifyListeners();
      return false;
    }

    if (newPass != confirmPass) {
      _errorMessage = l10n.passwordsDoNotMatch;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.changePassword(
        oldPassword: oldPass,
        password: newPass,
        passwordConfirmation: confirmPass,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        _errorMessage = (data is Map && data.containsKey('message')) 
            ? context.tr(data['message'].toString()) 
            : l10n.changePasswordFailed;
      } else {
        _errorMessage = context.tr(e.toString().replaceAll('Exception: ', ''));
      }
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
