import 'package:dio/dio.dart';
import 'package:vidhya_sethu/Features/Staff/Models/assignment.dart';
import 'package:vidhya_sethu/Features/Staff/Models/assignment_submission.dart';
import '../../../core/api/api_client.dart';
import '../../../core/logger/app_logger.dart';

class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  final Dio _dio = ApiClient().dio;

  factory AssignmentService() => _instance;
  AssignmentService._internal();

  /// Get assignments for a specific course (Student View) or all if staff
  /// Endpoint: GET /api/v1/student/assignments or /api/v1/staff/assignments
  Future<List<Assignment>> fetchAssignments({bool isStaff = false}) async {
    try {
      final endpoint = isStaff ? 'staff/assignments/' : 'student/assignments/';
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) {
          // Backend might send 'target_course' as 'course' or 'target_course'
          // UI expects 'course'
          final courseName = e['target_course'] ?? e['course'] ?? '';

          // Description might be null in top-level but present in topics[0]
          String description = e['description'] ?? '';
          if (description.isEmpty &&
              e['topics'] != null &&
              (e['topics'] as List).isNotEmpty) {
            description = e['topics'][0]['description'] ?? '';
          }

          return Assignment(
            id: e['id'],
            title: e['title'],
            description: description,
            dueDate: DateTime.parse(e['due_date']),
            course: courseName,
            subjectId: e['subject_id'] ?? '',
            maxMarks: e['max_marks'] ?? 100,
            createdAt: DateTime.parse(
              e['created_at'] ?? DateTime.now().toIso8601String(),
            ),
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.error('fetchAssignments ERROR', e);
    }
    return [];
  }

  /// Create a new assignment (Staff View)
  /// Endpoint: POST /api/v1/staff/assignments
  Future<bool> createAssignment(Assignment assignment) async {
    try {
      final response = await _dio.post(
        'staff/assignments/',
        data: {
          'title': assignment.title,
          'subject_id': assignment.subjectId,
          'target_course': assignment.course,
          'due_date': assignment.dueDate.toIso8601String(),
          'max_marks': assignment.maxMarks,
          'topics': [
            {'title': 'General', 'description': assignment.description},
          ],
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      AppLogger.error('createAssignment ERROR', e);
      return false;
    }
  }

  /// Delete an assignment (Staff View)
  /// Endpoint: DELETE /api/v1/staff/assignments/{assignmentId}
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      final response = await _dio.delete('staff/assignments/$assignmentId/');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('deleteAssignment ERROR for ID: $assignmentId', e);
      return false;
    }
  }

  /// Get all submissions for a specific assignment (Staff View)
  /// Endpoint: GET /api/v1/staff/assignments/{assignmentId}/submissions
  Future<List<AssignmentSubmission>> getSubmissionsForAssignment(
    String assignmentId,
  ) async {
    try {
      final response = await _dio.get(
        'staff/assignments/$assignmentId/submissions/',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (e) => AssignmentSubmission(
                id: e['id'],
                assignmentId: e['assignment_id'],
                studentId: e['student_id'] ?? 'Unknown',
                studentName: e['student_name'] ?? 'Unknown',
                submittedAt: DateTime.parse(e['submitted_at']),
                fileUrl: e['file_url'] ?? '',
                marksAwarded: e['marks_awarded'],
                feedback: e['feedback'],
              ),
            )
            .toList();
      }
    } catch (e) {
      AppLogger.error(
        'getSubmissionsForAssignment ERROR for ID: $assignmentId',
        e,
      );
    }
    return [];
  }

  /// Add a mock submission (Student View)
  /// Endpoint: POST /api/v1/student/assignments/{assignmentId}/submit
  Future<bool> submitAssignment(String assignmentId, String filePath) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );
      final formData = FormData.fromMap({'file': file});

      final response = await _dio.post(
        'student/assignments/$assignmentId/submit',
        data: formData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      AppLogger.error('submitAssignment ERROR for ID: $assignmentId', e);
      return false;
    }
  }

  /// Grade a submission (Staff View)
  /// Endpoint: POST /api/v1/staff/assignments/submissions/{submissionId}/grade
  Future<bool> gradeSubmission(
    String submissionId,
    int marks,
    String feedback,
  ) async {
    try {
      final response = await _dio.put(
        'staff/submissions/$submissionId/grade/',
        data: {'marks': marks, 'feedback': feedback},
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('gradeSubmission ERROR for ID: $submissionId', e);
      return false;
    }
  }
}
