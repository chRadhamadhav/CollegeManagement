import 'dart:convert';
import 'dart:typed_data';
import 'package:vidhya_sethu/Features/Student/Screens/profile_screen.dart';
import 'package:vidhya_sethu/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// Reuse the mock HTTP adapter
class MockAdapter implements HttpClientAdapter {
  Map<String, ResponseBody> responses = {};

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
  group('ProfileScreen Widget Tests', () {
    late MockAdapter mockAdapter;

    setUpAll(() {
      dotenv.testLoad(
        fileInput: '''API_BASE_URL=http://127.0.0.1:8000/api/v1''',
      );
    });

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockAdapter = MockAdapter();
      ApiClient().dio.httpClientAdapter = mockAdapter;
      // Strip interceptors to avoid secure storage channel crashes
      ApiClient().dio.interceptors.clear();
    });

    testWidgets('Renders loading indicator then loaded profile state', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockAdapter.onGet('/student/profile', 200, {
        'id': '12345678-uuid-test',
        'full_name': 'Test Student',
        'email': 'student@test.com',
        'roll_number': 'CS-001',
        'department_name': 'Computer Science',
        'course': 'B.Tech',
        'semester': '4',
        'phone_number': '1234567890',
        'avatar_url': null, // Avoid NetworkImage HTTP requests in test
      });

      // Act
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      // Initial state is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump to let the Future resolve
      await tester.pumpAndSettle();

      // Assert loaded UI
      expect(find.text('Test Student'), findsOneWidget);
      expect(find.text('CS-001'), findsOneWidget);
      expect(find.text('student@test.com'), findsOneWidget);
      expect(find.text('Computer Science'), findsOneWidget);
    });

    testWidgets('Renders error UI with Retry button on 404', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockAdapter.onGet('/student/profile', 404, {'error': 'Not found'});

      // Act
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Assert error UI
      expect(find.text('Failed to load profile data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
