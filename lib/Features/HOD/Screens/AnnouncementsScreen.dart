import 'package:college_management/Features/HOD/Screens/HODDashboard.dart';
import 'package:college_management/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:college_management/Features/HOD/Services/hod_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final HODService _hodService = HODService();
  bool _isLoading = true;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = ['All', 'Faculty Only', 'Students'];
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    final data = await _hodService.getAnnouncements();
    if (mounted) {
      setState(() {
        _announcements = data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    final success = await _hodService.deleteAnnouncement(id);
    if (success) {
      _loadAnnouncements();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete announcement')),
        );
      }
    }
  }

  void _showAddAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF151B2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _DialogField(
                  label: 'Title',
                  controller: titleCtrl,
                  hint: 'e.g. Exam Update',
                ),
                const SizedBox(height: 12),
                _DialogField(
                  label: 'Body',
                  controller: bodyCtrl,
                  hint: 'Enter details...',
                  isMultiline: true,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A7AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (titleCtrl.text.isNotEmpty &&
                              bodyCtrl.text.isNotEmpty) {
                            Navigator.pop(context); // Close dialog immediately

                            // Map UI filter selection to API enum value
                            String targetRole = 'all';
                            if (_selectedFilter == 1) targetRole = 'staff';
                            if (_selectedFilter == 2) targetRole = 'student';

                            final result = await _hodService.createAnnouncement(
                              titleCtrl.text,
                              bodyCtrl.text,
                              targetRole,
                            );

                            if (result != null) {
                              _loadAnnouncements();
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to post announcement',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Post',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0D14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4DB6FF)),
        ),
      );
    }

    // Filter announcements locally for quick UX
    List<Map<String, dynamic>> displayedAnnouncements = _announcements;
    if (_selectedFilter == 1) {
      displayedAnnouncements = _announcements
          .where((a) => a['target_role'] == 'staff')
          .toList();
    } else if (_selectedFilter == 2) {
      displayedAnnouncements = _announcements
          .where((a) => a['target_role'] == 'student')
          .toList();
    }

    // Apply search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      displayedAnnouncements = displayedAnnouncements.where((a) {
        final t = (a['title'] ?? '').toString().toLowerCase();
        final b = (a['body'] ?? '').toString().toLowerCase();
        return t.contains(query) || b.contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _showAddAnnouncementDialog,
          backgroundColor: const Color(0xFF3A7AFF),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF4DB6FF),
                            size: 18,
                          ),
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HODDashboardScreen(),
                            ),
                            (route) => false,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Color(0xFF4DB6FF),
                            size: 22,
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Title ──
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Search bar ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151B2B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E2A40),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search announcements...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          icon: Icon(
                            Icons.search,
                            color: Colors.white38,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Filter chips ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _filters.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(
                              right: i < _filters.length - 1 ? 10 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: i == _selectedFilter
                                      ? const Color(0xFF3A7AFF)
                                      : const Color(0xFF151B2B),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: i == _selectedFilter
                                        ? const Color(0xFF5B9AFF)
                                        : const Color(0xFF1E2A40),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _filters[i],
                                  style: TextStyle(
                                    color: i == _selectedFilter
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 13,
                                    fontWeight: i == _selectedFilter
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Announcement Cards ──
                    ...displayedAnnouncements.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onLongPress: () => _deleteAnnouncement(a['id']),
                          child: _AnnouncementCard(apiData: a),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const HodBottomNavBar(activeTab: HodTab.announcements),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Announcement Card
// ─────────────────────────────────────────────
class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> apiData;

  const _AnnouncementCard({required this.apiData});

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM dd, hh:mm a').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map API data back to UI theme components
    final targetRole = (apiData['target_role'] ?? 'ALL')
        .toString()
        .toUpperCase();

    Color audienceBg = const Color(0xFF1D2230);
    Color audienceTextColor = const Color(0xFF8899BB);
    if (targetRole == 'STUDENT') {
      audienceBg = const Color(0xFF0D2040);
      audienceTextColor = const Color(0xFF4DB6FF);
    } else if (targetRole == 'STAFF') {
      audienceBg = const Color(0xFF2A1A2B);
      audienceTextColor = const Color(0xFFCF9EBF);
    }

    // Highlight announcements created in the last 24 hours
    bool highlightLeft = false;
    if (apiData['created_at'] != null) {
      try {
        final date = DateTime.parse(apiData['created_at'].toString()).toLocal();
        if (DateTime.now().difference(date).inHours < 24) {
          highlightLeft = true;
        }
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlightLeft
              ? const Color(0xFF3A7AFF).withOpacity(0.4)
              : const Color(0xFF1E2A40),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Blue left accent bar (only for unread/highlighted)
              if (highlightLeft)
                Container(width: 4, color: const Color(0xFF3A7AFF)),

              // Card content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    highlightLeft ? 12 : 14,
                    14,
                    14,
                    14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Audience badge + Time + UNREAD ──
                      Row(
                        children: [
                          // Audience badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: audienceBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              targetRole,
                              style: TextStyle(
                                color: audienceTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(apiData['created_at']),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Title ──
                      Text(
                        apiData['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── Body ──
                      Text(
                        apiData['body'] ?? '',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Divider ──
                      Container(height: 1, color: const Color(0xFF1E2A40)),
                      const SizedBox(height: 10),

                      // ── Sender + Details ──
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2A2A2A),
                              border: Border.all(
                                color: Colors.white12,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFBBBBBB),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            apiData['sender_name'] ?? 'Unknown Sender',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: const [
                              Text(
                                'Details',
                                style: TextStyle(
                                  color: Color(0xFF4DB6FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF4DB6FF),
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isMultiline;

  const _DialogField({
    required this.label,
    required this.hint,
    required this.controller,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D121F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2A40)),
          ),
          child: TextField(
            controller: controller,
            maxLines: isMultiline ? 4 : 1,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
