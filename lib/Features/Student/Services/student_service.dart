import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

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
      final response = await _dio.get('/student/profile');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('getStudentProfile ERROR: $e');
      // Return null on failure — callers show an error/retry UI
    }
    return null;
  }

  /// Fetches the dashboard statistics of the currently logged-in student.
  Future<Map<String, dynamic>?> getStudentDashboard() async {
    try {
      final response = await _dio.get('/student/dashboard');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // Return null on failure
    }
    return null;
  }

  /// Fetches the timetable for the student's department.
  ///
  /// Returns a list of timetable slots, each including [subject_name],
  /// [day_of_week], [start_time], [end_time], and [room].
  Future<List<Map<String, dynamic>>> fetchTimetable() async {
    try {
      final response = await _dio.get('/student/timetable');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  /// Fetches all exam marks for the authenticated student.
  Future<List<Map<String, dynamic>>> fetchResults() async {
    try {
      final response = await _dio.get('/student/results');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  /// Fetches all study materials for subjects in the student's department.
  ///
  /// Each item includes [title], [file_url], [category], [subject_name],
  /// [subject_code], and [created_at].
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    try {
      final response = await _dio.get('/student/materials');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  /// Fetches all assignments relevant to the student's course.
  ///
  /// The backend already filters by the student's course. Each item includes
  /// a [submissions] list that the UI uses to determine pending vs submitted.
  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    try {
      final response = await _dio.get('/student/assignments');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  /// Fetches upcoming exams for the student's department, enriched with subject name.
  Future<List<Map<String, dynamic>>> fetchUpcomingExams() async {
    try {
      final response = await _dio.get('/student/exams');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  /// Fetches upcoming calendar events for the student
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final response = await _dio.get('/student/events');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }
}
