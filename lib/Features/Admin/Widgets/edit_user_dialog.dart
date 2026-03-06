import 'package:college_management/Features/Admin/Models/user_model.dart';
import 'package:college_management/Services/user_service.dart';
import 'package:flutter/material.dart';

/// A themed [AlertDialog] for editing a [User]'s name, role, and category.
///
/// Calls [onSaved] with the updated [User] on confirm so the parent can
/// call [UserService.updateUser] and trigger a rebuild via [setState].
class EditUserDialog extends StatefulWidget {
  final User user;
  final UserService userService;
  final ValueChanged<User> onSaved;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.userService,
    required this.onSaved,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late String _selectedCategory;

  static const List<String> _categories = ['Students', 'Staff', 'HODs'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _roleController = TextEditingController(text: widget.user.role);
    _selectedCategory = widget.user.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = User(
      id: widget.user.id,
      email: widget.user.email,
      name: _nameController.text,
      role: _roleController.text,
      category: _selectedCategory,
      avatarUrl: widget.user.avatarUrl,
      color: widget.user.color,
      initials: widget.user.initials,
      statusColor: widget.user.statusColor,
    );

    await widget.userService.updateUser(widget.user.id, {
      'full_name': _nameController.text,
      'role': _roleController.text,
    });

    widget.onSaved(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return AlertDialog(
      backgroundColor: surface,
      title: Text('Edit User', style: TextStyle(color: onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogField(
            controller: _nameController,
            label: 'Name',
            onSurface: onSurface,
          ),
          _DialogField(
            controller: _roleController,
            label: 'Role',
            onSurface: onSurface,
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedCategory,
            dropdownColor: surface,
            style: TextStyle(color: onSurface),
            items: _categories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// A themed underline [TextField] used inside dialogs.
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color onSurface;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: onSurface.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
