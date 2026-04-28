import 'package:flutter/material.dart';
import '../Models/order_model.dart';
import '../Repository/orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _repository;

  OrdersViewModel(this._repository);

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderModel> _allOrders = [];
  List<OrderModel> get allOrders => _allOrders;

  /// 📊 عدد الطلبات الجديدة (Pending) لغرض العداد في القائمة الجانبية
  int get newOrdersCount => _allOrders.where((o) => o.status == 'pending').length;

  // 🚀 تعريف التبويبات (أضفنا المرفوض والملغي)
  final List<String> tabs = [
    'all',
    'new_order',
    'in_progress',
    'completed',
    'rejected_orders',
  ];

  // 🚀 دالة جلب الطلبات من المستودع
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await _repository.getOrders();
      // 🚀 فرز الطلبات: الأحدث دائماً في الأعلى (بناءً على تاريخ الإنشاء)
      fetchedOrders.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      _allOrders = fetchedOrders;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    if (_selectedTabIndex == 0) return _allOrders; // الكل

    if (_selectedTabIndex == 1) {
      // جديد (Pending)
      return _allOrders.where((o) => o.status == 'pending').toList();
    }

    if (_selectedTabIndex == 2) {
      // قيد التنفيذ
      return _allOrders
          .where(
            (o) =>
                o.status == 'accepted_initial' ||
                o.status == 'accepted_partial_paid' ||
                o.status == 'accepted_full_paid' ||
                o.status == 'in_progress',
          )
          .toList();
    }

    if (_selectedTabIndex == 3) {
      // مكتمل
      return _allOrders
          .where((o) => o.status == 'completed' || o.status == 'finished')
          .toList();
    }

    if (_selectedTabIndex == 4) {
      // مرفوض وملغي
      return _allOrders
          .where((o) => o.status == 'cancelled' || o.status == 'rejected')
          .toList();
    }

    return []; // Fallback
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // 🚀 تحديث بيانات طلب واحد لضمان دقة العرض في صفحة التفاصيل
  Future<void> refreshOrderDetail(String id) async {
    try {
      final updatedOrder = await _repository.getOrderDetail(id);
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _allOrders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
    }
  }

  // 🚀 تحديث حالة الطلب
  Future<bool> updateStatus(String id, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateOrderStatus(id, newStatus);
      await refreshOrderDetail(id); // تحديث بيانات هذا الطلب تحديداً
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 إضافة مبلغ مدفوع
  Future<bool> addPaidAmount(String id, double amount) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. إضافة المبلغ المدفوع
      await _repository.addPaidAmount(id, amount);

      // تم إزالة الترقية التلقائية للحالة بناءً على طلب المستخدم لأن الباك إند يقوم بذلك تلقائياً


      // 3. تحديث البيانات النهائية من السيرفر
      await refreshOrderDetail(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 إكمال الطلب وإضافة تقييم (عملية مركبة)
  Future<bool> completeOrderWithReview({
    required String id,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحديث الحالة إلى مكتمل
      await _repository.updateOrderStatus(id, 'completed');

      // 2. إرسال التقييم
      await _repository.submitReview(
        requestId: id,
        rating: rating,
        comment: comment,
      );

      // 3. تحديث البيانات النهائية
      await refreshOrderDetail(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 إرسال شكوى على الطلب
  Future<bool> submitComplaint({
    required String requestId,
    required String title,
    required String type,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitComplaint(
        requestId: requestId,
        title: title,
        type: type,
        content: content,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
