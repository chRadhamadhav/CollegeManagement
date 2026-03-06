import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class TimetableService {
  static final TimetableService _instance = TimetableService._internal();
  final Dio _dio = ApiClient().dio;

  factory TimetableService() => _instance;
  TimetableService._internal();

  // Fetch timetable slots from the backend structure
  // The backend endpoint is: GET /api/v1/student/timetable
  // Returns: {"slots": [{"id": ..., "day_of_week": ..., "start_time": ..., "end_time": ..., "subject_name": ..., "room": ...}]}
  Future<List<Map<String, dynamic>>> fetchTimetable() async {
    try {
      final response = await _dio.get('/student/timetable');
      if (response.statusCode == 200) {
        final List<dynamic> slots = response.data['slots'];
        return slots.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      // Return empty list on failure for now
    }
    return [];
  }

  // Maintaining the mock signature for now as it seems to be used elsewhere (like fetching courses)
  Future<List<String>> fetchCourses() async {
    // We leave this mock here to prevent breaking screens that just need a dropdown,
    // but ideally this should be moved to a CourseService
    return [
      'BCA',
      'BSc Mathematics',
      'BSc Physics',
      'BSc Computer Science',
      'BSc Electronics',
      'BSc Information Technology',
      'BSc Statistics',
    ];
  }
}
