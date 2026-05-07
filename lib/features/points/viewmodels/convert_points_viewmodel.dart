// مسار الملف: lib/features/points/viewmodels/convert_points_viewmodel.dart

import 'package:flutter/material.dart';
import '../repositories/points_repository.dart';

class ConvertPointsViewModel extends ChangeNotifier {
  final PointsRepository _repository;

  ConvertPointsViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _amount = 0;
  double get amount => _amount;

  /// حساب المبلغ الإجمالي مع الـ 1% مكافأة
  double get totalWithBonus => _amount * 1.01;

  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  /// 🚀 تنفيذ عملية التحويل بعد التأكيد
  // Future<bool> convertPoints({
  //   required double availablePaidPoints,
  // }) async {
  //   // 1. التحقق من الرصيد
  //   if (_amount <= 0) {
  //     _errorMessage = 'amount_required';
  //     notifyListeners();
  //     return false;
  //   }

  //   if (_amount > availablePaidPoints) {
  //     _errorMessage = 'insufficient_balance';
  //     notifyListeners();
  //     return false;
  //   }

  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     await _repository.convertPoints(_amount);
  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
