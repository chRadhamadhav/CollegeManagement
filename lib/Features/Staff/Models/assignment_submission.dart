class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final String? fileUrl;
  int? marksAwarded;
  String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    this.fileUrl,
    this.marksAwarded,
    this.feedback,
  });
}
