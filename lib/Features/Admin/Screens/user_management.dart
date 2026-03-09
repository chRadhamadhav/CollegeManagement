import 'package:college_management/Features/Admin/Models/user_model.dart';
import 'package:college_management/Features/Admin/Widgets/admin_app_bar.dart';
import 'package:college_management/Features/Admin/Widgets/admin_drawer.dart';
import 'package:college_management/Features/Admin/Widgets/delete_user_dialog.dart';
import 'package:college_management/Features/Admin/Widgets/edit_user_dialog.dart';
import 'package:college_management/Features/Admin/Widgets/user_filter_tab.dart';
import 'package:college_management/Features/Admin/Widgets/user_list_tile.dart';
import 'package:college_management/Features/Admin/Widgets/user_stat_card.dart';
import 'package:college_management/Services/user_service.dart';
import 'package:college_management/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// A page wrapper for the User Management feature.
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserManagementScreen();
  }
}

/// The main screen for managing users, allowing administrators to
/// view, filter, search, edit, and delete user records.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();

  String _selectedCategory = 'All Users';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _userService.getUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  List<User> get _filteredUsers {
    return _users.where((user) {
      final matchesCategory =
          _selectedCategory == 'All Users' ||
          user.category == _selectedCategory;
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.role.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (_) => EditUserDialog(
        user: user,
        userService: _userService,
        onSaved: (_) => _loadUsers(),
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (_) => DeleteUserDialog(
        user: user,
        userService: _userService,
        onDeleted: () {
          _loadUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
        },
      ),
    );
  }

  Future<void> _bulkUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      final success = await _userService.bulkUploadUsers(result.files.single);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _loadUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bulk upload successful')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Bulk upload failed')));
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AdminDrawer(selectedIndex: 2),
      appBar: const AdminAppBar(title: 'User Management', showMenuButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search students, staff or HODs...',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  UserFilterTab(
                    label: 'All Users',
                    isSelected: _selectedCategory == 'All Users',
                    onTap: () =>
                        setState(() => _selectedCategory = 'All Users'),
                  ),
                  UserFilterTab(
                    label: 'Students',
                    isSelected: _selectedCategory == 'Students',
                    onTap: () => setState(() => _selectedCategory = 'Students'),
                  ),
                  UserFilterTab(
                    label: 'Staff',
                    isSelected: _selectedCategory == 'Staff',
                    onTap: () => setState(() => _selectedCategory = 'Staff'),
                  ),
                  UserFilterTab(
                    label: 'HODs',
                    isSelected: _selectedCategory == 'HODs',
                    onTap: () => setState(() => _selectedCategory = 'HODs'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Stats Cards
            Row(
              children: [
                Expanded(
                  child: UserStatCard(
                    title: 'TOTAL USERS',
                    count: _isLoading ? '...' : _users.length.toString(),
                    subtitle: 'From database',
                    subtitleColor: Colors.blueAccent,
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UserStatCard(
                    title: 'ACTIVE NOW',
                    count: _isLoading
                        ? '...'
                        : _users
                              .where((u) => u.statusColor == Colors.greenAccent)
                              .length
                              .toString(),
                    subtitle: '• Live Session',
                    subtitleColor: AppColors.adminAccentBlue,
                    isLive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Recent Users Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _bulkUpload,
                      icon: const Icon(Icons.file_upload_outlined, size: 18),
                      label: const Text('Import Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccentBlue.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: AppColors.adminAccentBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(color: AppColors.adminAccentBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. User List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filteredUsers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No users found",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return UserListTile(
                    user: user,
                    onEdit: () => _editUser(user),
                    onDelete: () => _deleteUser(user),
                  );
                },
              ),

            // Extra space at bottom so the last item isn't hidden behind the FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
