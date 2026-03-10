import 'dart:ui';
import 'package:vidhya_sethu/Features/Student/Services/student_service.dart';
import 'package:vidhya_sethu/Global/login.dart';
import 'package:vidhya_sethu/Services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;
  final StudentService _studentService = StudentService();
  final String _baseUrl = 'http://127.0.0.1:8000';

  bool _isEditing = false;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _studentService.getStudentProfile();
      if (data != null) {
        setState(() {
          _profileData = data;
          _isLoading = false;
          _nameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _courseController.text = data['course'] ?? '';
          _semesterController.text = data['semester'] ?? '';
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load profile data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
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
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Are you sure you want to exit your session? You will need to login again.',
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      ),
    );

    await AuthService().logout();
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StudentLoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final success = await _studentService.updateStudentProfile({
      'full_name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'course': _courseController.text,
      'semester': _semesterController.text,
    });

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _isEditing = false;
          _loadProfileData(); // Refresh data
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final avatarUrl = _profileData?['avatar_url'];
    final name = _profileData?['full_name'] ?? 'Student';

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light background like dashboard
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Reset controllers to original data
                  _nameController.text = _profileData?['full_name'] ?? '';
                  _emailController.text = _profileData?['email'] ?? '';
                  _phoneController.text = _profileData?['phone_number'] ?? '';
                  _courseController.text = _profileData?['course'] ?? '';
                  _semesterController.text = _profileData?['semester'] ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          ),
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.blue),
              onPressed: _isSaving ? null : _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2F80ED),
                            width: 3,
                          ),
                        ),
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  '$_baseUrl$avatarUrl',
                                ),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF2F80ED),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F80ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Full Name',
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        )
                      : Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                  const SizedBox(height: 4),
                  _isEditing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _courseController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Course',
                                ),
                              ),
                            ),
                            const Text(' | Sem '),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _semesterController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Sem',
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "${_profileData?['course'] ?? 'Course Not Set'} | Sem ${_profileData?['semester'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Status: Regular Student",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSection(
                    title: "Personal Information",
                    items: [
                      _buildInfoRow(
                        Icons.badge_outlined,
                        "Roll Number",
                        _profileData?['roll_number'] ?? 'Not set',
                      ),
                      _buildInfoRow(
                        Icons.cake_outlined,
                        "Student ID", // Reusing this row
                        _profileData?['id']
                                ?.toString()
                                .substring(0, 8)
                                .toUpperCase() ??
                            'N/A',
                      ),
                      _buildInfoRow(
                        Icons.bloodtype_outlined,
                        "Status", // Reusing this row
                        _profileData?['is_active'] == true
                            ? 'Active'
                            : 'Inactive',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: "Contact Details",
                    items: [
                      _buildInfoRow(
                        Icons.email_outlined,
                        "Email",
                        _profileData?['email'] ?? 'Not set',
                        controller: _emailController,
                        isEditable: true,
                      ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        "Phone",
                        _profileData?['phone_number'] ?? 'Not set',
                        controller: _phoneController,
                        isEditable: true,
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        "Role", // Reusing this row
                        _profileData?['role'] ?? 'student',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: "Academic Information",
                    items: [
                      _buildInfoRow(
                        Icons.school_outlined,
                        "Department",
                        _profileData?['department_name'] ?? 'Not set',
                      ),
                      _buildInfoRow(
                        Icons.menu_book_outlined,
                        "Current Semester",
                        _profileData?['semester'] ?? 'Not set',
                      ),
                      _buildInfoRow(
                        Icons.person_outline,
                        "Course", // Reusing this row
                        _profileData?['course'] ?? 'Not set',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmationDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    TextEditingController? controller,
    bool isEditable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                _isEditing && isEditable && controller != null
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
