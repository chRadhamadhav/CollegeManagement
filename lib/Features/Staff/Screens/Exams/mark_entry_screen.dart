import 'package:vidhya_sethu/Features/Staff/Models/student.dart';
import 'package:vidhya_sethu/Features/Staff/Models/exam.dart';
import 'package:vidhya_sethu/Features/Staff/Models/exam_mark.dart';
import 'package:flutter/material.dart';

import '../../Services/exam_service.dart';

class MarkEntryScreen extends StatefulWidget {
  final Exam exam;

  const MarkEntryScreen({super.key, required this.exam});

  @override
  State<MarkEntryScreen> createState() => _MarkEntryScreenState();
}

class _MarkEntryScreenState extends State<MarkEntryScreen> {
  final ExamService _examService = ExamService();
  List<Student> _students = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _absentStatus = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _examService.getStudents(widget.exam.subjectId),
      _examService.getMarks(widget.exam.id),
    ]);

    final studentsList = results[0] as List<Student>;
    final existingMarks = results[1] as List<ExamMark>;

    if (mounted) {
      setState(() {
        _students = studentsList;
        for (var student in _students) {
          // find mark for this student (using student.id matching existingMarks studentId)
          final mark = existingMarks
              .where((m) => m.studentId == student.id)
              .firstOrNull;
          _controllers[student.id] = TextEditingController(
            text: mark != null ? mark.marksObtained.toString() : '',
          );
          _absentStatus[student.id] = mark?.isAbsent ?? false;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAllMarks() async {
    if (_students.isEmpty) return;
    setState(() => _isSaving = true);

    List<ExamMark> marksToSave = [];
    bool hasValidationError = false;

    for (var student in _students) {
      final controller = _controllers[student.id];
      final isAbsent = _absentStatus[student.id] ?? false;

      double marks = double.tryParse(controller?.text ?? '') ?? 0.0;

      if (!isAbsent && marks > widget.exam.maxMarks) {
        hasValidationError = true;
        break;
      }

      marksToSave.add(
        ExamMark(
          id: '',
          examId: widget.exam.id,
          studentId: student.id,
          marksObtained: isAbsent ? 0.0 : marks,
          isAbsent: isAbsent,
        ),
      );
    }

    if (hasValidationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marks cannot exceed ${widget.exam.maxMarks} for any student',
          ),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final success = await _examService.saveMarksBulk(
      widget.exam.id,
      marksToSave,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'All marks saved successfully' : 'Failed to save marks',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exam.name} Marks'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_as),
              tooltip: 'Save All',
              onPressed: _saveAllMarks,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? const Center(child: Text('No students found for this subject.'))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max: ${widget.exam.maxMarks}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pass: ${widget.exam.passingMarks}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _students.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final isAbsent = _absentStatus[student.id] ?? false;
                      final controller = _controllers[student.id];

                      return _StudentMarkCard(
                        student: student,
                        isAbsent: isAbsent,
                        controller: controller,
                        onAbsentChanged: (val) {
                          setState(() {
                            _absentStatus[student.id] = val ?? false;
                            if (val == true) {
                              _controllers[student.id]?.text = '0.0';
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _StudentMarkCard extends StatelessWidget {
  final Student student;
  final bool isAbsent;
  final TextEditingController? controller;
  final ValueChanged<bool?> onAbsentChanged;

  const _StudentMarkCard({
    required this.student,
    required this.isAbsent,
    required this.controller,
    required this.onAbsentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Student Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  student.studentId,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Actions Row (Abs, Marks)
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Absent Checkbox
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Abs', style: TextStyle(fontSize: 12)),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: isAbsent,
                        onChanged: onAbsentChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Mark Input
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    enabled: !isAbsent,
                    decoration: InputDecoration(
                      labelText: 'Marks',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: isDark,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
