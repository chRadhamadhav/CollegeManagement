class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  final String subjectId;
  final int maxMarks;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    required this.subjectId,
    this.maxMarks = 100,
    required this.createdAt,
  });
}
