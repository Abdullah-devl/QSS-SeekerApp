/// 📂 اسم الملف: service_schedule_model.dart
/// 📝 الوصف: نموذج بيانات جدول المواعيد للخدمة.

class ServiceScheduleModel {
  final int id;
  final String day; // اليوم (مثلاً: Sunday, Monday...)
  final String fromTime; // وقت البدء (مثلاً: 08:00)
  final String toTime; // وقت الانتهاء (مثلاً: 16:00)
  final bool isActive; // هل هذا اليوم متاح أم مغلق
  final String? label; // اسم الفترة (مثلاً: الفترة الصباحية، الفترة المسائية)

  ServiceScheduleModel({
    required this.id,
    required this.day,
    required this.fromTime,
    required this.toTime,
    this.isActive = true,
    this.label,
  });

  factory ServiceScheduleModel.fromJson(Map<String, dynamic> json) {
    return ServiceScheduleModel(
      id: json['id'] ?? 0,
      day: json['day'] ?? json['day_name'] ?? '',
      fromTime: json['from'] ?? json['start_time'] ?? '00:00',
      toTime: json['to'] ?? json['end_time'] ?? '00:00',
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
      label: json['label']?.toString(),
    );
  }

  static List<ServiceScheduleModel> getMockSchedules() {
    return [
      ServiceScheduleModel(
        id: 1,
        day: 'الأحد',
        fromTime: '08:00 ص',
        toTime: '10:00 م',
      ),
      ServiceScheduleModel(
        id: 2,
        day: 'الإثنين',
        fromTime: '08:00 ص',
        toTime: '10:00 م',
      ),
      ServiceScheduleModel(
        id: 3,
        day: 'الثلاثاء',
        fromTime: '08:00 ص',
        toTime: '10:00 م',
      ),
      ServiceScheduleModel(
        id: 4,
        day: 'الأربعاء',
        fromTime: '08:00 ص',
        toTime: '10:00 م',
      ),
      ServiceScheduleModel(
        id: 5,
        day: 'الخميس',
        fromTime: '08:00 ص',
        toTime: '10:00 م',
      ),
      ServiceScheduleModel(
        id: 6,
        day: 'الجمعة',
        fromTime: '02:00 م',
        toTime: '11:00 م',
        isActive: false,
      ),
      ServiceScheduleModel(
        id: 7,
        day: 'السبت',
        fromTime: '02:00 م',
        toTime: '11:00 م',
      ),
    ];
  }
}
