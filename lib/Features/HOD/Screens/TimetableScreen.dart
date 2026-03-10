import 'package:vidhya_sethu/Features/HOD/Services/hod_service.dart';
import 'package:vidhya_sethu/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:vidhya_sethu/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final HODService _hodService = HODService();
  bool _isLoading = true;
  int _selectedDay = 0; // MON = 0
  List<Map<String, dynamic>> _slots = [];

  static const List<Map<String, String>> _days = [
    {'label': 'MON', 'api': 'MONDAY', 'date': '12'},
    {'label': 'TUE', 'api': 'TUESDAY', 'date': '13'},
    {'label': 'WED', 'api': 'WEDNESDAY', 'date': '14'},
    {'label': 'THU', 'api': 'THURSDAY', 'date': '15'},
    {'label': 'FRI', 'api': 'FRIDAY', 'date': '16'},
    {'label': 'SAT', 'api': 'SATURDAY', 'date': '17'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);
    final dayApi = _days[_selectedDay]['api']!;
    final data = await _hodService.getTimetable(day: dayApi);

    if (mounted) {
      setState(() {
        _slots = data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hodBackground,
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: AppColors.hodBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A6A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF4DB6FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Timetable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Day Selector ──
          _buildDaySelector(),
          const SizedBox(height: 6),

          // ── Schedule Timeline ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4DB6FF)),
                  )
                : _slots.isEmpty
                ? const Center(
                    child: Text(
                      'No classes scheduled for this day.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (context, i) {
                      final slot = _slots[i];
                      final isLast = i == _slots.length - 1;

                      // Mock/derive visual fields not in backend yet
                      final uiData = {
                        'time': slot['start_time'],
                        'title': slot['subject_name'] ?? 'Unknown',
                        'badge': 'LECTURE', // Default
                        'badgeColor': const Color(0xFF1D2230),
                        'badgeBorder': const Color(0xFF2A3450),
                        'badgeTextColor': const Color(0xFF8899BB),
                        'teacher':
                            'Department Faculty', // Placeholder until staff-subject mapping is clearer in this view
                        'location': slot['room'] ?? 'TBD',
                        'locationIcon': Icons.location_on_outlined,
                        'isCurrent':
                            false, // Logic to check current time could be added
                        'attendance': null,
                      };

                      return _TimelineSlot(slot: uiData, isLast: isLast);
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: const HodBottomNavBar(activeTab: HodTab.schedules),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _days.length,
        itemBuilder: (context, i) {
          final bool active = i == _selectedDay;
          final day = _days[i];
          return GestureDetector(
            onTap: () {
              if (_selectedDay != i) {
                setState(() => _selectedDay = i);
                _loadTimetable();
              }
            },
            child: Container(
              width: 62,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF3A7AFF)
                    : const Color(0xFF151B2B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? const Color(0xFF5B9AFF) : AppColors.hodBorder,
                  width: 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.hodAccentBlue.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day['label']!,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day['date']!,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Timeline Slot Row
// ─────────────────────────────────────────────
class _TimelineSlot extends StatelessWidget {
  final Map<String, dynamic> slot;
  final bool isLast;

  const _TimelineSlot({required this.slot, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = slot['isCurrent'] as bool;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Time + line column ──
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  slot['time'] as String,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFF4DB6FF) : Colors.white38,
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Center(
                    child: Container(width: 2, color: AppColors.hodBorder),
                  ),
                ),
              ],
            ),
          ),

          // ── Dot indicator ──
          Column(
            children: [
              const SizedBox(height: 2),
              Container(
                width: isCurrent ? 10 : 8,
                height: isCurrent ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? const Color(0xFF4DB6FF)
                      : const Color(0xFF1E2A40),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF4DB6FF)
                        : const Color(0xFF2A3450),
                    width: 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4DB6FF).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // ── Card ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SlotCard(slot: slot, isCurrent: isCurrent),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slot Card
// ─────────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final bool isCurrent;

  const _SlotCard({required this.slot, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final String? attendance = slot['attendance'] as String?;
    final Color badgeColor = slot['badgeColor'] as Color;
    final Color badgeBorder = slot['badgeBorder'] as Color;
    final Color badgeTextColor = slot['badgeTextColor'] as Color;
    final String badge = slot['badge'] as String;
    final IconData locIcon = slot['locationIcon'] as IconData;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.hodSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFF2A4070) : const Color(0xFF1E2A40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  slot['title'] as String,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFF4DB6FF) : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeBorder, width: 1),
                ),
                child: Text(
                  badge,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Teacher
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                slot['teacher'] as String,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Location
          Row(
            children: [
              Icon(locIcon, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                slot['location'] as String,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          // Attendance (only for current / lab slot)
          if (attendance != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.hodBorder, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'ATTENDANCE',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  attendance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
