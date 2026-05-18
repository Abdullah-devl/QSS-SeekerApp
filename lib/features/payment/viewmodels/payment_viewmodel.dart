import 'dart:io';
import 'package:flutter/material.dart';
import '../models/points_balance_model.dart';
import '../repositories/payment_repository.dart';

/// 📂 اسم الملف: payment_viewmodel.dart
/// 📝 الوصف: مدير الحالة الخاص بصفحة الدفع.

enum PaymentMethod { points, bond }

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentViewModel(this._repository);

  // --- الحالة (State) ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PointsBalanceModel _balance = PointsBalanceModel.empty();
  PointsBalanceModel get balance => _balance;

  PaymentMethod _selectedMethod = PaymentMethod.points;
  PaymentMethod get selectedMethod => _selectedMethod;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  // --- العمليات (Actions) ---

  void setPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  /// 💰 جلب رصيد النقاط
  Future<void> fetchBalance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _balance = await _repository.getPointsBalance();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  /// 🌟 السداد بالنقاط
  Future<bool> payByPoints(String requestId, double points) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.payByPoints(requestId: requestId, transferredPoints: points);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 📄 السداد بالسند
  Future<bool> payByBond(String requestId, double amount, String bondNumber) async {
    if (bondNumber.trim().isEmpty) {
      _errorMessage = "enterBondNumberError";
      notifyListeners();
      return false;
    }
    if (_selectedImage == null) {
      _errorMessage = "selectReceiptImageError";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitBond(
        requestId: requestId,
        amount: amount,
        image: _selectedImage!,
        bondNumber: bondNumber,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
