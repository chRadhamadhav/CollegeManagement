import 'package:vidhya_sethu/Features/HOD/Screens/HODDashboard.dart';
import 'package:vidhya_sethu/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:vidhya_sethu/Features/HOD/Services/hod_service.dart';
import 'package:vidhya_sethu/core/constants/app_colors.dart';
import 'package:vidhya_sethu/core/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PostResultsScreen extends StatefulWidget {
  const PostResultsScreen({super.key});

  @override
  State<PostResultsScreen> createState() => _PostResultsScreenState();
}

class _PostResultsScreenState extends State<PostResultsScreen> {
  final HODService _hodService = HODService();

  // ── Dropdown states ──
  String _semester = 'Semester 5';
  String _type = 'Internal 1';
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  bool _isCsvSelected = false;
  bool _isLoading = true;

  final List<String> _semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];
  final List<String> _types = [
    'Internal 1',
    'Internal 2',
    'Internal 3',
    'External',
  ];

  List<Map<String, dynamic>> _allSubjects = [];
  List<Map<String, dynamic>> _allExams = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _hodService.getSubjects(),
        _hodService.getExams(),
        _hodService.getStudents(),
      ]);

      _allSubjects = results[0] ?? [];
      _allExams = results[1] ?? [];
      final studentList = results[2] ?? [];

      if (_allSubjects.isNotEmpty) {
        _selectedSubjectId = _allSubjects.first['id'];
        _selectedSubjectName = _allSubjects.first['name'];
      }

      // Initialize controllers for students with colors
      _students = studentList.map((s) {
        final int colorIndex = (s['name']?.length ?? 0) % 5;
        final List<Color> bgColors = [
          const Color(0xFF1A2B2A),
          const Color(0xFF2A1A2B),
          const Color(0xFF2A221A),
          const Color(0xFF2A2A2A),
          const Color(0xFF1A252B),
        ];
        final List<Color> iconColors = [
          const Color(0xFF7ECFB3),
          const Color(0xFFCF7EBF),
          const Color(0xFFCFAA7E),
          Colors.white70,
          const Color(0xFF7EACCF),
        ];

        return {
          ...s,
          'controller': TextEditingController(text: '00'),
          'initials': _getInitials(s['name'] ?? 'S'),
          'avatarBg': bgColors[colorIndex],
          'iconColor': iconColors[colorIndex],
          'roll': s['roll_number'] ?? 'N/A',
        };
      }).toList();

      await _loadExistingMarks();
    } catch (e) {
      AppLogger.error('Error loading initial data', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  Future<void> _loadExistingMarks() async {
    if (_selectedSubjectId == null) return;

    // Find if an exam exists for this subject and type
    final exam = _allExams.firstWhere(
      (e) =>
          e['subject_id'] == _selectedSubjectId &&
          e['name'].toString().toLowerCase() == _type.toLowerCase(),
      orElse: () => {},
    );

    if (exam.isNotEmpty) {
      final marks = await _hodService.getExamMarks(exam['id']);
      if (marks != null) {
        setState(() {
          for (var student in _students) {
            final mark = marks.firstWhere(
              (m) => m['student_id'] == student['id'],
              orElse: () => {},
            );
            if (mark.isNotEmpty) {
              (student['controller'] as TextEditingController).text =
                  mark['marks_obtained'].toString().split('.')[0];
            } else {
              (student['controller'] as TextEditingController).text = '00';
            }
          }
        });
      }
    } else {
      // Clear marks if no exam found
      setState(() {
        for (var student in _students) {
          (student['controller'] as TextEditingController).text = '00';
        }
      });
    }
  }

  Future<void> _submitResults() async {
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    final exam = _allExams.firstWhere(
      (e) =>
          e['subject_id'] == _selectedSubjectId &&
          e['name'].toString().toLowerCase() == _type.toLowerCase(),
      orElse: () => {},
    );

    if (exam.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No exam found for this subject and type. Create one in Schedules.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final List<Map<String, dynamic>> marksToSubmit = _students.map((s) {
      final controller = s['controller'] as TextEditingController;
      double score = double.tryParse(controller.text) ?? 0.0;
      return {
        'student_id': s['id'],
        'marks_obtained': score,
        'is_absent': score == 0 && controller.text != '0', // Optional logic
      };
    }).toList();

    final success = await _hodService.postExamResults(
      exam['id'],
      marksToSubmit,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Results posted successfully!' : 'Failed to post results',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final s in _students) {
      if (s['controller'] != null) {
        (s['controller'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hodBackground,
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: AppColors.hodBackground,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HODDashboardScreen()),
            (route) => false,
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF4DB6FF),
            size: 14,
          ),
          label: const Text(
            'Back',
            style: TextStyle(color: Color(0xFF4DB6FF), fontSize: 15),
          ),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
        leadingWidth: 90,
        title: const Text(
          'Post Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3A7AFF),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Semester + Type Dropdowns ──
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledDropdown(
                          label: 'SEMESTER',
                          value: _semester,
                          items: _semesters,
                          onChanged: (v) => setState(() => _semester = v!),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _LabeledDropdown(
                          label: 'TYPE',
                          value: _type,
                          items: _types,
                          onChanged: (v) {
                            setState(() => _type = v!);
                            _loadExistingMarks();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Subject Dropdown (full width) ──
                  if (_allSubjects.isNotEmpty)
                    _LabeledDropdown(
                      label: 'SUBJECT',
                      value: _selectedSubjectName ?? '',
                      items: _allSubjects
                          .map((s) => s['name'] as String)
                          .toList(),
                      onChanged: (v) {
                        final sub = _allSubjects.firstWhere(
                          (s) => s['name'] == v,
                        );
                        setState(() {
                          _selectedSubjectName = v;
                          _selectedSubjectId = sub['id'];
                        });
                        _loadExistingMarks();
                      },
                    ),
                  const SizedBox(height: 20),

                  // ── Upload CSV / Manual Entry Toggle ──
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCsvSelected = true),
                          child: _EntryModeButton(
                            icon: Icons.upload_file_outlined,
                            label: 'UPLOAD CSV',
                            isActive: _isCsvSelected,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCsvSelected = false),
                          child: _EntryModeButton(
                            icon: Icons.edit_note_outlined,
                            label: 'MANUAL ENTRY',
                            isActive: !_isCsvSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Student List Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_students.length} Students',
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Student Cards ──
                  ..._students.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StudentMarksCard(student: s),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ── Post Results Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hodAccentBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                label: Text(
                  _isLoading ? 'Processing...' : 'Post Results',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const HodBottomNavBar(activeTab: HodTab.home),
    );
  }
}

// ─────────────────────────────────────────────
// Labeled Dropdown
// ─────────────────────────────────────────────
class _LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.hodSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hodBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.hodSurface,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white60,
                size: 20,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Entry Mode Button (CSV / Manual)
// ─────────────────────────────────────────────
class _EntryModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _EntryModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0D1E3A) : const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFF3A7AFF) : const Color(0xFF1E2A40),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4DB6FF) : Colors.white54,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF4DB6FF) : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Student Marks Card
// ─────────────────────────────────────────────
class _StudentMarksCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentMarksCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final String? initials = student['initials'] as String?;
    final TextEditingController ctrl =
        student['controller'] as TextEditingController;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2A40), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: student['avatarBg'] as Color,
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: initials != null
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: student['iconColor'] as Color,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 12),

          // Name + Roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Roll: ${student['roll']}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          // MARKS label (only if marks entered)
          if (ctrl.text != '00') ...[
            const Text(
              'MARKS',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Marks input box
          Container(
            width: 52,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1725),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ctrl.text != '00'
                    ? const Color(0xFF2A5AA0)
                    : const Color(0xFF1E2A40),
                width: 1,
              ),
            ),
            child: Center(
              child: TextField(
                controller: ctrl,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 3,
                style: TextStyle(
                  color: ctrl.text != '00'
                      ? const Color(0xFF4DB6FF)
                      : Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),
          const Text(
            '/100',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
