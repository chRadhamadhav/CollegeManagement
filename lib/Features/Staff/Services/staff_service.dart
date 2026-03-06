import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class StaffService {
  static final StaffService _instance = StaffService._internal();
  final Dio _dio = ApiClient().dio;

  factory StaffService() {
    return _instance;
  }

  StaffService._internal();

  /// Fetches the profile details of the currently logged-in staff member.
  Future<Map<String, dynamic>?> getStaffProfile() async {
    try {
      final response = await _dio.get('/staff/profile');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('getStaffProfile ERROR: $e');
      // Return null on failure
    }
    return null;
  }

  /// Fetches the dashboard statistics of the currently logged-in staff member.
  Future<Map<String, dynamic>?> getStaffDashboard() async {
    try {
      final response = await _dio.get('/staff/dashboard');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // Return null on failure
    }
    return null;
  }
}
