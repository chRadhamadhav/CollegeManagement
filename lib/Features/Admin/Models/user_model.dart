import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role; // e.g., 'student'
  final String category; // 'Students', 'Staff', 'HODs'
  final String? avatarUrl;
  final Color? color;
  final String initials;
  final Color statusColor;

  bool get isImage => avatarUrl != null && avatarUrl!.isNotEmpty;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.category,
    this.avatarUrl,
    this.color,
    this.initials = "",
    required this.statusColor,
  });
}
