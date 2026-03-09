import 'dart:convert';
import 'dart:typed_data';
import 'package:vidhya_sethu/Features/Student/Screens/calendar_screen.dart';
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
  group('CalendarScreen Widget Tests', () {
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

    testWidgets('Renders empty state when no events exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockAdapter.onGet('/student/events', 200, []);

      // Act
      await tester.pumpWidget(const MaterialApp(home: CalendarScreen()));
      await tester.pumpAndSettle();

      // Assert empty UI
      expect(find.text('No upcoming events'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });

    testWidgets('Renders grouped events logically on 200 OK', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockAdapter.onGet('/student/events', 200, [
        {
          'id': 'evt-1',
          'title': 'Computer Architecture Midterm',
          'event_date': '2026-10-15',
          'event_time': '14:30',
          'event_type': 'Academic',
        },
        {
          'id': 'evt-2',
          'title': 'Diwali Break',
          'event_date': '2026-11-05',
          'event_time': null,
          'event_type': 'Holiday',
        },
      ]);

      // Act
      await tester.pumpWidget(const MaterialApp(home: CalendarScreen()));
      await tester.pumpAndSettle();

      // Assert Group Headers (Month and Year)
      expect(find.text('October 2026 - November 2026'), findsOneWidget);
      expect(find.text('October'), findsOneWidget);
      expect(find.text('November'), findsOneWidget);

      // Assert Event 1 Layout
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Oct'), findsOneWidget);
      expect(find.text('Computer Architecture Midterm'), findsOneWidget);
      expect(
        find.text('02:30 PM'),
        findsOneWidget,
      ); // Checks custom time parsing

      // Assert Event 2 Layout
      expect(find.text('05'), findsOneWidget);
      expect(find.text('Nov'), findsOneWidget);
      expect(find.text('Diwali Break'), findsOneWidget);
      expect(find.text('All Day'), findsOneWidget); // Checks null time fallback
    });
  });
}
