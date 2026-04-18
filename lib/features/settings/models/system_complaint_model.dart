import 'package:intl/intl.dart';

class SystemComplaintModel {
  final int id;
  final String title;
  final String type;
  final String content;
  final String status;
  final String appSource;
  final DateTime createdAt;

  SystemComplaintModel({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    required this.status,
    required this.appSource,
    required this.createdAt,
  });

  factory SystemComplaintModel.fromJson(Map<String, dynamic> json) {
    return SystemComplaintModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'pending',
      appSource: json['app_source'] ?? 'seeker',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  String get formattedDate => DateFormat('yyyy/MM/dd HH:mm').format(createdAt);

  String get statusText {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'in_progress': return 'جاري العمل';
      case 'resolved': return 'تم الحل';
      case 'closed': return 'مغلق';
      case 'rejected': return 'مرفوض';
      default: return status;
    }
  }
}
