import 'course_material.dart';

class MaterialCategory {
  final String id;
  final String name;
  final String subjectId;
  final DateTime dateCreated;
  final List<CourseMaterial> materials;

  MaterialCategory({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.dateCreated,
    this.materials = const [],
  });

  factory MaterialCategory.fromJson(Map<String, dynamic> json) {
    return MaterialCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subjectId: json['subject_id'] ?? '',
      dateCreated: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      materials:
          (json['materials'] as List?)
              ?.map((e) => CourseMaterial.fromJson(e))
              .toList() ??
          [],
    );
  }
}
