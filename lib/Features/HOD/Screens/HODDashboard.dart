import 'package:vidhya_sethu/Features/HOD/Screens/AnnouncementsScreen.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/ExamSchedulesScreen.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/OnDutyListScreen.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/PostResultsScreen.dart';
import 'package:vidhya_sethu/Features/HOD/Screens/TimetableScreen.dart';
import 'package:vidhya_sethu/Features/HOD/Services/hod_service.dart';
import 'package:vidhya_sethu/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:vidhya_sethu/core/constants/app_colors.dart';
import 'package:vidhya_sethu/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class HODDashboardScreen extends StatefulWidget {
  const HODDashboardScreen({super.key});

  @override
  State<HODDashboardScreen> createState() => _HODDashboardScreenState();
}

class _HODDashboardScreenState extends State<HODDashboardScreen> {
  final HODService _hodService = HODService();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String _userName = 'HOD';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _hodService.getDashboardData();
    if (mounted) {
      setState(() {
        _userName = data?['hod_name'] ?? 'HOD';
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.hodBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.hodNavActive),
        ),
      );
    }

    final data = _dashboardData;
    final deptName = data?['department_name'] ?? 'UNKNOWN DEPARTMENT';
    final totalStudents = data?['total_students']?.toString() ?? '0';
    final totalFaculty = data?['total_faculty']?.toString() ?? '0';
    final attendanceData = (data?['attendance_data'] as List<dynamic>?) ?? [];
    final facultyOnDuty = (data?['faculty_on_duty'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.hodBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPaddingH,
                  vertical: AppSizes.screenPaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HODHeader(userName: _userName),
                    const SizedBox(height: AppSizes.spaceXs),
                    _DepartmentLabel(departmentName: deptName),
                    const SizedBox(height: AppSizes.spaceLg),
                    _StatsRow(students: totalStudents, faculty: totalFaculty),
                    const SizedBox(height: AppSizes.spaceLg),
                    _AttendanceCard(attendanceData: attendanceData),
                    const SizedBox(height: AppSizes.spaceXl),
                    _FacultyOnDutySection(facultyOnDuty: facultyOnDuty),
                    const SizedBox(height: AppSizes.spaceXl),
                    const _QuickActionsSection(),
                    const SizedBox(height: AppSizes.spaceLg),
                  ],
                ),
              ),
            ),
            const HodBottomNavBar(activeTab: HodTab.home),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _HODHeader extends StatelessWidget {
  final String userName;
  const _HODHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E2A3A),
            border: Border.all(color: const Color(0xFF2A3F5A), width: 2),
          ),
          child: ClipOval(
            child: Icon(Icons.person, size: 32, color: Colors.blueGrey[200]),
          ),
        ),
        const SizedBox(width: 12),
        // Name & role
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'HEAD OF DEPARTMENT',
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Bell icon
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF181E2E),
            border: Border.all(color: const Color(0xFF2A3450), width: 1.5),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Department Label
// ─────────────────────────────────────────────
class _DepartmentLabel extends StatelessWidget {
  final String departmentName;
  const _DepartmentLabel({required this.departmentName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.school_outlined, color: Colors.blue[300], size: 16),
        const SizedBox(width: 8),
        Text(
          departmentName,
          style: TextStyle(
            color: Colors.blue[300],
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Stats Row (Students + Faculty)
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final String students;
  final String faculty;
  const _StatsRow({required this.students, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_outlined,
            label: 'STUDENTS',
            value: students,
            sub: 'Enrolled',
            subColor: const Color(0xFF4DB6FF),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.badge_outlined,
            label: 'FACULTY',
            value: faculty,
            sub: 'Active',
            subColor: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color subColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.hodSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.hodBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[400], size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sub,
                style: TextStyle(
                  color: subColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Attendance Card
// ─────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final List<dynamic> attendanceData;
  const _AttendanceCard({required this.attendanceData});

  @override
  Widget build(BuildContext context) {
    final activeDay = attendanceData.firstWhere(
      (day) => day['active'] == true,
      orElse: () => null,
    );
    final activePercentage = activeDay != null
        ? '${(activeDay['value'] * 100).toInt()}%'
        : '--';
    final activeLabel = activeDay != null ? activeDay['label'] : '--';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.hodSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.hodBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Daily Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Weekly Department Performance',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activePercentage,
                    style: const TextStyle(
                      color: AppColors.hodNavActive,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activeLabel,
                      style: const TextStyle(
                        color: AppColors.hodNavActive,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: attendanceData.map((day) {
                final bool active = day['active'] as bool;
                final double val = (day['value'] as num).toDouble();
                return _AttendanceBar(
                  label: day['label'] as String,
                  heightFactor: val,
                  isActive: active,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBar extends StatelessWidget {
  final String label;
  final double heightFactor;
  final bool isActive;

  const _AttendanceBar({
    required this.label,
    required this.heightFactor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background track
              Container(
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Filled bar
              FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.hodNavActive
                        : const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.hodNavActive.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.hodNavActive : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Faculty On Duty Section
// ─────────────────────────────────────────────
class _FacultyOnDutySection extends StatelessWidget {
  final List<dynamic> facultyOnDuty;
  const _FacultyOnDutySection({required this.facultyOnDuty});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Faculty On Duty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnDutyListScreen()),
              ),
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: facultyOnDuty.length + 1,
            itemBuilder: (context, index) {
              if (index == facultyOnDuty.length) {
                return const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: _AddDutyCard(),
                );
              }
              final faculty = facultyOnDuty[index];
              final isEven = index % 2 == 0;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                child: _FacultyCard(
                  name: faculty['name'],
                  role: faculty['role'],
                  roleColor: isEven
                      ? const Color(0xFF3A7AFF)
                      : const Color(0xFFB87333),
                  bgColor: const Color(0xFF1A2236),
                  avatarColor: isEven
                      ? const Color(0xFF3D2B1F)
                      : const Color(0xFF2B3420),
                  iconColor: isEven
                      ? const Color(0xFFD4A07A)
                      : const Color(0xFFD4C07A),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final String name;
  final String role;
  final Color roleColor;
  final Color bgColor;
  final Color avatarColor;
  final Color iconColor;

  const _FacultyCard({
    required this.name,
    required this.role,
    required this.roleColor,
    required this.bgColor,
    required this.avatarColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hodBorder, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Icon(Icons.person, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: roleColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: roleColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddDutyCard extends StatelessWidget {
  const _AddDutyCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnDutyListScreen()),
      ),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.hodBorder, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3A5F),
                border: Border.all(color: const Color(0xFF2A5080), width: 1.5),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.hodNavActive,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Du...',
              style: TextStyle(
                color: AppColors.hodNavActive,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Actions Section
// ─────────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        // 2x2 grid
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.campaign_outlined,
                label: 'ANNOUNCEMENTS',
                isHighlighted: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.calendar_today_outlined,
                label: 'EXAM SCHEDULES',
                isHighlighted: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExamSchedulesScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.table_chart_outlined,
                label: 'TIME TABLE',
                isHighlighted: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimetableScreen()),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.check_box_outlined,
                label: 'INTERNAL RESULTS',
                isHighlighted: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostResultsScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;

  final VoidCallback? onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.isHighlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.hodAccentBlue : AppColors.hodSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF5B9AFF)
                : AppColors.hodBorder,
            width: 1,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.hodAccentBlue.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isHighlighted ? Colors.white : AppColors.hodNavActive,
              size: 26,
            ),
            Text(
              label,
              style: TextStyle(
                color: isHighlighted ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
