import 'package:vidhya_sethu/Features/Staff/Widgets/attendance_summary_item.dart';
import 'package:flutter/material.dart';
import 'package:vidhya_sethu/Features/Staff/Models/student.dart';
import 'package:vidhya_sethu/Features/Staff/Models/subject.dart';
import '../Services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  List<Student> _students = [];
  List<Student> _filteredStudents = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final subjects = await _attendanceService.getSubjects();
    if (mounted) {
      if (subjects.isNotEmpty) {
        setState(() {
          _subjects = subjects;
          _selectedSubject = subjects.first;
        });
        await _loadStudentsForSubject(subjects.first.id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStudentsForSubject(String subjectId) async {
    setState(() => _isLoading = true);
    final students = await _attendanceService.getStudents(subjectId);

    // Default everyone to present if not set
    for (var s in students) {
      s.status = AttendanceStatus.present;
    }

    if (mounted) {
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((s) {
          final q = query.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.studentId.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedSubject == null || _students.isEmpty) return;

    setState(() => _isSaving = true);

    final records = _students
        .map(
          (s) => {
            'student_id': s.id,
            'status': s.status.toString().split('.').last.toUpperCase(),
          },
        )
        .toList();

    final success = await _attendanceService.submitAttendance(
      subjectId: _selectedSubject!.id,
      date: DateTime.now(),
      records: records,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Attendance Submitted' : 'Failed to submit attendance',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students
        .where((s) => s.status == AttendanceStatus.present)
        .length;
    int absentCount = _students
        .where((s) => s.status == AttendanceStatus.absent)
        .length;
    int pendingCount = _students
        .where((s) => s.status == AttendanceStatus.pending)
        .length;

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: _isLoading && _subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Section
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class Selector
                      if (_subjects.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Subject>(
                              isExpanded: true,
                              value: _selectedSubject,
                              items: _subjects.map((subj) {
                                return DropdownMenuItem(
                                  value: subj,
                                  child: Text(
                                    subj.name,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedSubject = val;
                                  });
                                  _loadStudentsForSubject(val.id);
                                }
                              },
                            ),
                          ),
                        )
                      else
                        const Text("No subjects found."),
                      const SizedBox(height: 12),

                      // Date and Active Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Active Session",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      TextField(
                        onChanged: _filterStudents,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Theme.of(context).hintColor,
                          ),
                          hintText: "Search student name or ID...",
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Student Stats Header
                      Row(
                        children: [
                          Text(
                            "Students",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${_filteredStudents.length} Total",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var s in _students) {
                                  s.status = AttendanceStatus.present;
                                }
                              });
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text("All Present"),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredStudents.isEmpty
                      ? const Center(child: Text('No students found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return _StudentAttendanceCard(
                              student: student,
                              onStatusChanged: (status) {
                                setState(() {
                                  student.status = status;
                                });
                              },
                            );
                          },
                        ),
                ),

                // Bottom Sheet
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 600
                        ? 40
                        : 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            AttendanceSummaryItem(
                              label: 'PRESENT',
                              count: presentCount,
                              countColor: Theme.of(context).colorScheme.primary,
                            ),
                            AttendanceSummaryItem(
                              label: 'ABSENT',
                              count: absentCount,
                              countColor: Colors.redAccent,
                            ),
                            AttendanceSummaryItem(
                              label: 'PENDING',
                              count: pendingCount,
                              countColor:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color ??
                                  Colors.white54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submitAttendance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Submit Attendance",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
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

class _StudentAttendanceCard extends StatelessWidget {
  final Student student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentAttendanceCard({
    required this.student,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage:
                null, // Removed missing assets/profile_placeholder.png
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.3),
            child: student.name.isNotEmpty
                ? Text(
                    student.name[0],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          // Name & ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "ID: ${student.studentId}",
                  style: TextStyle(
                    color: isDark
                        ? Colors.grey[400]
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Status Toggles
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatusButton(
                  context,
                  AttendanceStatus.present,
                  "P",
                  Theme.of(context).colorScheme.primary,
                ),
                _buildStatusButton(
                  context,
                  AttendanceStatus.absent,
                  "A",
                  Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    AttendanceStatus status,
    String label,
    Color color,
  ) {
    bool isSelected = student.status == status;
    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: Container(
        width: 40,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Theme.of(context).textTheme.bodyMedium?.color),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
