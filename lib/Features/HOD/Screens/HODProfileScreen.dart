import 'dart:ui';
import 'package:college_management/Features/HOD/Widgets/hod_bottom_nav_bar.dart';
import 'package:college_management/Features/HOD/Services/hod_service.dart';
import 'package:college_management/Global/login.dart';
import 'package:college_management/Services/user_service.dart';
import 'package:college_management/Services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HODProfileScreen extends StatefulWidget {
  const HODProfileScreen({super.key});

  @override
  State<HODProfileScreen> createState() => _HODProfileScreenState();
}

class _HODProfileScreenState extends State<HODProfileScreen> {
  final HODService _hodService = HODService();
  final String _baseUrl = 'http://127.0.0.1:8000';
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final data = await _hodService.getHODProfile();
    if (mounted) {
      setState(() {
        _profileData = data;
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HOD Personal Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4DB6FF)),
            )
          : _profileData == null
          ? const Center(
              child: Text(
                'Failed to load profile',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── Avatar + Name ──
                  Center(
                    child: Column(
                      children: [
                        // Avatar with edit badge
                        GestureDetector(
                          onTap: () => _pickAndUploadImage(context),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1A2B3A),
                                  border: Border.all(
                                    color: const Color(0xFF3A7AFF),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      _profileData!['avatar_url'] != null &&
                                          _profileData!['avatar_url'].isNotEmpty
                                      ? Image.network(
                                          '$_baseUrl${_profileData!['avatar_url']}',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.person,
                                                    size: 64,
                                                    color: Colors.blueGrey[300],
                                                  ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.blueGrey[300],
                                        ),
                                ),
                              ),
                              // Edit button
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF3A7AFF),
                                  border: Border.all(
                                    color: const Color(0xFF0B0D14),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _profileData!['name'] ?? 'Unknown Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          (_profileData!['designation'] ?? 'HEAD OF DEPARTMENT')
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Info Cards ──
                  _InfoCard(
                    label: 'DEPARTMENT',
                    value: _profileData!['department_name'] ?? 'N/A',
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'EMPLOYEE ID',
                    value: _profileData!['employee_id'] ?? 'N/A',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'EMAIL',
                    value: _profileData!['email'] ?? 'N/A',
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'CONTACT',
                    value: _profileData!['phone'] ?? 'N/A',
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 10),

                  // ── Qualifications Section ──
                  const Text(
                    'QUALIFICATIONS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B2B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1E2A40),
                        width: 1,
                      ),
                    ),
                    child: _buildQualifications(),
                  ),
                  const SizedBox(height: 28),

                  // ── Logout Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A1010),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                            color: Color(0xFF5A1A1A),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFFF5252),
                        size: 22,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ), // Extra space to scroll past the FAB
                ],
              ),
            ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _profileData != null
              ? () => _showEditDialog(context)
              : null,
          backgroundColor: const Color(0xFF3A7AFF),
          tooltip: 'Edit Profile',
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),

      bottomNavigationBar: const HodBottomNavBar(activeTab: HodTab.profile),
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
                      color: const Color(
                        0xFF151B2B,
                      ), // Match HOD dark theme surface
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
                        const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        const Text(
                          'Are you sure you want to exit your session? You will need to login again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white70,
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
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
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

  void _showEditDialog(BuildContext context) {
    if (_profileData == null) return;

    final nameController = TextEditingController(text: _profileData!['name']);
    final educationController = TextEditingController(
      text: _profileData!['qualifications'],
    );

    // Attempt to extract DOB from the arbitrary `qualifications` or another field if needed
    // The HOD profile screen doesn't explicitly have DOB, but we can allow it
    final dobController = TextEditingController(text: '');
    final phoneController = TextEditingController(
      text: _profileData!['phone'] != '+1 234 567 890'
          ? _profileData!['phone']
          : '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // For custom rounded corners
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Color(0xFF151B2B), // Match HOD theme
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text(
                      'Edit Personal Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                        _pickAndUploadImage(context); // Open file picker
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF3A7AFF),
                      ),
                      label: const Text(
                        'Change Profile Photo',
                        style: TextStyle(color: Color(0xFF3A7AFF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: const Color(0xFF3A7AFF).withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: educationController,
                      label: 'Qualifications (comma-separated)',
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF3A7AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final data = {
                            'full_name': nameController.text.trim(),
                            'education': educationController.text.trim(),
                            'dob': dobController.text.trim(),
                            'phone': phoneController.text.trim(),
                          };

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saving profile...')),
                          );

                          final success = await UserService().updateUserProfile(
                            data,
                          );

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile updated successfully! ✨',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _loadProfileData(); // Reload HOD profile specifically
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update profile.'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF151B2B), // Match dark background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2A40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2A40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A7AFF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Uploading image...')));
        }

        final success = await UserService().uploadProfileImage(platformFile);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadProfileData(); // Reload HOD profile
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildQualifications() {
    String eduText = _profileData!['qualifications'] ?? '';
    if (eduText.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'No qualifications provided.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    // Support comma-separated or simple string qualifications
    List<String> quals = eduText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (quals.isEmpty) {
      quals = [eduText];
    }

    return Column(
      children: List.generate(quals.length, (i) {
        final degree = quals[i];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3A7AFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      degree,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < quals.length - 1)
              Container(height: 1, color: const Color(0xFF1E2A40)),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A40), width: 1),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A6A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4DB6FF), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
