import 'package:flutter/material.dart';

/// A stats card displayed at the top of User Management.
///
/// Shows a [title], a large [count], and a [subtitle] with an optional
/// live-pulse dot ([isLive]) or trending [icon].
class UserStatCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final Color subtitleColor;

  /// When true, renders a pulsing coloured dot instead of an icon.
  final bool isLive;
  final IconData? icon;

  const UserStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.subtitleColor,
    this.isLive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (isLive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: subtitleColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(icon, color: subtitleColor, size: 16),
              if (!isLive) const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
