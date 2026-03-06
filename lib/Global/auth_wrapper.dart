import 'package:college_management/Features/Admin/Screens/admin_dashboard.dart';
import 'package:college_management/Features/HOD/Screens/HODDashboard.dart';
import 'package:college_management/Features/Staff/Screens/dashboard.dart';
import 'package:college_management/Features/Student/Screens/student_dashboard.dart';
import 'package:college_management/Global/login.dart';
import 'package:college_management/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget _initialScreen = const StudentLoginPage();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final stayLoggedIn = await SecureStorage.getStayLoggedIn();

      if (stayLoggedIn) {
        final token = await SecureStorage.getAccessToken();
        final role = await SecureStorage.getUserRole();

        if (token != null && role != null) {
          // Valid session, bypass login
          setState(() {
            _initialScreen = _getDashboardForRole(role);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error checking authentication: $e');
    }

    // Default to login screen
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getDashboardForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const AdminDashboard();
      case 'hod':
        return const HODDashboardScreen();
      case 'staff':
        return const HomeScreen();
      case 'student':
        return const StudentDashboard();
      default:
        return const StudentLoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E1A2B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
        ),
      );
    }

    return _initialScreen;
  }
}
