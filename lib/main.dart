import 'package:college_management/Global/auth_wrapper.dart';
import 'package:college_management/Global/theme_controller.dart';
import 'package:college_management/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'College Management',
          debugShowCheckedModeBanner: false,
          themeMode:
              themeMode, // Controlled dynamically by the theme toggle/system
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F80ED),
              brightness: Brightness.light,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0B0D14),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F80ED),
              brightness: Brightness.dark,
              surface: const Color(0xFF151B2B),
              onSurface: const Color(0xFFF8FAFC),
            ),
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          home: const AuthWrapper(),
          onGenerateRoute: AppRoutes.generate,
        );
      },
    );
  }
}
