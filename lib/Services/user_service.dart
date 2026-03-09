import 'package:college_management/Features/Admin/Models/user_model.dart';
import 'package:college_management/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('/admin/users');
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
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<bool> addUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/admin/users', data: data);
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    // Backend only has deactivate currently (patch /admin/users/{id}/deactivate)
    // We'll simulate update passing for now or implement full update later
    return true;
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _apiClient.dio.delete('/admin/users/$userId');
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/admin/statistics');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return null;
    }
  }

  Future<bool> checkSystemHealth() async {
    try {
      // Create a fresh dio instance to bypass the api client's prefix /api/v1
      // and directly hit /health
      final dio = _apiClient.dio;
      final baseUrl = dio.options.baseUrl.replaceAll('/api/v1', '');

      final response = await dio.get('$baseUrl/health');
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/auth/me', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> uploadProfileImage(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });

      final response = await _apiClient.dio.post(
        '/auth/me/avatar',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading profile image: $e');
      return false;
    }
  }

  Future<bool> bulkUploadUsers(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });

      final response = await _apiClient.dio.post(
        '/admin/users/bulk',
        data: formData,
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error bulk uploading users: $e');
      return false;
    }
  }
}
