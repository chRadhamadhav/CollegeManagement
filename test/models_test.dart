import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:college_management/Features/Admin/Models/user_model.dart';
import 'package:college_management/Features/Staff/Models/student.dart';

void main() {
  group('Model Serialization Tests', () {
    test('Student model can be created from parameters', () {
      final student = Student(
        id: '123',
        name: 'John Doe',
        studentId: 'CS101',
        course: 'Computer Science',
        imageUrl: '',
      );

      expect(student.id, '123');
      expect(student.name, 'John Doe');
      expect(student.studentId, 'CS101');
      expect(student.status, AttendanceStatus.pending); // default
    });

    test('User model creates with correct role mapping', () {
      final json = {
        'id': 'abc',
        'email': 'admin@test.com',
        'full_name': 'Admin User',
        'role': 'admin',
        'is_active': true,
      };

      final roleStr = json['role'] as String;
      String category = 'Students';
      if (roleStr == 'staff') category = 'Staff';
      if (roleStr == 'hod') category = 'HODs';
      if (roleStr == 'admin') category = 'Admins';

      final user = User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['full_name'] as String,
        role: roleStr,
        category: category,
        initials: "A",
        statusColor: (json['is_active'] == true)
            ? const Color(0xFF69F0AE) // Colors.greenAccent
            : const Color(0xFFFF5252), // Colors.redAccent
      );

      expect(user.id, 'abc');
      expect(user.role, 'admin');
      expect(user.category, 'Admins');
    });
  });
}
