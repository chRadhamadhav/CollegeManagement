import 'package:college_management/Features/Admin/Models/user_model.dart';
import 'package:college_management/Services/user_service.dart';
import 'package:flutter/material.dart';

/// A minimal confirmation [AlertDialog] before deleting a [User].
///
/// Calls [onDeleted] after the user confirms so the parent can call
/// [UserService.deleteUser] and trigger a rebuild via [setState].
class DeleteUserDialog extends StatelessWidget {
  final User user;
  final UserService userService;
  final VoidCallback onDeleted;

  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.userService,
    required this.onDeleted,
  });

  Future<void> _confirm(BuildContext context) async {
    final success = await userService.deleteUser(user.id);
    if (success) {
      onDeleted();
      if (context.mounted) Navigator.pop(context);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete user. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('Delete User', style: TextStyle(color: onSurface)),
      content: Text(
        'Are you sure you want to delete ${user.name}?',
        style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _confirm(context),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
