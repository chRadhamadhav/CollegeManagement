import 'package:college_management/Features/Staff/Screens/attendance.dart';
import 'package:college_management/Features/Staff/Screens/materials_screen.dart';
import 'package:college_management/Features/Staff/Screens/Exams/exam_dashboard.dart';
import 'package:college_management/Features/Staff/Screens/Assignments/assignments_dashboard.dart';
import 'package:college_management/Features/Staff/Services/materials_service.dart';
import 'package:college_management/Features/Staff/Services/timetable_service.dart';
import 'package:college_management/Features/Staff/Models/material_category.dart';
import 'package:college_management/Features/Staff/Widgets/dashboard_header.dart';
import 'package:college_management/Features/Staff/Widgets/quick_action_card.dart';
import 'package:college_management/Features/Staff/Widgets/today_class_card.dart';
import 'package:college_management/Features/Staff/Services/staff_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _upcomingClass;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final staffService = StaffService();
    final timetableService = TimetableService();

    // Load profile, dashboard stats, and timetable simultaneously
    final results = await Future.wait([
      staffService.getStaffProfile(),
      staffService.getStaffDashboard(),
      timetableService.fetchTimetable(),
    ]);

    if (mounted) {
      setState(() {
        _profileData = results[0] as Map<String, dynamic>?;
        _dashboardData = results[1] as Map<String, dynamic>?;

        final slotsList = results[2] as List<dynamic>;
        final slots = List<Map<String, dynamic>>.from(slotsList);

        if (slots.isNotEmpty) {
          _upcomingClass = slots.first;
        }

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Wrapped in Scaffold so InkWell widgets have a Material ancestor
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(profileData: _profileData),

              const SizedBox(height: 20),

              // ================= TODAY'S CLASSES =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S CLASSES",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Backend
                      // Navigate to schedule screen
                    },
                    child: const Text("View Schedule"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TodayClassCard(classData: _upcomingClass),

              const SizedBox(height: 24),

              // ================= QUICK ACTIONS =================
              Text(
                "QUICK ACTIONS",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      QuickActionCard(
                        icon: Icons.how_to_reg,
                        title: "Attendance",
                        subtitle:
                            "${_dashboardData?['total_students'] ?? 0} Students",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttendanceScreen(),
                            ),
                          );
                        },
                      ),
                      QuickActionCard(
                        icon: Icons.assignment,
                        title: "Assignments",
                        subtitle:
                            "${_dashboardData?['total_assignments'] ?? 0} Total",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AssignmentsDashboard(),
                            ),
                          );
                        },
                      ),
                      QuickActionCard(
                        icon: Icons.edit_note,
                        title: "Exam Marks",
                        subtitle:
                            "${_dashboardData?['total_subjects'] ?? 0} Subjects",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExamDashboard(),
                            ),
                          );
                        },
                      ),
                      QuickActionCard(
                        icon: Icons.upload_file,
                        title: "Materials",
                        subtitle:
                            "${_dashboardData?['total_materials'] ?? 0} Files",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MaterialsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ================= QUICK UPLOAD =================
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await _showQuickUploadDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quick Upload",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Upload study materials instantly",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).hintColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickUploadDialog(BuildContext context) async {
    final materialsService = MaterialsService();
    final timetableService = TimetableService();

    // 1. Pick file first
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;

    if (!context.mounted) return;

    // 2. Show a dialog to pick course and category
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final courses = await timetableService.fetchCourses();
    if (!context.mounted) return;
    Navigator.pop(context); // close loader

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No courses available to upload to.')),
      );
      return;
    }

    String selectedCourse = courses.first;
    List<MaterialCategory> categories = await materialsService.getCategories(
      selectedCourse,
    );
    String? selectedCategoryId = categories.isNotEmpty
        ? categories.first.id
        : null;
    bool isLoadingCategories = false;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Quick Upload'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File: ${file.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Course'),
                  value: selectedCourse,
                  isExpanded: true,
                  items: courses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null && value != selectedCourse) {
                      setState(() {
                        selectedCourse = value;
                        isLoadingCategories = true;
                      });
                      final newCats = await materialsService.getCategories(
                        value,
                      );
                      setState(() {
                        categories = newCats;
                        selectedCategoryId = newCats.isNotEmpty
                            ? newCats.first.id
                            : null;
                        isLoadingCategories = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (isLoadingCategories)
                  const Center(child: CircularProgressIndicator())
                else if (categories.isEmpty)
                  const Text(
                    'No categories in this course. Please use the Materials screen to create one.',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: selectedCategoryId,
                    isExpanded: true,
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedCategoryId = value);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    (categories.isEmpty ||
                        selectedCategoryId == null ||
                        isLoadingCategories)
                    ? null
                    : () async {
                        // Upload
                        Navigator.pop(context); // close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Uploading...')),
                        );
                        final success = await materialsService.addMaterial(
                          filePath: file.path!,
                          fileName: file.name,
                          categoryId: selectedCategoryId!,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Upload successful!'
                                    : 'Upload failed.',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }
}
