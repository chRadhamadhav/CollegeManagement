import 'package:vidhya_sethu/Features/Admin/Screens/admin_dashboard.dart';
import 'package:vidhya_sethu/Features/Admin/Screens/detailed_statistics.dart';
import 'package:vidhya_sethu/Features/Admin/Screens/user_management.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/HODDashboard.dart';
import 'package:vidhya_sethu/Features/Staff/Screens/staff_main_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/student_dashboard.dart';
import 'package:vidhya_sethu/Global/login.dart';
import 'package:flutter/material.dart';

/// Centralised named route definitions for the entire application.
///
/// Use [AppRoutes.generate] with [MaterialApp.onGenerateRoute] to resolve
/// routes by name and keep navigation logic out of UI widgets.
///
/// Usage (push by name):
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.adminDashboard);
/// ```
abstract final class AppRoutes {
  // ─── Entry ─────────────────────────────────────────────────────────
  static const String login = '/';

  // ─── Admin ─────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStatistics = '/admin/statistics';
  static const String adminUsers = '/admin/users';

  // ─── HOD ───────────────────────────────────────────────────────────
  static const String hodDashboard = '/hod/dashboard';

  // ─── Staff ─────────────────────────────────────────────────────────
  static const String staffMain = '/staff/main';

  // ─── Student ───────────────────────────────────────────────────────
  static const String studentDashboard = '/student/dashboard';

  // ─── Route factory ─────────────────────────────────────────────────

  /// Generates the [Route] for [settings.name].
  ///
  /// Unknown routes fall back to the login screen so the app never crashes
  /// with an unhandled route exception.
  static Route<dynamic> generate(RouteSettings settings) {
    final builder = _routes[settings.name] ?? _routes[login]!;
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  static final Map<String, WidgetBuilder> _routes = {
    login: (_) => const StudentLoginPage(),
    adminDashboard: (_) => const AdminDashboard(),
    adminStatistics: (_) => const DetailedStatistics(),
    adminUsers: (_) => const UserManagementPage(),
    hodDashboard: (_) => const HODDashboardScreen(),
    staffMain: (_) => const StaffMainScreen(),
    studentDashboard: (_) => const StudentDashboard(),
  };
}
