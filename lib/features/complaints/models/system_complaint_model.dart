class SystemComplaintModel {
  final int? id;
  final String title;
  final String type;
  final String content;
  final String appSource;
  final String status;
  final String? statusLabel;
  final DateTime? createdAt;

  SystemComplaintModel({
    this.id,
    required this.title,
    required this.type,
    required this.content,
    this.appSource = "seeker",
    this.status = "pending",
    this.statusLabel,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'content': content,
      'app_source': appSource,
    };
  }

  factory SystemComplaintModel.fromJson(Map<String, dynamic> json) {
    return SystemComplaintModel(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      appSource: json['app_source'] ?? 'seeker',
      status: json['status'] ?? 'pending',
      statusLabel: json['status_text'] ??
          json['status_label'] ??
          json['status_name'] ??
          json['status_ar'] ??
          json['status_en'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
