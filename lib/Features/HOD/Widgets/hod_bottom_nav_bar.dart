import 'package:college_management/Features/HOD/Screens/AnnouncementsScreen.dart';
import 'package:college_management/Features/HOD/Screens/ExamSchedulesScreen.dart';
import 'package:college_management/Features/HOD/Screens/HODDashboard.dart';
import 'package:college_management/Features/HOD/Screens/HODProfileScreen.dart';
import 'package:college_management/Features/HOD/Screens/OnDutyListScreen.dart';
import 'package:college_management/core/constants/app_colors.dart';
import 'package:college_management/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

/// Identifies which HOD tab is currently active.
/// Used by [HodBottomNavBar] to highlight the correct item and suppress its
/// tap — preventing redundant navigation to the current screen.
enum HodTab { home, schedules, announcements, faculty, profile }

/// Shared bottom navigation bar for all HOD screens.
///
/// Pass the [activeTab] matching the current screen so the correct item is
/// highlighted. Navigation to the active tab's screen is automatically
/// suppressed (no-op tap).
class HodBottomNavBar extends StatelessWidget {
  final HodTab activeTab;

  const HodBottomNavBar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.hodNavBackground,
        border: Border(
          top: BorderSide(color: AppColors.hodNavBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _HodNavItem(
            icon: Icons.grid_view_rounded,
            label: 'HOME',
            isActive: activeTab == HodTab.home,
            onTap: activeTab == HodTab.home
                ? null
                : () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HODDashboardScreen(),
                    ),
                    (route) => false,
                  ),
          ),
          _HodNavItem(
            icon: Icons.calendar_today_outlined,
            label: 'SCHEDULES',
            isActive: activeTab == HodTab.schedules,
            onTap: activeTab == HodTab.schedules
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExamSchedulesScreen(),
                    ),
                  ),
          ),
          _HodNavItem(
            icon: Icons.campaign_outlined,
            label: 'ANNOUNCE',
            isActive: activeTab == HodTab.announcements,
            onTap: activeTab == HodTab.announcements
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen(),
                    ),
                  ),
          ),
          _HodNavItem(
            icon: Icons.people_alt_outlined,
            label: 'FACULTY',
            isActive: activeTab == HodTab.faculty,
            onTap: activeTab == HodTab.faculty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnDutyListScreen()),
                  ),
          ),
          _HodNavItem(
            icon: Icons.account_circle_outlined,
            label: 'PROFILE',
            isActive: activeTab == HodTab.profile,
            onTap: activeTab == HodTab.profile
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HODProfileScreen()),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A single item in [HodBottomNavBar].
class _HodNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _HodNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.hodNavActive : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSizes.hodNavIconSize),
          const SizedBox(height: AppSizes.spaceXxs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.hodNavLabelSize,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
