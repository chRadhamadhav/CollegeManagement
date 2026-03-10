import 'package:vidhya_sethu/Features/Admin/Screens/admin_profile.dart';
import 'package:vidhya_sethu/Global/theme_controller.dart';
import 'package:vidhya_sethu/Services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenuButton;

  const AdminAppBar({
    super.key,
    required this.title,
    this.showMenuButton = false,
  });

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminAppBarState extends State<AdminAppBar> {
  late final String _baseUrl;
  late Future<Map<String, dynamic>?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _baseUrl = (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000')
        .replaceAll('/api/v1', '');
    _userProfileFuture = UserService().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: widget.showMenuButton
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            ThemeController.instance.isDarkMode(context)
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => ThemeController.instance.toggleTheme(context),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              // Avoid pushing if we're already on the profile page
              if (ModalRoute.of(context)?.settings.name != 'AdminProfilePage') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminProfilePage(),
                  ),
                );
              }
            },
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                final userData = snapshot.data;
                final name = userData?['full_name'] ?? "A";
                final avatarUrl = userData?['avatar_url'];

                if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  return CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('$_baseUrl$avatarUrl'),
                    backgroundColor: Colors.white24,
                  );
                } else {
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
