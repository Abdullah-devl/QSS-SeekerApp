// import 'package:flutter/material.dart';
// import 'package:seeker/core/errors/failure.dart';
// // تأكد من مسار الـ repository لديك
// // import '../repositories/home_repository.dart';
// import '../models/service_model.dart';

// /// 📂 اسم الملف: service_details_view_model.dart
// class ServiceDetailsViewModel extends ChangeNotifier {
//   // final HomeRepository _repository; // فك التعليق عند ربط الـ API الحقيقي

//   // ServiceDetailsViewModel(this._repository);
//   ServiceDetailsViewModel();

//   bool _isLoading = false;
//   String _errorMessage = '';
//   ServiceModel? _service;
//   bool _isFavorite = false;

//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   ServiceModel? get service => _service;
//   bool get isFavorite => _isFavorite;

//   /// 🚀 جلب بيانات الخدمة التفصيلية من الـ API
//   Future<void> fetchServiceDetails(
//     int serviceId,
//     ServiceModel initialData,
//   ) async {
//     _isLoading = true;
//     _service =
//         initialData; // نضع البيانات الأولية حتى يكتمل التحميل لكي لا تنتظر الشاشة
//     notifyListeners();

//     try {
//       // 💡 هنا سيتم استدعاء الـ API الفعلي لجلب باقي التفاصيل (الصور، التقييمات، البنوك)
//       // _service = await _repository.fetchServiceDetails(serviceId);

//       // محاكاة تأخير الشبكة للتجربة
//       await Future.delayed(const Duration(milliseconds: 500));

//       // _isFavorite = await _repository.checkFavoriteStatus(serviceId);
//     } catch (e) {
//       if (e is Failure) {
//         _errorMessage = e.message;
//       } else {
//         _errorMessage = 'حدث خطأ غير متوقع';
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// 💖 تغيير حالة المفضلة
//   void toggleFavorite() {
//     _isFavorite = !_isFavorite;
//     notifyListeners();
//     // 💡 إرسال الطلب للـ API
//     // _repository.toggleFavorite(_service!.id);
//   }
// }
import 'package:flutter/material.dart';
import '../models/service_model.dart';
// 🚀 استدعاء الريبوزيتوري
// import '../repositories/home_repository.dart'; 

/// 📂 اسم الملف: service_details_view_model.dart
class ServiceDetailsViewModel extends ChangeNotifier {
  // final HomeRepository _repository;
  // ServiceDetailsViewModel(this._repository);

  bool _isLoading = false;
  String _errorMessage = '';
  ServiceModel? _service;
  bool _isFavorite = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ServiceModel? get service => _service;
  bool get isFavorite => _isFavorite;

  /// 🚀 جلب بيانات الخدمة التفصيلية من الـ API
  Future<void> fetchServiceDetails(int serviceId, ServiceModel initialData) async {
    // 1️⃣ نضع البيانات الأولية فوراً لكي تفتح الشاشة بدون انتظار (Optimistic UI)
    _service = initialData; 
    _isLoading = true;
    notifyListeners();

    try {
      // 2️⃣ نطلب البيانات الكاملة (والتي بداخلها الخدمات الفرعية) من السيرفر
      // _service = await _repository.fetchServiceById(serviceId);

      // محاكاة للإنترنت (للتجربة) - احذفها بعد ربط الريبوزيتوري
      await Future.delayed(const Duration(milliseconds: 800)); 
      
    } catch (e) {
      _errorMessage = 'تعذر تحديث البيانات، نعرض البيانات المحفوظة مسبقاً.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 💖 تغيير حالة المفضلة
  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
    // 💡 إرسال الطلب للـ API مستقبلاً
  }
}