import 'package:vidhya_sethu/Features/Student/Screens/timetable_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/profile_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/calendar_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/courses_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/result_screen.dart';
import 'package:vidhya_sethu/Features/Student/Screens/study_material.dart';
import 'package:vidhya_sethu/Features/Student/Screens/upload_assignment.dart';
import 'package:vidhya_sethu/Features/Student/Widgets/dashboard_action_grid_item.dart';
import 'package:vidhya_sethu/Features/Student/Widgets/dashboard_header.dart';
import 'package:vidhya_sethu/Features/Student/Widgets/material_item.dart';
import 'package:vidhya_sethu/Features/Student/Widgets/student_info_card.dart';
import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const CoursesScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light background like the image
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2F80ED),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _recentMaterials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final studentService = StudentService();
    // Load profile, dashboard stats, and recent materials simultaneously
    final results = await Future.wait([
      studentService.getStudentProfile(),
      studentService.getStudentDashboard(),
      studentService.fetchMaterials(),
    ]);

    if (mounted) {
      setState(() {
        _profileData = results[0] as Map<String, dynamic>?;
        _dashboardData = results[1] as Map<String, dynamic>?;
        // Show only the 3 most recent materials
        final allMaterials = results[2] as List<Map<String, dynamic>>;
        _recentMaterials = allMaterials.take(3).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          DashboardHeader(profileData: _profileData),
          const SizedBox(height: 25),

          // Student Info Card
          StudentInfoCard(profileData: _profileData),
          const SizedBox(height: 25),

          // Action Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Action Grid Items
              DashboardActionGridItem(
                icon: Icons.school_outlined,
                iconColor: Colors.green,
                title: "View Results",
                subtitle:
                    "${_dashboardData?['attendance_percentage'] ?? 0}% Attendance",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultScreen()),
                ),
              ),
              DashboardActionGridItem(
                icon: Icons.upload_file_outlined,
                iconColor: Colors.orange,
                title: "Upload Assignment",
                subtitle:
                    "${_dashboardData?['pending_assignments'] ?? 0} Pending",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadAssignmentPage(),
                  ),
                ),
              ),
              DashboardActionGridItem(
                icon: Icons.library_books_outlined,
                iconColor: Colors.purple,
                title: "Study Materials",
                subtitle: "Access Course Files",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudyMaterialPage()),
                ),
              ),
              DashboardActionGridItem(
                icon: Icons.schedule_outlined,
                iconColor: Colors.teal,
                title: "Timetable",
                subtitle: "View Weekly Schedule",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimetableScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Recent Materials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Materials",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudyMaterialPage(),
                    ),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Color(0xFF2F80ED)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recent materials — live from backend (empty state handled gracefully)
          if (_recentMaterials.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No materials uploaded yet.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            )
          else
            ..._recentMaterials.map((material) {
              final title = material['title'] as String? ?? 'Untitled';
              final subjectCode = material['subject_code'] as String? ?? '';
              final subjectName = material['subject_name'] as String? ?? '';
              final subtitle = subjectCode.isNotEmpty
                  ? '$subjectCode • $subjectName'
                  : subjectName;

              final IconData icon;
              final Color iconColor;
              if (title.toLowerCase().endsWith('.pdf')) {
                icon = Icons.picture_as_pdf;
                iconColor = Colors.redAccent;
              } else if (title.toLowerCase().endsWith('.docx') ||
                  title.toLowerCase().endsWith('.doc')) {
                icon = Icons.description;
                iconColor = Colors.blueAccent;
              } else {
                icon = Icons.insert_drive_file_outlined;
                iconColor = Colors.orange;
              }

              return MaterialItem(
                icon: icon,
                iconColor: iconColor,
                title: title,
                subtitle: subtitle,
                onDownload: () async {
                  final apiUrl =
                      dotenv.env['API_BASE_URL'] ??
                      'http://127.0.0.1:8000/api/v1';
                  final baseUrl = apiUrl.replaceAll('/api/v1', '');
                  final fileUrl = material['file_url'] as String?;

                  if (fileUrl != null && fileUrl.isNotEmpty) {
                    final url = Uri.parse('$baseUrl$fileUrl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open file')),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File URL not found')),
                    );
                  }
                },
              );
            }),
        ],
      ),
    );
  }
}
