import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/logger/app_logger.dart';

/// Service for all student-related API calls.
///
/// Each method maps 1-to-1 with a backend endpoint scoped to the
/// authenticated student. Business logic lives in the backend; this
/// service is presentation-only.
class StudentService {
  static final StudentService _instance = StudentService._internal();
  final Dio _dio = ApiClient().dio;

  factory StudentService() {
    return _instance;
  }

  StudentService._internal();

  /// Fetches the profile details of the currently logged-in student.
  Future<Map<String, dynamic>?> getStudentProfile() async {
    try {
      final response = await _dio.get('student/profile/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('getStudentProfile ERROR', e);
      // Return null on failure — callers show an error/retry UI
    }
    return null;
  }

  /// Fetches the dashboard statistics of the currently logged-in student.
  Future<Map<String, dynamic>?> getStudentDashboard() async {
    try {
      final response = await _dio.get('student/dashboard/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('getStudentDashboard ERROR', e);
    }
    return null;
  }

  /// Fetches the timetable for the student's department.
  ///
  /// Returns a list of timetable slots, each including [subject_name],
  /// [day_of_week], [start_time], [end_time], and [room].
  Future<List<Map<String, dynamic>>> fetchTimetable() async {
    try {
      final response = await _dio.get('student/timetable/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchTimetable ERROR', e);
    }
    return [];
  }

  /// Fetches all exam marks for the authenticated student.
  Future<List<Map<String, dynamic>>> fetchResults() async {
    try {
      final response = await _dio.get('student/results/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchResults ERROR', e);
    }
    return [];
  }

  /// Fetches the attendance summary for the authenticated student.
  Future<List<Map<String, dynamic>>> fetchAttendance() async {
    try {
      final response = await _dio.get('student/attendance/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchAttendance ERROR', e);
    }
    return [];
  }

  /// Fetches all study materials for subjects in the student's department.
  ///
  /// The backend returns a flat list of materials.
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    try {
      final response = await _dio.get('student/materials/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchMaterials ERROR', e);
    }
    return [];
  }

  /// Submits an assignment via file upload.
  Future<bool> submitAssignment({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post(
        'student/assignments/$assignmentId/submit',
        data: formData,
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      AppLogger.error('submitAssignment ERROR', e);
      return false;
    }
  }

  /// Fetches all assignments relevant to the student's course.
  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    try {
      final response = await _dio.get('student/assignments/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchAssignments ERROR', e);
    }
    return [];
  }

  /// Fetches upcoming exams for the student's department, enriched with subject name.
  Future<List<Map<String, dynamic>>> fetchUpcomingExams() async {
    try {
      final response = await _dio.get('student/exams/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchUpcomingExams ERROR', e);
    }
    return [];
  }

  /// Fetches upcoming calendar events for the student
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final response = await _dio.get('student/events/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      AppLogger.error('fetchEvents ERROR', e);
    }
    return [];
  }
}
