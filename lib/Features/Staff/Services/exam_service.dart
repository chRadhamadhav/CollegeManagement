import 'package:vidhya_sethu/Features/Staff/Models/exam.dart';
import 'package:vidhya_sethu/Features/Staff/Models/exam_mark.dart';
import 'package:vidhya_sethu/Features/Staff/Models/student.dart';
import 'package:vidhya_sethu/Features/Staff/Models/subject.dart';
import 'package:vidhya_sethu/core/api/api_client.dart';
import 'package:vidhya_sethu/core/logger/app_logger.dart';

class ExamService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Exam>> getExams() async {
    try {
      final response = await _apiClient.dio.get('staff/exams/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => Exam.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error fetching exams', e);
      return [];
    }
  }

  Future<bool> addExam({
    required String name,
    required String subjectId,
    required String departmentId,
    required DateTime examDate,
    required double maxMarks,
    required double passingMarks,
    String examTime = '10:00 AM - 01:00 PM',
    String location = 'TBA',
  }) async {
    try {
      AppLogger.info('Adding exam: $name for subject: $subjectId');
      final response = await _apiClient.dio.post(
        'staff/exams/',
        data: {
          'name': name,
          'subject_id': subjectId,
          'department_id': departmentId,
          'exam_date': examDate.toIso8601String().split('T')[0],
          'exam_time': examTime,
          'location': location,
          'max_marks': maxMarks,
          'passing_marks': passingMarks,
        },
      );
      AppLogger.info('addExam response: ${response.statusCode}');
      return response.statusCode == 201;
    } catch (e) {
      AppLogger.error('Error adding exam', e);
      return false;
    }
  }

  Future<bool> deleteExam(String examId) async {
    try {
      final response = await _apiClient.dio.delete('staff/exams/$examId/');
      return response.statusCode == 204;
    } catch (e) {
      AppLogger.error('Error deleting exam: $examId', e);
      return false;
    }
  }

  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _apiClient.dio.get('staff/subjects/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => Subject.fromJson(e)).toList();
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
        final List<dynamic> data = response.data;
        return data.map((e) {
          // Flatten user object to match existing Student model
          final user = e['user'] ?? {};
          return Student(
            id: e['id'] ?? '',
            studentId: e['roll_number'] ?? '',
            course: e['course'] ?? '',
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

  Future<List<ExamMark>> getMarks(String examId) async {
    try {
      final response = await _apiClient.dio.get('staff/exams/$examId/marks/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => ExamMark.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error fetching marks for exam: $examId', e);
      return [];
    }
  }

  Future<bool> saveMarksBulk(String examId, List<ExamMark> marks) async {
    try {
      final response = await _apiClient.dio.post(
        'staff/exams/$examId/marks/',
        data: {
          'exam_id': examId,
          'marks': marks
              .map(
                (m) => {
                  'student_id': m.studentId,
                  'marks_obtained': m.marksObtained,
                  'is_absent': m.isAbsent,
                },
              )
              .toList(),
        },
      );
      return response.statusCode == 204;
    } catch (e) {
      AppLogger.error('Error saving bulk marks for exam: $examId', e);
      return false;
    }
  }
}
