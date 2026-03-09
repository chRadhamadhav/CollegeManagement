import 'dart:convert';
import 'dart:typed_data';
import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';
import 'package:vidhya_sethu/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// A simple mock HTTP adapter for Dio that overrides network requests in tests
class MockAdapter implements HttpClientAdapter {
  Map<String, ResponseBody> responses = {};

  // Helper to register mock responses
  void onGet(String path, int statusCode, dynamic data) {
    responses[path] = ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    if (responses.containsKey(path)) {
      return responses[path]!;
    }
    return ResponseBody.fromString('Not Found', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('StudentService API Tests', () {
    late StudentService service;
    late MockAdapter mockAdapter;

    setUpAll(() {
      dotenv.testLoad(
        fileInput: '''API_BASE_URL=http://127.0.0.1:8000/api/v1''',
      );
    });

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Create our mock adapter
      mockAdapter = MockAdapter();
      // Inject the mock adapter directly into the singleton's Dio instance
      ApiClient().dio.httpClientAdapter = mockAdapter;
      // Strip out the interceptor that calls SecureStorage via Platform Channels
      ApiClient().dio.interceptors.clear();
      // Initialize the service which uses ApiClient().dio under the hood
      service = StudentService();
    });

    test('getStudentProfile returns parsed map on 200 OK', () async {
      // Arrange
      final mockData = {
        'id': '123',
        'full_name': 'Test Student',
        'email': 'student@test.com',
        'roll_number': 'CS-001',
      };
      mockAdapter.onGet('/student/profile', 200, mockData);

      // Act
      final result = await service.getStudentProfile();

      // Assert
      expect(result, isNotNull);
      expect(result!['full_name'], 'Test Student');
      expect(result['roll_number'], 'CS-001');
    });

    test('getStudentProfile returns null on 404 (Missing Profile)', () async {
      // Arrange
      mockAdapter.onGet('/student/profile', 404, {
        'error': 'Profile not found',
      });

      // Act
      final result = await service.getStudentProfile();

      // Assert
      expect(result, isNull);
    });

    test('getStudentProfile returns null on 500 Server Error', () async {
      // Arrange
      mockAdapter.onGet('/student/profile', 500, {'error': 'Internal crash'});

      // Act
      final result = await service.getStudentProfile();

      // Assert
      expect(result, isNull);
    });

    test('getStudentDashboard returns stats map on 200 OK', () async {
      // Arrange
      final mockData = {
        'attendance_percentage': 85.5,
        'upcoming_exams': 2,
        'total_assignments': 3,
      };
      mockAdapter.onGet('/student/dashboard', 200, mockData);

      // Act
      final result = await service.getStudentDashboard();

      // Assert
      expect(result, isNotNull);
      expect(result!['attendance_percentage'], 85.5);
      expect(result['upcoming_exams'], 2);
    });
  });
}
