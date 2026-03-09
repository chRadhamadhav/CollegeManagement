import 'package:vidhya_sethu/Features/HOD/Screens/HODDashboard.dart';
import 'package:vidhya_sethu/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:vidhya_sethu/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PostResultsScreen extends StatefulWidget {
  const PostResultsScreen({super.key});

  @override
  State<PostResultsScreen> createState() => _PostResultsScreenState();
}

class _PostResultsScreenState extends State<PostResultsScreen> {
  // ── Dropdown states ──
  String _semester = 'Semester 5';
  String _type = 'Internal 1';
  String _subject = 'Data Structures & Algorithms';
  bool _isCsvSelected = true;

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
  final List<String> _subjects = [
    'Data Structures & Algorithms',
    'Operating Systems',
    'DBMS',
    'Computer Networks',
    'Machine Learning',
  ];

  // ── Student data with marks controllers ──
  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Aditya Sharma',
      'roll': 'CS-2021-042',
      'avatarBg': const Color(0xFF1A2B2A),
      'iconColor': const Color(0xFF7ECFB3),
      'initials': null,
      'controller': TextEditingController(text: '98'),
    },
    {
      'name': 'Priya Patel',
      'roll': 'CS-2021-089',
      'avatarBg': const Color(0xFF2A1A2B),
      'iconColor': const Color(0xFFCF7EBF),
      'initials': null,
      'controller': TextEditingController(text: '95'),
    },
    {
      'name': 'Rahul Verma',
      'roll': 'CS-2021-015',
      'avatarBg': const Color(0xFF2A221A),
      'iconColor': const Color(0xFFCFAA7E),
      'initials': null,
      'controller': TextEditingController(text: '00'),
    },
    {
      'name': 'Sana Khan',
      'roll': 'CS-2021-022',
      'avatarBg': const Color(0xFF2A2A2A),
      'iconColor': Colors.white70,
      'initials': 'SK',
      'controller': TextEditingController(text: '00'),
    },
  ];

  @override
  void dispose() {
    for (final s in _students) {
      (s['controller'] as TextEditingController).dispose();
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
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Subject Dropdown (full width) ──
                  _LabeledDropdown(
                    label: 'SUBJECT',
                    value: _subject,
                    items: _subjects,
                    onChanged: (v) => setState(() => _subject = v!),
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
                        '64 Students',
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hodAccentBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.upload_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Post Results',
                  style: TextStyle(
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
