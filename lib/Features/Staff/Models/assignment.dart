class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    required this.createdAt,
  });
}
