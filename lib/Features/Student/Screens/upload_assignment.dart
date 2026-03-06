import 'package:college_management/Features/Student/Services/student_service.dart';
import 'package:flutter/material.dart';

/// Displays the student's pending and submitted assignments.
///
/// Uses the student assignments endpoint which returns all assignments for
/// the student's course. The pending/submitted split is determined by
/// whether there is already a submission from the current student.
class UploadAssignmentPage extends StatefulWidget {
  const UploadAssignmentPage({super.key});

  @override
  State<UploadAssignmentPage> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<UploadAssignmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingAssignments = [];
  List<Map<String, dynamic>> _completedAssignments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final assignments = await StudentService().fetchAssignments();
      final pending = <Map<String, dynamic>>[];
      final completed = <Map<String, dynamic>>[];

      for (final a in assignments) {
        // Backend includes a 'submissions' list on each assignment.
        // If any submission exists for this assignment, it is completed.
        final submissions = a['submissions'] as List?;
        if (submissions != null && submissions.isNotEmpty) {
          completed.add(a);
        } else {
          pending.add(a);
        }
      }

      if (mounted) {
        setState(() {
          _pendingAssignments = pending;
          _completedAssignments = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load assignments.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2F80ED),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2F80ED),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAssignments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAssignmentList(_pendingAssignments, isPending: true),
                _buildAssignmentList(_completedAssignments, isPending: false),
              ],
            ),
    );
  }

  Widget _buildAssignmentList(
    List<Map<String, dynamic>> assignments, {
    required bool isPending,
  }) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isPending
                  ? 'All caught up! No pending assignments.'
                  : 'No submissions yet.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildAssignmentCard(assignments[index], isPending: isPending);
      },
    );
  }

  Widget _buildAssignmentCard(
    Map<String, dynamic> item, {
    required bool isPending,
  }) {
    final title = item['title'] as String? ?? 'Untitled Assignment';
    final course = item['target_course'] as String? ?? 'Unknown Course';
    final description = item['description'] as String? ?? '';
    final dueDateStr = item['due_date'] as String?;

    String dueLabel = 'No due date';
    if (dueDateStr != null && dueDateStr.isNotEmpty) {
      try {
        final dueDate = DateTime.parse(dueDateStr).toLocal();
        dueLabel = 'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}';
      } catch (_) {
        dueLabel = 'Due: $dueDateStr';
      }
    }

    final accentColor = isPending ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.assignment, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Submitted',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(description, style: TextStyle(color: Colors.grey[800])),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isPending ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                dueLabel,
                style: TextStyle(
                  color: isPending ? Colors.orange : Colors.grey,
                  fontWeight: isPending ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (isPending)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement file upload via /student/assignments/{id}/submit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File upload coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
