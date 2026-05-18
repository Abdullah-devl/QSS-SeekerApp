// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/provider_request_model.dart';
// import '../repositories/be_provider_repository.dart';

// /// 📂 اسم الملف: be_provider_view_model.dart
// /// 📝 الوصف: ViewModel لإدارة منطق صفحة "كن مزود خدمة".
// class BeProviderViewModel extends ChangeNotifier {
//   final BeProviderRepository _repository;

//   BeProviderViewModel(this._repository);

//   // ---------------------------------------------------------------------------
//   // 📊 المتغيرات (State)
//   // ---------------------------------------------------------------------------
//   bool _isLoading = false;
//   String? _errorMessage;
//   File? _selectedImage;
//   String _location = '';

//   // Controllers
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController descController = TextEditingController();

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   File? get selectedImage => _selectedImage;
//   String get location => _location;

//   double? get latitude => null;

//   double? get longitude => null;

//   // ---------------------------------------------------------------------------
//   // ⚙️ العمليات (Actions)
//   // ---------------------------------------------------------------------------

//   /// 📸 اختيار صورة الهوية
//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _selectedImage = File(pickedFile.path);
//       notifyListeners();
//     }
//   }

//   /// 📍 تعيين الموقع المختار يدوياً
//   void setLocation(double lat, double lng, String address) {
//     _location = address;
//     // يمكنك هنا أيضاً تخزين الإحداثيات إذا كنت بحاجة لإرسالها للباك إند
//     // _latitude = lat;
//     // _longitude = lng;
//     notifyListeners();
//   }

//   /// 🚀 إرسال الطلب
//   Future<bool> submitRequest() async {
//     if (nameController.text.isEmpty ||
//         descController.text.isEmpty ||
//         _selectedImage == null ||
//         _location.isEmpty) {
//       _errorMessage = 'يرجى تعبئة جميع الحقول وإرفاق الصورة وتحديد الموقع';
//       notifyListeners();
//       return false;
//     }

//     _isLoading = true;
//     _errorMessage = null; // تصفير الخطأ السابق
//     notifyListeners();

//     try {
//       final request = ProviderRequestModel(
//         name: nameController.text,
//         requestContent: descController.text,
//         location: _location,
//         idCardImage: _selectedImage!,
//       );

//       await _repository.submitRequest(request);
//       return true; // نجاح
//     } catch (e) {
//       _errorMessage = 'حدث خطأ أثناء إرسال الطلب: $e';
//       return false; // فشل
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../models/provider_request_model.dart';
import '../repositories/be_provider_repository.dart';

/// 📂 اسم الملف: be_provider_view_model.dart
/// 📝 الوصف: ViewModel لإدارة منطق صفحة "كن مزود خدمة".
class BeProviderViewModel extends ChangeNotifier {
  final BeProviderRepository _repository;

  BeProviderViewModel(this._repository);

  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  String _location = '';
  
  // 🚀 أضفنا متغيرات الإحداثيات الحقيقية
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  String get location => _location;
  
  // 🚀 إرجاع القيم الحقيقية بدلاً من null
  double get latitude => _latitude;
  double get longitude => _longitude;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 📸 اختيار صورة الهوية
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  /// 📍 تعيين الموقع المختار والإحداثيات
  void setLocation(double lat, double lng, String address) {
    _location = address;
    _latitude = lat;     // ✅ تفعيل حفظ خط العرض
    _longitude = lng;    // ✅ تفعيل حفظ خط الطول
    notifyListeners();
  }

  /// 🚀 إرسال الطلب
  Future<bool> submitRequest(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (nameController.text.isEmpty ||
        descController.text.isEmpty ||
        _selectedImage == null ||
        _location.isEmpty) {
      _errorMessage = l10n.beProviderValidation;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null; // تصفير الخطأ السابق
    notifyListeners();

    try {
      final request = ProviderRequestModel(
        name: nameController.text,
        requestContent: descController.text,
        location: _location,
        latitude: _latitude,   // 🚀 إرسال خط العرض
        longitude: _longitude, // 🚀 إرسال خط الطول
        idCardImage: _selectedImage!,
      );

      await _repository.submitRequest(request);
      return true; // نجاح
    } catch (e) {
      _errorMessage = l10n.errorSendingRequest(e.toString());
      return false; // فشل
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}