import 'package:flutter/material.dart';

/// A single navigation [ListTile] used inside [AdminDrawer].
///
/// Highlights icon and label in white/blue when [isSelected] is true.
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? onSurface : onSurface.withValues(alpha: 0.6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
