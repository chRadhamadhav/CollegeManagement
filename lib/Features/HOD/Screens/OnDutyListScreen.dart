import 'package:college_management/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:college_management/Features/HOD/Services/hod_service.dart';
import 'package:flutter/material.dart';

class OnDutyListScreen extends StatefulWidget {
  const OnDutyListScreen({super.key});

  @override
  State<OnDutyListScreen> createState() => _OnDutyListScreenState();
}

class _OnDutyListScreenState extends State<OnDutyListScreen> {
  final HODService _hodService = HODService();
  bool _isLoading = true;
  int _selectedDay = 0;

  List<Map<String, dynamic>> _assignments = [];

  static const List<Map<String, String>> _days = [
    {'label': 'TODAY', 'date': '12'},
    {'label': 'TUE', 'date': '13'},
    {'label': 'WED', 'date': '14'},
    {'label': 'THU', 'date': '15'},
    {'label': 'FRI', 'date': '16'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDutyList();
  }

  Future<void> _loadDutyList() async {
    setState(() => _isLoading = true);
    final data = await _hodService.getFacultyDuty();
    if (mounted) {
      setState(() {
        _assignments = data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
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
                Icons.badge_outlined,
                color: Color(0xFF4DB6FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'On Duty List',
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
            icon: const Icon(Icons.search, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4DB6FF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Day Selector ──
                  _buildDaySelector(),
                  const SizedBox(height: 20),

                  // ── Active Assignments Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE ASSIGNMENTS (${_assignments.length})',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'View Map',
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Assignment Cards ──
                  if (_assignments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No faculty on duty today.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ..._assignments.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AssignmentCard(apiData: a),
                      ),
                    ),
                ],
              ),
            ),

      bottomNavigationBar: const HodBottomNavBar(activeTab: HodTab.faculty),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, i) {
          final bool active = i == _selectedDay;
          final day = _days[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: Container(
              width: 66,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF3A7AFF)
                    : const Color(0xFF151B2B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? const Color(0xFF5B9AFF)
                      : const Color(0xFF1E2A40),
                  width: 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3A7AFF).withOpacity(0.35),
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
                      fontSize: active ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
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
// Assignment Card
// ─────────────────────────────────────────────
class _AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> apiData;

  const _AssignmentCard({required this.apiData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2A40), width: 1),
      ),
      child: Column(
        children: [
          // ── Top: Avatar + Name + Status + Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A2B3A),
                  border: Border.all(
                    color: const Color(0xFF2A3F5A),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF4DB6FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Name + Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiData['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Green dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4CAF82),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF82).withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          apiData['status'] ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent, // data['badgeBg']
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4DB6FF), // data['badgeBorderColor']
                    width: 1,
                  ),
                ),
                child: Text(
                  apiData['badge'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF4DB6FF), // data['badgeTextColor']
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Divider ──
          Container(height: 1, color: const Color(0xFF1E2A40)),
          const SizedBox(height: 14),

          // ── Time Slot + Location ──
          Row(
            children: [
              // Time Slot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIME SLOT',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF4DB6FF),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          apiData['timeSlot'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFF1E2A40),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOCATION',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF4DB6FF),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            apiData['location'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Contact + Change Buttons ──
          Row(
            children: [
              // Contact button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      'Contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Change button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF2A3450),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
