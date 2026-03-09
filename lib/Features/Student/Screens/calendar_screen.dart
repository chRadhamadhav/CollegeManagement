import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StudentService _studentService = StudentService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _studentService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  // Groups events by Month and Year, e.g. "October 2026"
  Map<String, List<Map<String, dynamic>>> _groupEventsByMonth() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var event in _events) {
      final dateStr = event['event_date'] as String;
      final date = DateTime.parse(dateStr);
      final monthYear = DateFormat('MMMM yyyy').format(date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(event);
    }
    return grouped;
  }

  Color _getColorForEventType(String type) {
    switch (type) {
      case 'Academic':
        return Colors.redAccent;
      case 'Extracurricular':
        return Colors.purple;
      case 'Holiday':
        return Colors.green;
      case 'Deadline':
        return Colors.orange;
      case 'Admin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light background like dashboard
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No upcoming events",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final groupedEvents = _groupEventsByMonth();
    final sortedMonths = groupedEvents.keys.toList();
    // Assuming events are already sorted ascending by DB

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Important Dates",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${sortedMonths.first} - ${sortedMonths.last}",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          ...sortedMonths.map((monthStr) {
            final monthEvents = groupedEvents[monthStr]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthStr.split(' ')[0], // Just the month name
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                ...monthEvents.map((event) {
                  final date = DateTime.parse(event['event_date']);
                  final type = event['event_type'] ?? 'Academic';
                  final title = event['title'] ?? 'Event';

                  // Format time or use 'All Day'
                  String timeStr = "All Day";
                  if (event['event_time'] != null) {
                    final timeParts = event['event_time'].split(':');
                    if (timeParts.length >= 2) {
                      final hour = int.tryParse(timeParts[0]) ?? 0;
                      final min = timeParts[1];
                      final ampm = hour >= 12 ? 'PM' : 'AM';
                      final displayHour = hour > 12
                          ? hour - 12
                          : (hour == 0 ? 12 : hour);
                      timeStr =
                          "${displayHour.toString().padLeft(2, '0')}:$min $ampm";
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildEventCard(
                      date: DateFormat('dd MMM').format(date),
                      title: title,
                      time: timeStr,
                      type: type,
                      color: _getColorForEventType(type),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String date,
    required String title,
    required String time,
    required String type,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  date.split(' ')[1],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
