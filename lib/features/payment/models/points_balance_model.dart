/// 📂 اسم الملف: points_balance_model.dart
/// 📝 الوصف: نموذج بيانات رصيد النقاط (المكافآت والأرباح).

class PointsBalanceModel {
  final double bonusPoints; // رصيد نقاط المكافأة (Wallet)
  final double paidPoints; // رصيد الأرباح القابلة للسحب (Earnings)

  PointsBalanceModel({required this.bonusPoints, required this.paidPoints});

  /// 🏭 مصنع لإنشاء الكائن من JSON
  factory PointsBalanceModel.fromJson(Map<String, dynamic> json) {
    return PointsBalanceModel(
      bonusPoints:
          double.tryParse(json['bonus_points']?.toString() ?? '0') ?? 0.0,
      paidPoints:
          double.tryParse(json['paid_points']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// 🛠️ كائن افتراضي للقيم الصفرية
  factory PointsBalanceModel.empty() {
    return PointsBalanceModel(bonusPoints: 0.0, paidPoints: 0.0);
  }
}
