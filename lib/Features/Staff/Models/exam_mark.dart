class ExamMark {
  final String id;
  final String examId;
  final String studentId;
  final double marksObtained;
  final bool isAbsent;

  ExamMark({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.marksObtained,
    required this.isAbsent,
  });

  factory ExamMark.fromJson(Map<String, dynamic> json) {
    return ExamMark(
      id: json['id'] ?? '',
      examId: json['exam_id'] ?? '',
      studentId: json['student_id'] ?? '',
      marksObtained: (json['marks_obtained'] as num?)?.toDouble() ?? 0.0,
      isAbsent: json['is_absent'] ?? false,
    );
  }
}
