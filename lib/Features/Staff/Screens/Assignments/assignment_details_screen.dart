import 'package:college_management/Features/Staff/Models/assignment.dart';
import 'package:college_management/Features/Staff/Models/assignment_submission.dart';
import 'package:flutter/material.dart';
import '../../Services/assignment_service.dart';
import 'package:intl/intl.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  final Assignment assignment;

  const AssignmentDetailsScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  final AssignmentService _assignmentService = AssignmentService();
  late List<AssignmentSubmission> _submissions;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final subs = await _assignmentService.getSubmissionsForAssignment(
      widget.assignment.id,
    );
    if (mounted) {
      setState(() {
        _submissions = subs;
        _isLoading = false;
      });
    }
  }

  void _gradeSubmission(AssignmentSubmission submission) {
    final marksController = TextEditingController(
      text: submission.marksAwarded?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grade Submission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Marks Awarded'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: feedbackController,
                decoration: const InputDecoration(labelText: 'Feedback'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final marks = int.tryParse(marksController.text);
                if (marks != null) {
                  setState(() {
                    _assignmentService.gradeSubmission(
                      submission.id,
                      marks,
                      feedbackController.text,
                    );
                    _loadData();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assignment.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${widget.assignment.course}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Due Date: ${DateFormat.yMMMd().format(widget.assignment.dueDate)}',
            ),
            const SizedBox(height: 12),
            Text(widget.assignment.description),
            const SizedBox(height: 24),
            const Text(
              'Submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_submissions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No submissions yet.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              ..._submissions.map((sub) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      child: Text(
                        sub.studentName.isNotEmpty
                            ? sub.studentName.substring(0, 1)
                            : '?',
                      ),
                    ),
                    title: Text(
                      sub.studentName.isNotEmpty
                          ? sub.studentName
                          : 'Unknown Student',
                    ),
                    subtitle: Text(
                      sub.marksAwarded != null
                          ? 'Graded: ${sub.marksAwarded} Marks\nFeedback: ${sub.feedback}'
                          : 'Submitted: ${DateFormat.yMd().add_jm().format(sub.submittedAt)}',
                      style: TextStyle(
                        color: sub.marksAwarded != null
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: sub.marksAwarded != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => _gradeSubmission(sub),
                      child: const Text('Grade'),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
