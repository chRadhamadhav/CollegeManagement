import 'package:flutter/material.dart';
import 'package:vidhya_sethu/Features/Admin/Screens/admin_dashboard.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/HODDashboard.dart';
import 'package:vidhya_sethu/Features/Staff/Screens/dashboard.dart';
import 'package:vidhya_sethu/Features/Student/Screens/student_dashboard.dart';
import 'package:vidhya_sethu/Services/auth_service.dart';

class StudentLoginPage extends StatelessWidget {
  const StudentLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 360,
            width: double.infinity,
            child: Image.network(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuDuNwqZb4GkKElrHx5zDPg6ksCRn0pIFY5RmCpiKSkwSwdNKil3K-jLZkA25pYE1yB-fWRVevE1m7riuArp7xf44Qb2HHTF8VH1WNM9PQ0BAhiUY9NHjb9ME8ZJBBwqnnrx35E-3lP_tybq22L1QDJ9Xs-D3oJG6E3Twg1IOBD5a8AZUXdQb94_YQEShI7AMxaQvtIpumhpg9a_MBhfCI285PtAgcf-OYs8WA1K2pFEICUJ6Yn5eqfNCTfLlxB1WSiCNUbZ7mDcMQg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 420,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF0E1A2B)],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.72,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0E1A2B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: const LoginForm(),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white70),
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.school, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "COLLEGE PORTAL",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _stayLoggedIn = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final role = await _authService.login(
      email,
      password,
      stayLoggedIn: _stayLoggedIn,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (role != null) {
      // Navigate to the correct dashboard based on backend role
      Widget dashboard;
      switch (role.toLowerCase()) {
        case 'admin':
          dashboard = const AdminDashboard();
          break;
        case 'hod':
          dashboard = const HODDashboardScreen();
          break;
        case 'staff':
          dashboard = const HomeScreen();
          break;
        case 'student':
          dashboard = const StudentDashboard();
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown role assigned: $role')),
          );
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF16263A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "       Welcome Back!",
          style: TextStyle(
            fontSize: 34,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "              Please sign in to access your dashboard.",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 28),
        const Text("Email", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: fieldDecoration("e.g. user@college.edu", Icons.person),
        ),
        const SizedBox(height: 20),
        const Text("Password", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFF16263A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _stayLoggedIn,
              onChanged: (value) {
                setState(() {
                  _stayLoggedIn = value ?? false;
                });
              },
              activeColor: const Color(0xFF2F80ED),
              side: const BorderSide(color: Color(0xFF137fec)),
            ),
            const Text(
              "Stay logged in",
              style: TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Sign In →",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 22),
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white30)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "OR CONTINUE WITH",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            Expanded(child: Divider(color: Colors.white30)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _socialButton("Google", Icons.g_mobiledata),
            const SizedBox(width: 12),
            _socialButton("Microsoft", Icons.window),
          ],
        ),
      ],
    );
  }

  static Expanded _socialButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF16263A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
