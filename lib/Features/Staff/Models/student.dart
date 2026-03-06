enum AttendanceStatus { present, absent, pending }

class Student {
  final String id;
  final String name;
  final String studentId;
  final String course;
  AttendanceStatus status;
  final String imageUrl;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.course,
    this.status = AttendanceStatus.pending,
    required this.imageUrl, // Placeholder for image asset path or URL
  });
}
