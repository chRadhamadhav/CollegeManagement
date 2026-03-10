import 'package:vidhya_sethu/Features/HOD/Screens/HODDashboard.dart';
import 'package:vidhya_sethu/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:vidhya_sethu/Features/HOD/Services/hod_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamSchedulesScreen extends StatefulWidget {
  const ExamSchedulesScreen({super.key});

  @override
  State<ExamSchedulesScreen> createState() => _ExamSchedulesScreenState();
}

class _ExamSchedulesScreenState extends State<ExamSchedulesScreen> {
  final HODService _hodService = HODService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final exams = await _hodService.getExams();
    final facultyList = await _hodService.getFaculty();
    final subjectList = await _hodService.getSubjects();

    if (mounted) {
      setState(() {
        _exams = exams ?? [];
        _faculties = facultyList ?? [];
        _subjects = subjectList ?? [];
        _isLoading = false;
      });
    }
  }

  void _showFacultyPicker(Map<String, dynamic> exam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Assign Faculty',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _faculties.length,
                  itemBuilder: (context, i) {
                    final faculty = _faculties[i];
                    return ListTile(
                      title: Text(
                        faculty['name'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        final success = await _hodService.assignInvigilator(
                          exam['id'],
                          faculty['id'],
                        );
                        if (success) {
                          await _loadData();
                        } else {
                          setState(() => _isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to assign invigilator'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExamDialog() {
    String? selectedSubjectId;
    String selectedType = 'INTERNAL_1';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final locationCtrl = TextEditingController();

    if (_subjects.isNotEmpty) {
      selectedSubjectId = _subjects[0]['id'];
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF151B2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Exam',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SUBJECT',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D121F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E2A40)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubjectId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF151B2B),
                        style: const TextStyle(color: Colors.white),
                        items: _subjects
                            .map(
                              (s) => DropdownMenuItem(
                                value: s['id'] as String,
                                child: Text(s['name'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedSubjectId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TYPE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D121F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E2A40)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF151B2B),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(
                            value: 'INTERNAL_1',
                            child: Text('Internal 1'),
                          ),
                          DropdownMenuItem(
                            value: 'INTERNAL_2',
                            child: Text('Internal 2'),
                          ),
                          DropdownMenuItem(
                            value: 'INTERNAL_3',
                            child: Text('Internal 3'),
                          ),
                          DropdownMenuItem(
                            value: 'EXTERNAL',
                            child: Text('External'),
                          ),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => selectedType = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DATE',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null)
                                  setDialogState(() => selectedDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D121F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF1E2A40),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TIME',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (picked != null)
                                  setDialogState(() => selectedTime = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D121F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF1E2A40),
                                  ),
                                ),
                                child: Text(
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DialogField(
                    label: 'Location',
                    controller: locationCtrl,
                    hint: 'e.g. Lab 3, Block B',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A7AFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (selectedSubjectId != null) {
                              final data = {
                                'name': selectedType,
                                'subject_id': selectedSubjectId,
                                'exam_date': DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDate),
                                'exam_time':
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00',
                                'location': locationCtrl.text,
                              };

                              Navigator.pop(dialogContext);
                              setState(() => _isLoading = true);
                              final res = await _hodService.createExam(data);
                              if (res != null) {
                                await _loadData();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Exam schedule created successfully!',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                setState(() => _isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to create exam.'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text(
                            'Add Exam',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0D14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4DB6FF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF4DB6FF),
            size: 18,
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HODDashboardScreen()),
            (route) => false,
          ),
        ),
        title: const Text(
          'Exam Schedules',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Color(0xFF4DB6FF),
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExamDialog,
        backgroundColor: const Color(0xFF3A7AFF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Row ──
            Row(
              children: [
                Expanded(
                  child: _StatMiniCard(
                    label: 'TOTAL EXAMS',
                    value: _exams.length.toString().padLeft(2, '0'),
                    isHighlighted: false,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatMiniCard(
                    label: 'PENDING ASSIGN',
                    value: _exams
                        .where((e) => e['invigilator_name'] == null)
                        .length
                        .toString()
                        .padLeft(2, '0'),
                    isHighlighted: true,
                    showInfo: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ── Upcoming Schedule Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'UPCOMING SCHEDULE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            ...List.generate(_exams.length, (index) {
              final exam = _exams[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ExamCard(
                  data: {
                    ...exam,
                    'title':
                        exam['subject_name'] ?? exam['title'] ?? 'Unknown Exam',
                    'code': exam['subject_code'] ?? 'N/A',
                    'badge': 'UPCOMING',
                    'badgeColor': const Color(0xFF1D2230),
                    'badgeTextColor': const Color(0xFF8899BB),
                    'date': _formatDate(exam['exam_date'] ?? ''),
                    'time': exam['exam_time'] ?? 'TBA',
                    'location': exam['location'] ?? 'TBA',
                    'faculty': exam['invigilator_name'],
                    'buttonLabel': exam['invigilator_name'] == null
                        ? 'Manage Invigilation'
                        : 'Change Faculty',
                    'buttonIcon': Icons.people_alt_outlined,
                    'buttonStyle': exam['invigilator_name'] == null
                        ? 'filled'
                        : 'outlined',
                  },
                  onAssign: () => _showFacultyPicker(exam),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: const HodBottomNavBar(activeTab: HodTab.schedules),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Mini Card
// ─────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final bool showInfo;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.isHighlighted,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF2A5AA0)
              : const Color(0xFF1E2A40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showInfo) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3A7AFF),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Exam Card
// ─────────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onAssign;

  const _ExamCard({required this.data, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    final String? faculty = data['faculty'] as String?;
    final bool isFilled = data['buttonStyle'] == 'filled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2A40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  data['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data['badgeColor'] as Color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2A3450), width: 1),
                ),
                child: Text(
                  data['badge'] as String,
                  style: TextStyle(
                    color: data['badgeTextColor'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Course code tag ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2040),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              data['code'] as String,
              style: const TextStyle(
                color: Color(0xFF4DB6FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Date ──
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            text: data['date'] as String,
          ),
          const SizedBox(height: 8),

          // ── Time ──
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: data['time'] as String,
          ),
          const SizedBox(height: 8),

          // ── Location ──
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: data['location'] as String,
          ),

          // ── Assigned Faculty row (only for Database Systems card) ──
          if (faculty != null) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: const Color(0xFF1E2A40)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A221A),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFCFAA7E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSIGNED FACULTY',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      faculty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: onAssign,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3A7AFF), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'EDIT',
                    style: TextStyle(
                      color: Color(0xFF4DB6FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // ── Action Button ──
          SizedBox(
            width: double.infinity,
            height: 46,
            child: isFilled
                ? ElevatedButton.icon(
                    onPressed: onAssign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      data['buttonIcon'] as IconData,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      data['buttonLabel'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onAssign,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF3A7AFF),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      data['buttonIcon'] as IconData,
                      color: const Color(0xFF4DB6FF),
                      size: 18,
                    ),
                    label: Text(
                      data['buttonLabel'] as String,
                      style: const TextStyle(
                        color: Color(0xFF4DB6FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info Row (icon + text)
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4DB6FF), size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Dialog Field — used by the Add Exam dialog
// ─────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _DialogField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D121F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2A40)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
