import 'package:flutter/material.dart';

/// Displays the currently live or upcoming class card on the Staff dashboard.
///
/// TODO: Replace hardcoded fields with a [ScheduleClass] model once the
/// timetable service is wired up.
class TodayClassCard extends StatelessWidget {
  final Map<String, dynamic>? classData;

  const TodayClassCard({super.key, this.classData});

  @override
  Widget build(BuildContext context) {
    if (classData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No upcoming classes.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    }

    final subjectName = classData!['subject_name'] ?? 'Unknown Subject';
    final room = classData!['room'] ?? 'TBA';
    final startTime = classData!['start_time'] ?? '';
    final endTime = classData!['end_time'] ?? '';
    final timeStr = "$startTime - $endTime";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Live Now',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subjectName,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Room $room',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          // TODO: Backend — replace hardcoded class data with API response
        ],
      ),
    );
  }
}
