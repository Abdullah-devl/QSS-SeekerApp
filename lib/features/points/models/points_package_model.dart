// مسار الملف: lib/features/points/models/points_package_model.dart

class PointsPackageModel {
  final int id;
  final String name;
  final double price;
  final int points;
  final int bonusPoints;
  final String? description;

  PointsPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.points,
    this.bonusPoints = 0,
    this.description,
  });

  factory PointsPackageModel.fromJson(Map<String, dynamic> json) {
    return PointsPackageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      points: json['points'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
      description: json['description'],
    );
  }

  int get totalPoints => points + bonusPoints;
}
