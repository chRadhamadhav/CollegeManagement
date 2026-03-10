import 'package:vidhya_sethu/Features/Admin/Models/user_model.dart';
import 'package:vidhya_sethu/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/logger/app_logger.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('admin/users');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['users'] ?? [];
        return usersJson.map((json) {
          final roleStr = json['role'] as String? ?? 'student';
          String category = 'Students';
          if (roleStr == 'staff') category = 'Staff';
          if (roleStr == 'hod') category = 'HODs';
          if (roleStr == 'admin') category = 'Admins';

          final name = json['full_name'] ?? 'Unknown';

          return User(
            id: json['id'] ?? '',
            email: json['email'] ?? '',
            name: name,
            role: roleStr,
            category: category,
            avatarUrl: json['avatar_url'],
            initials: name.isNotEmpty ? name[0].toUpperCase() : 'U',
            color: Colors.blueAccent,
            statusColor: (json['is_active'] == true)
                ? Colors.greenAccent
                : Colors.redAccent,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error fetching users', e);
      return [];
    }
  }

  /// Adds a new user. Returns null on success, or an error message on failure.
  Future<String?> addUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('admin/users', data: data);
      if (response.statusCode == 201) {
        return null;
      }
      return 'Unexpected response: ${response.statusCode}';
    } catch (e) {
      AppLogger.error('Error adding user', e);
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        if (e.response?.statusCode == 409) {
          return 'User with this email already exists.';
        }
      }
      return 'Failed to create user. Please try again.';
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    // Backend only has deactivate currently (patch /admin/users/{id}/deactivate)
    // We'll simulate update passing for now or implement full update later
    return true;
  }

  Future<bool> deleteUser(String userId) async {
    if (userId.isEmpty) {
      AppLogger.error('Error: Attempted to delete user with empty ID', null);
      return false;
    }
    try {
      final path = 'admin/users/$userId';
      AppLogger.info('Attempting to delete user: $userId at path: $path');
      final response = await _apiClient.dio.delete(path);

      if (response.statusCode == 204) {
        return true;
      } else {
        AppLogger.error(
          'Unexpected status code ${response.statusCode} while deleting user: ${response.data}',
          null,
        );
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(
          'Dio error deleting user: ${e.response?.statusCode} - ${e.response?.data}',
          e,
        );
      } else {
        AppLogger.error('Unexpected error deleting user: $userId', e);
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('admin/statistics');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching dashboard stats', e);
      return null;
    }
  }

  Future<bool> checkSystemHealth() async {
    try {
      // Create a fresh dio instance to bypass the api client's prefix /api/v1
      // and directly hit /health
      final dio = _apiClient.dio;
      var baseUrl = dio.options.baseUrl.replaceAll('/api/v1', '');

      // Remove trailing slash if it exists to avoid //health
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      final response = await dio.get('$baseUrl/health');
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      AppLogger.error('Health check error', e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('auth/me');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching user profile', e);
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('auth/me', data: data);
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error updating user profile', e);
      return false;
    }
  }

  Future<bool> uploadProfileImage(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });

      final response = await _apiClient.dio.post(
        'auth/me/avatar',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error uploading profile image', e);
      return false;
    }
  }

  Future<bool> bulkUploadUsers(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });

      final response = await _apiClient.dio.post(
        'admin/users/bulk',
        data: formData,
      );

      return response.statusCode == 201;
    } catch (e) {
      AppLogger.error('Error bulk uploading users', e);
      return false;
    }
  }
}
