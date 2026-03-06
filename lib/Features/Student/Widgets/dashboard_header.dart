import 'package:flutter/material.dart';

/// Header row displayed at the top of the student dashboard.
///
/// Shows the student's avatar, greeting message, name, and a notification bell.
/// Data is currently hardcoded — wire to a student model/provider later.
class DashboardHeader extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final String _baseUrl = 'http://127.0.0.1:8000';

  const DashboardHeader({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    final name = profileData?['full_name'] ?? 'Student';
    final avatarUrl = profileData?['avatar_url'];
    return Row(
      children: [
        avatarUrl != null && avatarUrl.isNotEmpty
            ? CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('$_baseUrl$avatarUrl'),
              )
            : CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2F80ED),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              name.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.black87),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
