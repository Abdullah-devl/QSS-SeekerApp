// // import 'package:flutter/material.dart';
// // import '../services/service_model.dart';
// // // import '../repositories/order_repository.dart'; // للربط بالـ API لاحقاً

// // /// 📂 نموذج إضافات الخدمة (محاكاة للبيانات التي ستأتي من الـ API)
// // class ServiceAddon {
// //   final String name;
// //   final String unit;
// //   final double price;
// //   int quantity;

// //   ServiceAddon({required this.name, required this.unit, required this.price, this.quantity = 0});
// // }

// // /// 📂 اسم الملف: confirm_order_view_model.dart
// // class ConfirmOrderViewModel extends ChangeNotifier {
// //   final ServiceModel service;
// //   // final OrderRepository _repository; // للربط لاحقاً

// //   ConfirmOrderViewModel({required this.service}) {
// //     // محاكاة تحميل إضافات الخدمة بناءً على التصميم
// //     _addons = [
// //       ServiceAddon(name: 'غرف النوم', unit: 'غرفة', price: 50, quantity: 2),
// //       ServiceAddon(name: 'دورات المياه', unit: 'حمام', price: 30, quantity: 1),
// //       ServiceAddon(name: 'تنظيف المطبخ', unit: 'مطبخ', price: 80, quantity: 0),
// //       ServiceAddon(name: 'غرفة المعيشة', unit: 'غرفة', price: 60, quantity: 1),
// //     ];
// //   }

// //   // ---------------------------------------------------------------------------
// //   // 📊 المتغيرات (State)
// //   // ---------------------------------------------------------------------------
// //   bool _isLoading = false;
// //   String? _errorMessage;
// //   List<ServiceAddon> _addons = [];
// //   final TextEditingController notesController = TextEditingController();

// //   // Getters
// //   bool get isLoading => _isLoading;
// //   String? get errorMessage => _errorMessage;
// //   List<ServiceAddon> get addons => _addons;

// //   /// 🧮 حساب المجموع الفرعي (سعر الخدمة الأساسي + الإضافات)
// //   double get subTotal {
// //     double total = service.price; // السعر الأساسي للخدمة
// //     for (var addon in _addons) {
// //       total += (addon.price * addon.quantity);
// //     }
// //     return total;
// //   }

// //   /// 🧮 حساب الضريبة (15%)
// //   double get vatAmount => subTotal * 0.15;

// //   /// 🧮 حساب الإجمالي النهائي
// //   double get finalTotal => subTotal + vatAmount;

// //   // ---------------------------------------------------------------------------
// //   // ⚙️ العمليات (Actions)
// //   // ---------------------------------------------------------------------------

// //   void incrementAddon(int index) {
// //     _addons[index].quantity++;
// //     notifyListeners();
// //   }

// //   void decrementAddon(int index) {
// //     if (_addons[index].quantity > 0) {
// //       _addons[index].quantity--;
// //       notifyListeners();
// //     }
// //   }

// //   /// 🚀 إرسال الطلب النهائي للـ API
// //   Future<bool> confirmOrder() async {
// //     _isLoading = true;
// //     notifyListeners();

// //     try {
// //       // 💡 هنا يتم تجهيز البيانات وإرسالها للباك إند
// //       /*
// //       final orderData = {
// //         'service_id': service.id,
// //         'addons': _addons.where((a) => a.quantity > 0).toList(),
// //         'notes': notesController.text,
// //         'total_price': finalTotal,
// //       };
// //       await _repository.submitOrder(orderData);
// //       */

// //       await Future.delayed(const Duration(seconds: 2)); // محاكاة التحميل
// //       return true; // نجاح
// //     } catch (e) {
// //       _errorMessage = 'حدث خطأ أثناء تأكيد الطلب';
// //       return false;
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../services/service_model.dart';

// /// 📂 نموذج مساعد لإدارة حالة الكمية (Quantity) للخدمة الفرعية في واجهة المستخدم
// class SubServiceItem {
//   final int id;
//   final String title;
//   final double price;
//   int quantity;

//   SubServiceItem({
//     required this.id,
//     required this.title,
//     required this.price,
//     this.quantity = 0, // 🚀 تبدأ الكمية دائماً من صفر
//   });
// }

// /// 📂 اسم الملف: confirm_order_view_model.dart
// /// 📝 الوصف: المحاسب والعقل المدبر لشاشة تأكيد الطلب.
// class ConfirmOrderViewModel extends ChangeNotifier {
//   final ServiceModel mainService;

//   ConfirmOrderViewModel({required this.mainService, required ServiceModel service}) {
//     _initializeSubServices();
//   }

//   // ---------------------------------------------------------------------------
//   // 📊 المتغيرات (State)
//   // ---------------------------------------------------------------------------
//   bool _isLoading = false;
//   String? _errorMessage;
//   List<SubServiceItem> _subServices = [];
//   final TextEditingController notesController = TextEditingController();

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   List<SubServiceItem> get subServices => _subServices;

//   // ---------------------------------------------------------------------------
//   // ⚙️ العمليات (Actions)
//   // ---------------------------------------------------------------------------

//   /// 📥 استخراج الخدمات الفرعية الحقيقية من الخدمة الأساسية
//   void _initializeSubServices() {
//     // 🚀 السحر هنا: نقرأ قائمة الخدمات الفرعية المرفقة داخل الخدمة الأساسية مباشرة
//     // ونحولها إلى عناصر يمكن للمستخدم زيادة أو نقصان كميتها
//     _subServices = mainService.subServices.map((childService) {
//       return SubServiceItem(
//         id: childService.id,
//         title: childService.title,
//         price: childService.price,
//         quantity: 0, // الافتراضي صفر
//       );
//     }).toList();
//   }

//   /// 🧮 حساب المجموع الفرعي (الخدمة الأساسية + الخدمات الفرعية المضافة)
//   double get subTotal {
//     double total = mainService.price; // سعر الخدمة الأساسية
//     for (var sub in _subServices) {
//       total += (sub.price * sub.quantity); // إضافة سعر الخدمات الفرعية المحددة
//     }
//     return total;
//   }

//   /// 🧮 حساب الضريبة (15%)
//   double get vatAmount => subTotal * 0.15;

//   /// 🧮 حساب الإجمالي النهائي
//   double get finalTotal => subTotal + vatAmount;

//   get addons => null;

//   get service => null;

//   // ➕ زيادة كمية الخدمة الفرعية
//   void incrementSubService(int index) {
//     _subServices[index].quantity++;
//     notifyListeners(); // 🔄 تحديث الأسعار في الواجهة فوراً
//   }

//   // ➖ تقليل كمية الخدمة الفرعية
//   void decrementSubService(int index) {
//     if (_subServices[index].quantity > 0) {
//       _subServices[index].quantity--;
//       notifyListeners(); // 🔄 تحديث الأسعار في الواجهة فوراً
//     }
//   }

//   /// 🚀 إرسال الطلب للـ API
//   Future<bool> confirmOrder() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // 💡 هنا سيتم تجهيز البيانات الفعيلة وإرسالها للباك اند
//       // الخدمات الفرعية التي اختارها المستخدم فقط (كميتها أكبر من 0)
//       final selectedChildServices = _subServices.where((s) => s.quantity > 0).toList();

//       print('تم طلب الخدمة: ${mainService.title}');
//       print('عدد الخدمات الفرعية المختارة: ${selectedChildServices.length}');

//       // محاكاة التحميل والتواصل مع السيرفر
//       await Future.delayed(const Duration(seconds: 2));
//       return true;
//     } catch (e) {
//       _errorMessage = 'حدث خطأ أثناء التأكيد';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void decrementAddon(int index) {}
// }

import 'package:flutter/material.dart';
import '../services/models/service_model.dart';
import '../../profile/requests/repository/request_repository.dart';

/// 📂 نموذج مساعد لإدارة حالة الكمية (Quantity) للخدمة الفرعية في واجهة المستخدم
class SubServiceItem {
  final int id;
  final String title;
  final double price;
  int quantity;

  SubServiceItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 0, // 🚀 تبدأ الكمية دائماً من صفر
  });
}

/// 📂 اسم الملف: confirm_order_view_model.dart
/// 📝 الوصف: المحاسب والعقل المدبر لشاشة تأكيد الطلب وتخصيصه.
class ConfirmOrderViewModel extends ChangeNotifier {
  final ServiceModel mainService;
  final RequestRepository _repository;

  ConfirmOrderViewModel({
    required this.mainService,
    required RequestRepository repository,
  }) : _repository = repository {
    _initializeSubServices();
  }

  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;
  List<SubServiceItem> _subServices = [];
  final TextEditingController notesController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();

  // Location State
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SubServiceItem> get subServices => _subServices;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String? get selectedAddress => _selectedAddress;

  /// 📍 تحديث الموقع المختار من الخريطة
  void setLocation(double lat, double lng, String address) {
    _selectedLatitude = lat;
    _selectedLongitude = lng;
    _selectedAddress = address;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 📥 استخراج الخدمات الفرعية الحقيقية من الخدمة الأساسية
  void _initializeSubServices() {
    _subServices = mainService.subServices.map((childService) {
      return SubServiceItem(
        id: childService.id,
        title: childService.title,
        price: childService.price,
        quantity: 0,
      );
    }).toList();
  }

  /// 🧮 حساب المجموع الفرعي (الخدمة الأساسية + الخدمات الفرعية المضافة)
  double get subTotal {
    double total = mainService.price;
    for (var sub in _subServices) {
      total += (sub.price * sub.quantity);
    }
    return total;
  }

  /// 🧮 حساب الإجمالي النهائي
  double get finalTotal => subTotal;

  // ➕ زيادة كمية الخدمة الفرعية
  void incrementSubService(int index) {
    _subServices[index].quantity++;
    notifyListeners();
  }

  // ➖ تقليل كمية الخدمة الفرعية
  void decrementSubService(int index) {
    if (_subServices[index].quantity > 0) {
      _subServices[index].quantity--;
      notifyListeners();
    }
  }

  /// 🚀 إرسال الطلب للـ API
  Future<bool> confirmOrder() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🚀 تجهيز مصفوفة الخدمات الفرعية بالشكل المطلوب للباكيند
      final supServices = _subServices
          .where((s) => s.quantity > 0)
          .map((s) => {'id': s.id, 'quantity': s.quantity})
          .toList();

      // دمج بيانات المستخدم (الاسم والهاتف) مع الملاحظات في حقل الرسالة
      final combinedMessage = '''
الاسم: ${userNameController.text}
الهاتف: ${userPhoneController.text}
ملاحظات: ${notesController.text}
''';

      final success = await _repository.createServiceRequest(
        serviceId: mainService.id,
        message: combinedMessage,
        supServices: supServices,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    userNameController.dispose();
    userPhoneController.dispose();
    super.dispose();
  }
}
