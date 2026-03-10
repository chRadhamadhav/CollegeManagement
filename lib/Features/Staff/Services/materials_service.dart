import 'package:dio/dio.dart';
import 'package:vidhya_sethu/Features/Staff/Models/material_category.dart';
import 'package:vidhya_sethu/core/api/api_client.dart';
import 'package:vidhya_sethu/core/logger/app_logger.dart';

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
      AppLogger.info('Fetching categories for subject: $subjectId');
      // Add timestamp to bypass caching
      final response = await _dio.get(
        'staff/materials/$subjectId/',
        queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        AppLogger.info('Fetched ${data.length} categories');
        AppLogger.info('Categories response body: $data');
        return data.map((json) => MaterialCategory.fromJson(json)).toList();
      } else {
        AppLogger.warn(
          'getCategories unexpected status: ${response.statusCode}',
        );
      }
    } catch (e) {
      AppLogger.error('getCategories ERROR for subject: $subjectId', e);
    }
    return [];
  }

  Future<bool> addCategory(String name, String subjectId) async {
    try {
      AppLogger.info('Adding category: $name for subject: $subjectId');
      final response = await _dio.post(
        'staff/materials/categories/',
        data: {'name': name, 'subject_id': subjectId},
      );
      AppLogger.info('addCategory response: ${response.statusCode}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      AppLogger.error('addCategory ERROR', e);
      if (e is DioException) {
        AppLogger.error('Dio Response: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<bool> addMaterial({
    required String filePath,
    required String fileName,
    required String categoryId,
  }) async {
    try {
      AppLogger.info('Uploading material: $fileName to category: $categoryId');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post(
        'staff/materials/$categoryId/upload/',
        data: formData,
      );
      AppLogger.info('Upload response: ${response.statusCode}');
      return response.statusCode == 201;
    } catch (e) {
      AppLogger.error('addMaterial ERROR for category: $categoryId', e);
      return false;
    }
  }

  Future<bool> deleteMaterial(String materialId) async {
    try {
      final response = await _dio.delete('staff/materials/$materialId/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      AppLogger.error('deleteMaterial ERROR for ID: $materialId', e);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    // Backend doesn't support category deletion yet, return false
    return false;
  }
}
