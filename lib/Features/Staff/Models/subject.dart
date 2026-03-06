class Subject {
  final String id;
  final String name;
  final String code;
  final String departmentId;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      departmentId: json['department_id'] ?? '',
    );
  }
}
