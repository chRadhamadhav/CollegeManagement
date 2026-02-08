import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              // 1. Top Section: Campus Illustration
              Container(
                height: screenHeight * 0.42,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDuNwqZb4GkKElrHx5zDPg6ksCRn0pIFY5RmCpiKSkwSwdNKil3K-jLZkA25pYE1yB-fWRVevE1m7riuArp7xf44Qb2HHTF8VH1WNM9PQ0BAhiUY9NHjb9ME8ZJBBwqnnrx35E-3lP_tybq22L1QDJ9Xs-D3oJG6E3Twg1IOBD5a8AZUXdQb94_YQEShI7AMxaQvtIpumhpg9a_MBhfCI285PtAgcf-OYs8WA1K2pFEICUJ6Yn5eqfNCTfLlxB1WSiCNUbZ7mDcMQg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        const Color(0xFF101922).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Floating Badge
              Positioned(
                top: 55,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "STUDENT PORTAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Login Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF161e27),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 40,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Column(
                            children: [
                              Text(
                                "Welcome Back!",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Please sign in to access your dashboard.",
                                style: TextStyle(
                                  color: Color(0xFF9dabb9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ID Input
                        const Text(
                          "Student / Faculty ID",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField("e.g. 20248491", Icons.badge_outlined),

                        const SizedBox(height: 20),

                        // Password Input
                        const Text(
                          "Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          "••••••••",
                          Icons.visibility_outlined,
                          isObscure: true,
                        ),

                        const SizedBox(height: 12),

                        // Utility Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: true,
                                    onChanged: (v) {},
                                    activeColor: const Color(0xFF137fec),
                                    side: const BorderSide(
                                      color: Color(0xFF3b4754),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Stay logged in",
                                  style: TextStyle(
                                    color: Color(0xFF9dabb9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF137fec),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Sign In Button
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF137fec),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF137fec).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // SSO Section
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFF3b4754))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(
                                  color: Color(0xFF9dabb9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFF3b4754))),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: _socialBtn("Google")),
                            const SizedBox(width: 16),
                            Expanded(child: _socialBtn("Microsoft")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Minimal helper functions
Widget _inputField(String hint, IconData icon, {bool isObscure = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFF1c2127),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF3b4754)),
    ),
    child: TextField(
      obscureText: isObscure,
      // THIS CHANGE TURNS THE TYPED VALUE WHITE
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF637588)),
        suffixIcon: Icon(icon, color: const Color(0xFF9dabb9), size: 20),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget _socialBtn(String label) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFF1c2127),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF3b4754)),
    ),
    child: Center(
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
