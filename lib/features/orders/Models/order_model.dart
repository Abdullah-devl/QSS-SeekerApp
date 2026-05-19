// مسار الملف: lib/features/orders/models/order_model.dart

import '../../profile/models/bank_model.dart';
import '../../../core/network/api_endpoints.dart';

enum OrderStatus { newOrder, inProgress, completed, cancelled }

class OrderSubService {
  final String name;
  final double price;
  final int quantity;

  OrderSubService({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  factory OrderSubService.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pivot = json['pivot'] != null 
        ? Map<String, dynamic>.from(json['pivot']) 
        : {};
    return OrderSubService(
      name: json['name'] ?? 'خدمة فرعية',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(pivot['quantity']?.toString() ?? '1') ?? 1,
    );
  }

  double get totalPrice => price * quantity;
}

class OrderBond {
  final String id;
  final String bondNumber;
  final String imagePath;
  final double amount; // 💰 مبلغ السند
  final String? status; // 📝 حالة السند
  final String? createdAt; // 📅 تاريخ الإنشاء
  final String? description; // 📝 وصف السند

  OrderBond({
    required this.id,
    required this.bondNumber,
    required this.imagePath,
    required this.amount,
    this.status,
    this.createdAt,
    this.description,
  });

  factory OrderBond.fromJson(Map<String, dynamic> json) {
    return OrderBond(
      id: json['id']?.toString() ?? '',
      bondNumber: json['bond_number']?.toString() ?? '---',
      imagePath: ApiEndpoints.getImageUrl(json['image_path']),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String? mainServiceImage; // 🖼️ صورة الخدمة الأساسية
  final double mainServicePrice; // 💰 سعر الخدمة الأساسية
  final String customerImage;
  final String customerPhone;
  final String providerName; // 👨‍🔧 اسم المزود
  final String providerImage; // 🖼️ صورة المزود
  final String providerPhone; // 📞 هاتف المزود
  final String providerEmail; // 📧 بريد المزود
  final bool isVerified;
  final double price;
  final double? oldPrice;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String timeAgo;
  final List<OrderSubService> subServices;
  final String status; // 📝 تم تغييره إلى String لدعم الحالات المحددة
  final String distance;
  final double paidAmount; // 💰 المبلغ المدفوع
  final double requiredPartialPercentage; // 📊 نسبة الدفع الجزئي
  final List<OrderBond> bonds; // 📂 السندات الخاصة بالطلب
  final List<BankModel> providerBanks; // 🏦 الحسابات البنكية للمزود
  final DateTime? createdAt; // 📅 تاريخ الإنشاء للفرز والدقة
  final bool providerFinished; // 👷 إشارة المزود بإنهاء العمل
  final Map<String, dynamic>? rawJson; // 🔍 الحزم الأصلية للتشخيص (Diagnostics)
  final int? providerId; // 👨‍🔧 معرف المزود

  OrderModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    this.mainServiceImage,
    this.mainServicePrice = 0.0,
    required this.customerImage,
    required this.customerPhone,
    this.providerName = 'مزود الخدمة',
    this.providerImage = '',
    this.providerPhone = '',
    this.providerEmail = '',
    this.isVerified = false,
    required this.price,
    this.oldPrice,
    required this.location,
    this.latitude,
    this.longitude,
    this.description,
    required this.timeAgo,
    required this.subServices,
    required this.status,
    this.distance = '---',
    this.paidAmount = 0.0,
    this.requiredPartialPercentage = 0.0,
    this.bonds = const [],
    this.providerBanks = const [],
    this.createdAt,
    this.providerFinished = false,
    this.rawJson,
    this.providerId,
  });

  // 🚀 حساب المبلغ المتبقي (محلياً)
  double get remainingAmount => price - paidAmount;

  // 🚀 دالة تحويل الـ JSON القادم من السيرفر إلى مودل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
   // جلب الحالة كما هي من الباك اند
    String currentStatus = (json['status'] ?? 'pending').toString().toLowerCase();

    // استخراج بيانات المستخدم (طالب الخدمة)
    final userData = json['user'] ?? json['seeker'] ?? json['customer'] ?? {};

    // 🚀 استخراج الخدمات من القائمة الموحدة 'services' (كما يظهر في اللوك)
    final List allServices = json['services'] ?? [];
    String mainServiceName = 'خدمة عامة';
    String? mainServiceImage;
    double mainServicePrice = 0.0;
    double partialPercentage = 0.0;
    List<OrderSubService> subServices = [];

    // 🕵️ أولاً: التحقق من وجود 'sub_services' في جذر الـ JSON بأي من المسميات المحتملة
    final List rootSubServices = json['sub_services'] ?? json['subServices'] ?? json['children'] ?? json['child_services'] ?? [];
    if (rootSubServices.isNotEmpty) {
      subServices = rootSubServices
          .map((e) => OrderSubService.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (allServices.isNotEmpty) {
      // البحث عن الخدمة الأساسية
      final mainServiceJson = allServices.firstWhere(
        (s) => s['type'] == 'main' || s['pivot']?['is_main'] == 1,
        orElse: () => allServices[0],
      );

      mainServiceName = mainServiceJson['name'] ?? 'خدمة عامة';
      mainServiceImage = mainServiceJson['image_path'];
      mainServicePrice = double.tryParse(mainServiceJson['price']?.toString() ?? '0') ?? 0.0;
      partialPercentage =
          double.tryParse(mainServiceJson['required_partial_percentage']?.toString() ?? '0') ?? 0.0;

      // إذا لم نجد خدمات فرعية في الجذر، نجمعها من allServices
      if (subServices.isEmpty) {
        subServices = allServices
            .where((s) => s['id'] != mainServiceJson['id'])
            .map((e) => OrderSubService.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else {
      // 🔄 Fallback للنظام القديم 'main_service' إذا لم تتوفر مصفوفة services
      final List mainServiceLegacy = json['main_service'] ?? json['mainService'] ?? [];
      if (mainServiceLegacy.isNotEmpty) {
        final first = mainServiceLegacy[0];
        mainServiceName = first['name'] ?? 'خدمة عامة';
        mainServiceImage = first['image_path'];
        mainServicePrice = double.tryParse(first['price']?.toString() ?? '0') ?? 0.0;
        partialPercentage =
            double.tryParse(first['required_partial_percentage']?.toString() ?? '0') ?? 0.0;

        // إذا لم نجد خدمات فرعية في الجذر، نجمعها من first['sub_services'] أو first['children']
        if (subServices.isEmpty) {
          final List rawSubs = first['sub_services'] ?? first['subServices'] ?? first['children'] ?? first['child_services'] ?? [];
          subServices = rawSubs.map((e) => OrderSubService.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }
    }

    // 🚀 استخراج بيانات المزود (إذا وجدت)
    Map<String, dynamic> providerData = json['provider'] ?? json['service_provider'] ?? {};

    // 🛡️ طبقة حماية إضافية ذكية: إذا لم نجدها في الجذر، نحاول استخراجها من الخدمات المتاحة
    if (providerData.isEmpty) {
      if (allServices.isNotEmpty) {
        final mainServiceJson = allServices.firstWhere(
          (s) => s['type'] == 'main' || s['pivot']?['is_main'] == 1,
          orElse: () => allServices[0],
        );
        if (mainServiceJson['provider'] != null) {
          providerData = Map<String, dynamic>.from(mainServiceJson['provider']);
        }
      } else {
        final List mainServiceLegacy = json['main_service'] ?? [];
        if (mainServiceLegacy.isNotEmpty) {
          final first = mainServiceLegacy[0];
          if (first['provider'] != null) {
            providerData = Map<String, dynamic>.from(first['provider']);
          }
        }
      }
    }

    // استخراج السندات
    final List rawBonds = json['bonds'] ?? json['receipts'] ?? [];
    List<OrderBond> bonds = rawBonds
        .map<OrderBond>((e) => OrderBond.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // استخراج الحسابات البنكية للمزود
    final List rawBanks = providerData['banks'] ?? providerData['bank_accounts'] ?? [];
    List<BankModel> providerBanks = rawBanks
        .map<BankModel>((e) => BankModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (providerBanks.isEmpty && providerData.isNotEmpty) {
      providerBanks = BankModel.getMockBanks();
    }

    // تنسيق الوقت
    String timeOnly = '';
    DateTime? fullCreatedAt;
    try {
      fullCreatedAt = DateTime.parse(json['created_at'].toString());
      final hour = fullCreatedAt.hour.toString().padLeft(2, '0');
      final minute = fullCreatedAt.minute.toString().padLeft(2, '0');
      timeOnly = '$hour:$minute';
    } catch (e) {
      timeOnly = (json['created_at_human'] ?? '').toString();
    }

    // استخراج معرف المزود
    int? providerId;
    if (json['provider_id'] != null) {
      providerId = int.tryParse(json['provider_id'].toString());
    } else if (providerData['id'] != null) {
      providerId = int.tryParse(providerData['id'].toString());
    } else if (providerData['user_id'] != null) {
      providerId = int.tryParse(providerData['user_id'].toString());
    } else if (allServices.isNotEmpty) {
      providerId = int.tryParse(allServices.first['provider_id']?.toString() ?? '');
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerName: userData['name'] ?? 'عميل',
      customerImage: ApiEndpoints.getImageUrl(userData['avatar'] ?? userData['image_path']),
      customerPhone: userData['phone'] ?? userData['mobile'] ?? '',
      providerName: providerData['name'] ?? 'مزود الخدمة',
      providerImage: ApiEndpoints.getImageUrl(providerData['avatar'] ?? providerData['image_path']),
      providerPhone: providerData['phone'] ?? providerData['mobile'] ?? '',
      providerEmail: providerData['email'] ?? '',
      serviceName: mainServiceName,
      mainServiceImage: ApiEndpoints.getImageUrl(mainServiceImage),
      mainServicePrice: mainServicePrice,
      price: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      oldPrice: json['old_price'] != null ? double.tryParse(json['old_price'].toString()) : null,
      location: json['address'] ?? json['location'] ?? 'الموقع غير محدد',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      description: json['message'] ?? json['notes'] ?? json['description'],
      timeAgo: timeOnly,
      subServices: subServices,
      status: currentStatus,
      isVerified: userData['is_verified'] == 1 || userData['is_verified'] == true,
      distance: (json['distance'] ?? '2.5').toString(),
      paidAmount:
          double.tryParse(json['money_paid']?.toString() ?? json['paid_amount']?.toString() ?? '0') ??
          0.0,
      requiredPartialPercentage: partialPercentage,
      bonds: bonds,
      providerBanks: providerBanks,
      createdAt: fullCreatedAt,
      providerFinished:
          (json['provider_finished'] == 1 ||
              json['provider_finished'] == true ||
              json['is_provider_finished'] == 1),
      rawJson: json,
      providerId: providerId,
    );
  }
}
