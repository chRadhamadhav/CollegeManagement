class Exam {
  final String id;
  final String name;
  final String subjectId;
  final String departmentId;
  final DateTime examDate;
  final double maxMarks;
  final double passingMarks;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.departmentId,
    required this.examDate,
    required this.maxMarks,
    required this.passingMarks,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subjectId: json['subject_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      examDate: json['exam_date'] != null
          ? DateTime.parse(json['exam_date'])
          : DateTime.now(),
      maxMarks: (json['max_marks'] as num?)?.toDouble() ?? 100.0,
      passingMarks: (json['passing_marks'] as num?)?.toDouble() ?? 35.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
