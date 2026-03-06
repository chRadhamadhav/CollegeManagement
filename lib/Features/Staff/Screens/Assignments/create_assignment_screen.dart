import 'package:college_management/Features/Staff/Models/assignment.dart';
import 'package:flutter/material.dart';
import '../../Services/assignment_service.dart';
import '../../Services/timetable_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  String? _selectedCourse;
  List<String> _availableCourses = [];

  final TimetableService _timetableService = TimetableService();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courses = await _timetableService.fetchCourses();
    setState(() {
      _availableCourses = courses;
    });
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveAssignment() async {
    if (_formKey.currentState!.validate()) {
      final newAssignment = Assignment(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        course: _selectedCourse!,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
      );

      final success = await AssignmentService().createAssignment(newAssignment);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Assignment Created!')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create assignment.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assignment'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAssignment),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment Title',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Assignment Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCourse,
              decoration: const InputDecoration(
                labelText: 'Target Course / Group',
                border: OutlineInputBorder(),
              ),
              items: _availableCourses.map((String course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCourse = newValue;
                });
              },
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat.yMMMd().format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: () => _selectDueDate(context),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAssignment,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('CREATE ASSIGNMENT'),
            ),
          ],
        ),
      ),
    );
  }
}
