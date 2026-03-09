import 'dart:ui';
import 'package:vidhya_sethu/Features/Admin/Screens/admin_dashboard.dart';
import 'package:vidhya_sethu/Features/Admin/Screens/detailed_statistics.dart';
import 'package:vidhya_sethu/Features/Admin/Screens/user_management.dart';
import 'package:vidhya_sethu/Features/Admin/Widgets/drawer_item.dart';
import 'package:vidhya_sethu/Services/user_service.dart';
import 'package:vidhya_sethu/Services/auth_service.dart';
import 'package:vidhya_sethu/Global/login.dart';
import 'package:flutter/material.dart';

/// A custom drawer widget for the Admin dashboard.
/// It provides navigation links to various administrative features.
class AdminDrawer extends StatefulWidget {
  final int selectedIndex;
  const AdminDrawer({super.key, this.selectedIndex = 0});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  late Future<Map<String, dynamic>?> _userProfileFuture;
  final String _baseUrl =
      'http://127.0.0.1:8000'; // Define backend base URL for resolving relative image paths

  @override
  void initState() {
    super.initState();
    _userProfileFuture = UserService().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    // Determine adaptive colors
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 60),

          /// Profile section showing administrator's avatar and name
          FutureBuilder<Map<String, dynamic>?>(
            future: _userProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(),
                );
              }

              final userData = snapshot.data;
              final name = userData?['full_name'] ?? "Admin User";
              final role =
                  userData?['role']?.toString().toUpperCase() ??
                  "ADMINISTRATOR";
              final avatarUrl = userData?['avatar_url'];

              // Logic to handle avatar or initials
              Widget avatarWidget;
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                avatarWidget = CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('$_baseUrl$avatarUrl'),
                  backgroundColor: Colors.white24,
                );
              } else {
                avatarWidget = CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          /// Navigation items
          DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: widget.selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              if (widget.selectedIndex != 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
          DrawerItem(
            icon: Icons.bar_chart,
            title: 'Detailed Statistics',
            isSelected: widget.selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              if (widget.selectedIndex != 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedStatistics(),
                  ),
                );
              }
            },
          ),
          DrawerItem(
            icon: Icons.people,
            title: 'User Management',
            isSelected: widget.selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              if (widget.selectedIndex != 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementPage(),
                  ),
                );
              }
            },
          ),

          const Spacer(),

          /// Logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              _showLogoutConfirmationDialog(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Circle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'Are you sure you want to exit your administrator session? You will need to login again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _performLogout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    // 1. Show loading indicator over the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      ),
    );

    // 2. Clear secure storage tokens
    await AuthService().logout();

    // Small delay to make the transition feel smooth and not too abrupt
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Navigate to Login Page, popping all previous routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StudentLoginPage()),
        (route) => false,
      );
    }
  }
}
