import '../../../core/api/api_client.dart';
import '../../../core/logger/app_logger.dart';
import 'package:dio/dio.dart';

class HODService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('hod/dashboard/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching HOD dashboard', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching HOD dashboard', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getFaculty() async {
    try {
      final response = await _apiClient.dio.get('hod/faculty/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching faculty', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching HOD faculty', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getExams() async {
    try {
      final response = await _apiClient.dio.get('hod/exams/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching exams', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching HOD exams', e);
      return null;
    }
  }

  Future<bool> assignInvigilator(String examId, String staffId) async {
    try {
      final response = await _apiClient.dio.patch(
        'hod/exams/$examId/assign/',
        data: {'staff_id': staffId},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error('Dio error assigning invigilator', e);
      return false;
    } catch (e) {
      AppLogger.error('Error assigning invigilator', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getSubjects() async {
    try {
      final response = await _apiClient.dio.get('hod/subjects/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching subjects', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching subjects', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStudents() async {
    try {
      final response = await _apiClient.dio.get('hod/students/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching students', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching students', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getTimetable({String? day}) async {
    try {
      final response = await _apiClient.dio.get(
        'hod/timetable/',
        queryParameters: day != null ? {'day_of_week': day} : null,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching timetable', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching timetable', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> createExam(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('hod/exams/', data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error creating exam', e);
      return null;
    } catch (e) {
      AppLogger.error('Error creating exam', e);
      return null;
    }
  }

  Future<bool> postExamResults(
    String examId,
    List<Map<String, dynamic>> marks,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        'hod/exams/$examId/results/',
        data: {'exam_id': examId, 'marks': marks},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      AppLogger.error('Dio error posting results', e);
      return false;
    } catch (e) {
      AppLogger.error('Error posting results', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getExamMarks(String examId) async {
    try {
      final response = await _apiClient.dio.get('hod/exams/$examId/marks/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching exam marks', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching exam marks', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAnnouncements() async {
    try {
      final response = await _apiClient.dio.get('hod/announcements/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching announcements', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching HOD announcements', e);
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
        'hod/announcements/',
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
      AppLogger.error('Dio error creating announcement', e);
      return null;
    } catch (e) {
      AppLogger.error('Error creating announcement', e);
      return null;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      final response = await _apiClient.dio.delete('hod/announcements/$id/');
      return response.statusCode == 204;
    } on DioException catch (e) {
      AppLogger.error('Dio error deleting announcement', e);
      return false;
    } catch (e) {
      AppLogger.error('Error deleting announcement', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getFacultyDuty() async {
    try {
      final response = await _apiClient.dio.get('hod/faculty/duty/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching faculty duty', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching faculty duty', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getHODProfile() async {
    try {
      final response = await _apiClient.dio.get('hod/profile/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching HOD profile', e);
      return null;
    } catch (e) {
      AppLogger.error('Error fetching HOD profile', e);
      return null;
    }
  }
}
