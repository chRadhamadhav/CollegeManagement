import 'package:dio/dio.dart';
import 'package:college_management/Features/Staff/Models/assignment.dart';
import 'package:college_management/Features/Staff/Models/assignment_submission.dart';
import '../../../core/api/api_client.dart';

class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  final Dio _dio = ApiClient().dio;

  factory AssignmentService() => _instance;
  AssignmentService._internal();

  /// Get assignments for a specific course (Student View) or all if staff
  /// Endpoint: GET /api/v1/student/assignments or /api/v1/staff/assignments
  Future<List<Assignment>> fetchAssignments({bool isStaff = false}) async {
    try {
      final endpoint = isStaff ? '/staff/assignments' : '/student/assignments';
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (e) => Assignment(
                id: e['id'],
                title: e['title'],
                description: e['description'] ?? '',
                dueDate: DateTime.parse(e['due_date']),
                course: e['course'],
                createdAt: DateTime.parse(e['created_at']),
              ),
            )
            .toList();
      }
    } catch (e) {
      // Return empty list on failure for now
    }
    return [];
  }

  /// Create a new assignment (Staff View)
  /// Endpoint: POST /api/v1/staff/assignments
  Future<bool> createAssignment(Assignment assignment) async {
    try {
      final response = await _dio.post(
        '/staff/assignments',
        data: {
          'title': assignment.title,
          'description': assignment.description,
          'due_date': assignment.dueDate.toIso8601String(),
          'course': assignment.course,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Delete an assignment (Staff View)
  /// Endpoint: DELETE /api/v1/staff/assignments/{assignmentId}
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      final response = await _dio.delete('/staff/assignments/$assignmentId');
      return response.statusCode == 200;
    } catch (e) {
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
        '/staff/assignments/$assignmentId/submissions',
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
      //
    }
    return [];
  }

  /// Add a mock submission (Student View)
  /// Endpoint: POST /api/v1/student/assignments/{assignmentId}/submit
  Future<bool> submitAssignment(String assignmentId, String filePath) async {
    try {
      // In a real scenario, this would involve sending form-data with the file.
      // For this migration, assuming basic POST due to file complexity handling missing at backend right now.
      final response = await _dio.post(
        '/student/assignments/$assignmentId/submit',
        data: {
          'file_path': filePath, // Simulation
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
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
      final response = await _dio.post(
        '/staff/assignments/submissions/$submissionId/grade',
        data: {'marks': marks, 'feedback': feedback},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
