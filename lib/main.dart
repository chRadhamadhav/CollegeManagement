import 'package:collegemanagement/Global/login.dart' show LoginPage;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrant College',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
