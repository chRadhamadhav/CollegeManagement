import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';
import 'package:flutter/material.dart';

/// Shows the student's weekly class timetable, fetched live from the backend.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> _slots = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    try {
      final data = await StudentService().fetchTimetable();
      if (mounted) {
        setState(() {
          _slots = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load timetable.';
          _isLoading = false;
        });
      }
    }
  }

  /// Groups the flat list of slots by day of week for ordered display.
  Map<String, List<Map<String, dynamic>>> _groupByDay(
    List<Map<String, dynamic>> slots,
  ) {
    const orderedDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final day in orderedDays) {
      final daySlots = slots.where((s) => s['day_of_week'] == day).toList()
        ..sort((a, b) {
          final aTime = a['start_time'] as String? ?? '';
          final bTime = b['start_time'] as String? ?? '';
          return aTime.compareTo(bTime);
        });
      if (daySlots.isNotEmpty) {
        grouped[day] = daySlots;
      }
    }
    return grouped;
  }

  static const List<Color> _slotColors = [
    Colors.blue,
    Colors.teal,
    Colors.purple,
    Colors.orange,
    Colors.redAccent,
    Colors.green,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  Color _colorForSubject(String subjectId) {
    return _slotColors[subjectId.hashCode.abs() % _slotColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadTimetable();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_slots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No timetable entries yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(_slots);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        for (final entry in grouped.entries) ...[
          _buildDayHeader(entry.key),
          const SizedBox(height: 12),
          for (final slot in entry.value) ...[
            _buildClassCard(slot),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildDayHeader(String day) {
    return Text(
      day[0].toUpperCase() + day.substring(1),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> slot) {
    final color = _colorForSubject(slot['subject_id'] as String? ?? '');
    final subjectName = slot['subject_name'] as String? ?? 'Unknown Subject';
    final subjectCode = slot['subject_code'] as String? ?? '';
    final room = slot['room'] as String? ?? 'TBA';
    // Format time: "09:00:00" → "09:00 AM"
    final startTime = _formatTime(slot['start_time'] as String? ?? '');
    final endTime = _formatTime(slot['end_time'] as String? ?? '');

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
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subjectCode.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subjectCode,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$startTime – $endTime',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts "HH:MM:SS" to "HH:MM AM/PM".
  String _formatTime(String time) {
    if (time.isEmpty) return '';
    try {
      final parts = time.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts[1];
      final suffix = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $suffix';
    } catch (_) {
      return time;
    }
  }
}
