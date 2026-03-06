import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class HODService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/hod/dashboard');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching HOD dashboard: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching HOD dashboard: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getFaculty() async {
    try {
      final response = await _apiClient.dio.get('/hod/faculty');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching faculty: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching HOD faculty: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getExams() async {
    try {
      final response = await _apiClient.dio.get('/hod/exams');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching exams: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching HOD exams: $e');
      return null;
    }
  }

  Future<bool> assignInvigilator(String examId, String staffId) async {
    try {
      final response = await _apiClient.dio.patch(
        '/hod/exams/$examId/assign',
        data: {'staff_id': staffId},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      log('Dio error assigning invigilator: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      log('Error assigning invigilator: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getAnnouncements() async {
    try {
      final response = await _apiClient.dio.get('/hod/announcements');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching announcements: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching HOD announcements: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createAnnouncement(
    String title,
    String body,
    String targetRole,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/hod/announcements',
        data: {
          'title': title,
          'body': body,
          'target_role': targetRole.toLowerCase(),
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      log('Dio error creating announcement: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error creating announcement: $e');
      return null;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      final response = await _apiClient.dio.delete('/hod/announcements/$id');
      return response.statusCode == 204;
    } on DioException catch (e) {
      log('Dio error deleting announcement: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      log('Error deleting announcement: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getFacultyDuty() async {
    try {
      final response = await _apiClient.dio.get('/hod/faculty/duty');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching faculty duty: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching faculty duty: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getHODProfile() async {
    try {
      final response = await _apiClient.dio.get('/hod/profile');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      log('Dio error fetching HOD profile: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Error fetching HOD profile: $e');
      return null;
    }
  }
}
