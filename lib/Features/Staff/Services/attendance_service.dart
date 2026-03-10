import '../../../core/api/api_client.dart';
import '../Models/student.dart';
import '../Models/subject.dart';
import '../../../core/logger/app_logger.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _apiClient.dio.get('staff/subjects/');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Subject.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error fetching subjects', e);
      return [];
    }
  }

  Future<List<Student>> getStudents(String subjectId) async {
    try {
      final response = await _apiClient.dio.get(
        'staff/subjects/$subjectId/students/',
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((json) {
          final user = json['user'] ?? {};
          return Student(
            id: json['id'] ?? '',
            studentId: json['roll_number'] ?? '',
            course: json['course'] ?? '',
            name: user['full_name'] ?? 'Unknown',
            imageUrl: user['avatar_url'] ?? '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error fetching students for subject: $subjectId', e);
      return [];
    }
  }

  Future<bool> submitAttendance({
    required String subjectId,
    required DateTime date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      final payload = {
        'subject_id': subjectId,
        'date': date.toIso8601String().split('T')[0],
        'records': records,
      };

      final response = await _apiClient.dio.post(
        'staff/attendance/',
        data: payload,
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error submitting attendance', e);
      return false;
    }
  }
}
