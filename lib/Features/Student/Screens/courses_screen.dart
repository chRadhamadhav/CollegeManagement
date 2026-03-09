import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';
import 'package:flutter/material.dart';

/// Displays the current semester's subjects, derived from the student's timetable.
///
/// Since there is no dedicated "courses" backend endpoint, unique subjects are
/// extracted from the timetable, which is already filtered to the student's dept.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final slots = await StudentService().fetchTimetable();
      // Deduplicate by subject_id to get unique subjects
      final seen = <String>{};
      final subjects = <Map<String, dynamic>>[];
      for (final slot in slots) {
        final sid = slot['subject_id'] as String? ?? '';
        if (sid.isNotEmpty && seen.add(sid)) {
          subjects.add({
            'subject_id': sid,
            'subject_name': slot['subject_name'] ?? 'Unknown Subject',
            'subject_code': slot['subject_code'] ?? '',
          });
        }
      }
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load courses.';
          _isLoading = false;
        });
      }
    }
  }

  static const List<Color> _courseColors = [
    Colors.blue,
    Colors.teal,
    Colors.purple,
    Colors.orange,
    Colors.indigo,
    Colors.green,
    Colors.redAccent,
    Colors.pink,
  ];

  static const List<IconData> _courseIcons = [
    Icons.account_tree_outlined,
    Icons.hub_outlined,
    Icons.storage_outlined,
    Icons.settings_system_daydream_outlined,
    Icons.calculate_outlined,
    Icons.language_outlined,
    Icons.science_outlined,
    Icons.engineering_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadCourses, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No courses found for your department.',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Current Semester',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_subjects.length} Subjects',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < _subjects.length; i++) ...[
          _buildCourseCard(_subjects[i], i),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> subject, int index) {
    final name = subject['subject_name'] as String? ?? 'Unknown';
    final code = subject['subject_code'] as String? ?? '';
    final color = _courseColors[index % _courseColors.length];
    final icon = _courseIcons[index % _courseIcons.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (code.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
