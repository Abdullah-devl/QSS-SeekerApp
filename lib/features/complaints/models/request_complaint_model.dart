class RequestComplaintModel {
  final int id;
  final String content;
  final String status;
  final String? statusLabel;
  final String createdAt;
  final int? orderId;
  final String? orderType;

  RequestComplaintModel({
    required this.id,
    required this.content,
    required this.status,
    this.statusLabel,
    required this.createdAt,
    this.orderId,
    this.orderType,
  });

  factory RequestComplaintModel.fromJson(Map<String, dynamic> json) {
    return RequestComplaintModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      status: json['status'] ?? 'pending',
      statusLabel: json['status_text'] ??
          json['status_label'] ??
          json['status_name'] ??
          json['status_ar'] ??
          json['status_en'],
      createdAt: json['created_at'] ?? '',
      orderId: json['request_id'] ?? json['order_id'],
      orderType: json['type'] ?? '',
    );
  }
}
