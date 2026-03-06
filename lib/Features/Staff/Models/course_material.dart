class CourseMaterial {
  final String id;
  final String fileUrl;
  final String fileName;
  final DateTime dateAdded;
  final String categoryId;

  CourseMaterial({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.dateAdded,
    required this.categoryId,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      id: json['id'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      categoryId: json['category_id'] ?? '',
      dateAdded: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
