import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import 'package:seeker/core/errors/api_error_handler.dart';
import '../models/complaint_model.dart';

import '../models/system_complaint_model.dart';
import '../models/request_complaint_model.dart';

class ComplaintsRepository {
  final ApiService _apiService;

  ComplaintsRepository(this._apiService);

  Future<List<RequestComplaintModel>> getRequestComplaints({
    String? status,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.requestComplaints,
        queryParameters: status != null ? {'status': status} : null,
      );
      ApiErrorHandler.handleResponse(response);

      // 🧩 دعم هيكل الاستجابة المتنوع من الباك إند
      final List data =
          response.data['RequestComplaints']?['data'] ??
          response.data['data'] ??
          [];
      return data.map((e) => RequestComplaintModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> submitOrderComplaint(ComplaintModel complaint) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.requestComplaints,
        data: complaint.toJson(),
      );

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<SystemComplaintModel>> getSystemComplaints({
    String? status,
    String appSource = "seeker",
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.systemComplaints,
        queryParameters: {
          'app_source': appSource,
          if (status != null) 'status': status,
        },
      );
      ApiErrorHandler.handleResponse(response);

      final List data =
          response.data['SystemComplaints']?['data'] ??
          response.data['data'] ??
          [];
      return data.map((e) => SystemComplaintModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> submitSystemComplaint(SystemComplaintModel complaint) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.systemComplaints,
        data: complaint.toJson(),
      );

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
