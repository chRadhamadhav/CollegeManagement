import 'package:vidhya_sethu/Features/Admin/Widgets/admin_app_bar.dart';
import 'package:vidhya_sethu/Services/user_service.dart';
import 'package:flutter/material.dart';

/// A page that allows administrators to create a new user (Student, Staff, or HOD).
class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => NewUserPageState();
}

class NewUserPageState extends State<NewUserPage> {
  /// Index of the currently selected role from the [roles] list.
  int selectedRole = 1;

  /// Whether the temporary password should be visible.
  bool showPassword = false;

  /// Available user roles for selection.
  final roles = ["HOD", "Staff", "Student"];

  /// List of departments available for the new user.
  final departments = [
    "Computer Science",
    "Data science",
    "Maths",
    "commerce",
    "Statistics",
  ];

  /// The currently selected department.
  String? selectedDepartment;

  // Controllers for handling input field data
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Reference to the singleton [UserService] for adding the new user.
  final UserService _userService = UserService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates input fields and adds a new user to the [UserService].
  /// Shows a success message and navigates back upon successful creation.
  Future<void> _createUser() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedDepartment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final roleLabel = roles[selectedRole]
        .toLowerCase(); // "hod", "staff", "student"

    final Map<String, dynamic> data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'full_name': _fullNameController.text.trim(),
      'role': roleLabel,
      'department': selectedDepartment,
    };

    if (roleLabel == 'student') {
      data['roll_number'] = _idController.text.trim();
    } else {
      data['designation'] = _idController.text
          .trim(); // Mapping employee ID/Title to designation
    }

    final errorMessage = await _userService.addUser(data);

    if (mounted) {
      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_fullNameController.text} created successfully!',
            ),
          ),
        );
        Navigator.pop(context, true); // return true to refresh
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg = Theme.of(context).scaffoldBackgroundColor;
    Color surface = Theme.of(context).colorScheme.surface;
    Color border = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.12);
    Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: const AdminAppBar(title: 'Create New User'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 45,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xff1C242C)
                            : const Color(0xffE0E2E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: List.generate(roles.length, (index) {
                          final isSelected = selectedRole == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedRole = index),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  roles[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 25),
                    buildTextField(
                      "Full Name",
                      "Enter full name",
                      surface,
                      border,
                      _fullNameController,
                    ),
                    buildTextField(
                      "Email Address",
                      "example@gmail.com",
                      surface,
                      border,
                      _emailController,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Department",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Select Department'),
                              children: departments.map((String department) {
                                return SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      selectedDepartment = department;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(department),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDepartment ?? "Select Department",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (roles[selectedRole] == 'Student')
                      buildTextField(
                        "Student ID",
                        "STU-123456",
                        surface,
                        border,
                        _idController,
                      )
                    else
                      buildTextField(
                        "Employee ID",
                        "EMP-123456",
                        surface,
                        border,
                        _idController,
                      ),
                    const SizedBox(height: 22),
                    const Text(
                      "Temporary Password",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () =>
                                setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Password Must be at least 8 characters long",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _createUser,
                  child: const Text(
                    "Create User",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint,
    Color surface,
    Color border,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
