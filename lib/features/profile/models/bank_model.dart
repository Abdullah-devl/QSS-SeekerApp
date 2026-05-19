import 'dart:developer' as developer;

/// 📂 اسم الملف: bank_model.dart
/// 📝 الوصف: نموذج بيانات الحسابات البنكية للمزود.
/// جزء من بيانات الملف الشخصي.
class BankModel {
  final int id;
  final String bankName; // اسم البنك (مثلاً: مصرف الراجحي)
  final String accountName; // اسم صاحب الحساب
  final String iban; // رقم الآيبان

  BankModel({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.iban,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    // 🔍 معالجة الـ pivot والبحث عن رقم الحساب بصرامة
    final dynamic pivot = json['pivot'];
    Map<String, dynamic>? pivotMap;
    if (pivot != null && pivot is Map) {
      pivotMap = Map<String, dynamic>.from(pivot);
    }

    final String accountNo =
        (pivotMap?['bank_account'] ??
                json['bank_account'] ??
                pivotMap?['iban'] ??
                json['iban'] ??
                '')
            .toString()
            .trim();

    developer.log(
      '🔍 [BankModel.fromJson] Parsing Bank: ${json['bank_name'] ?? json['name']}. Found Account: $accountNo (from pivot: ${pivotMap != null})',
      name: 'BankModel',
    );

    return BankModel(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? json['name'] ?? 'بنك غير معروف',
      accountName:
          json['account_name'] ??
          json['user_name'] ??
          pivotMap?['account_name'] ??
          '',
      iban: accountNo.isEmpty ? 'رقم الحساب غير متوفر' : accountNo,
    );
  }

  static List<BankModel> getMockBanks() {
    return [
      BankModel(
        id: 1,
        bankName: 'مصرف الراجحي',
        accountName: 'المزود المتميز',
        iban: 'SA45 8000 0000 6080 1020 3040',
      ),
      BankModel(
        id: 2,
        bankName: 'البنك الأهلي SNB',
        accountName: 'المزود المتميز',
        iban: 'SA20 1000 0000 4455 6677 8899',
      ),
    ];
  }
}
