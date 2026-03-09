import 'package:vidhya_sethu/Features/Admin/Screens/create_user.dart';
import 'package:vidhya_sethu/Features/Admin/Widgets/admin_app_bar.dart';
import 'package:vidhya_sethu/Features/Admin/Widgets/admin_drawer.dart';
import 'package:vidhya_sethu/Services/user_service.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>?> _statsFuture;
  late Future<bool> _healthFuture;

  @override
  void initState() {
    super.initState();
    final userService = UserService();
    _statsFuture = userService.getDashboardStats();
    _healthFuture = userService.checkSystemHealth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(
        title: 'Admin Monitoring',
        showMenuButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // System Status Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<bool>(
                          future: _healthFuture,
                          builder: (context, snapshot) {
                            final isHealthy = snapshot.data ?? false;
                            final isLoading =
                                snapshot.connectionState ==
                                ConnectionState.waiting;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoading
                                      ? 'Checking...'
                                      : isHealthy
                                      ? 'Healthy'
                                      : 'Offline',
                                  style: TextStyle(
                                    color: isLoading
                                        ? Colors.orange
                                        : isHealthy
                                        ? const Color(0xFF00BFA5)
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isLoading
                                            ? Colors.orangeAccent
                                            : isHealthy
                                            ? const Color(0xFF69F0AE)
                                            : Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isLoading
                                          ? 'Fetching status...'
                                          : isHealthy
                                          ? 'All services operational'
                                          : 'Backend not responding',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    FutureBuilder<bool>(
                      future: _healthFuture,
                      builder: (context, snapshot) {
                        final isHealthy = snapshot.data ?? false;
                        final isLoading =
                            snapshot.connectionState == ConnectionState.waiting;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isLoading
                                ? Colors.orange.withValues(alpha: 0.1)
                                : isHealthy
                                ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                                : Colors.redAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLoading
                                ? Icons.sync
                                : isHealthy
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: isLoading
                                ? Colors.orange
                                : isHealthy
                                ? const Color(0xFF00BFA5)
                                : Colors.redAccent,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Grid
              FutureBuilder<Map<String, dynamic>?>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Error loading stats',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final stats = snapshot.data ?? {};
                  final totalStudents = stats['total_students'] ?? 0;
                  final totalHods = stats['total_hods'] ?? 0;
                  final totalStaff = stats['total_staff'] ?? 0;
                  final totalDepartments = stats['total_departments'] ?? 0;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      StatCard(
                        icon: Icons.school_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        count: totalStudents.toString(),
                        label: 'Total Students',
                      ),
                      StatCard(
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF8B5CF6),
                        count: totalHods.toString(),
                        label: 'Total HODs',
                      ),
                      StatCard(
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        count: totalStaff.toString(),
                        label: 'Total Staff',
                      ),
                      StatCard(
                        icon: Icons.business_outlined,
                        iconColor: const Color(0xFF6366F1),
                        count: totalDepartments.toString(),
                        label: 'Total Departments',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewUserPage()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
