import 'package:dio/dio.dart';
import 'package:college_management/Features/Staff/Models/material_category.dart';
import 'package:college_management/core/api/api_client.dart';

class MaterialsService {
  static final MaterialsService _instance = MaterialsService._internal();
  final Dio _dio = ApiClient().dio;

  factory MaterialsService() => _instance;
  MaterialsService._internal();

  Future<void> init() async {
    // No longer needed with HTTP API
  }

  Future<List<MaterialCategory>> getCategories(String subjectId) async {
    try {
      final response = await _dio.get('/staff/materials/$subjectId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MaterialCategory.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error quietly for now
    }
    return [];
  }

  Future<bool> addCategory(String name, String subjectId) async {
    try {
      final response = await _dio.post(
        '/staff/materials/categories',
        data: {'name': name, 'subject_id': subjectId},
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addMaterial({
    required String filePath,
    required String fileName,
    required String categoryId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post(
        '/staff/materials/$categoryId/upload',
        data: formData,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMaterial(String materialId) async {
    try {
      final response = await _dio.delete('/staff/materials/$materialId');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    // Backend doesn't support category deletion yet, return false
    return false;
  }
}
