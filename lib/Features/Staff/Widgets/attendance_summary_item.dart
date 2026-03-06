import 'package:flutter/material.dart';

/// A single label+count column in the attendance submission footer.
///
/// Used for PRESENT / ABSENT / PENDING summary counts.
class AttendanceSummaryItem extends StatelessWidget {
  final String label;
  final int count;
  final Color countColor;

  const AttendanceSummaryItem({
    super.key,
    required this.label,
    required this.count,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString().padLeft(2, '0'),
          style: TextStyle(
            color: countColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
