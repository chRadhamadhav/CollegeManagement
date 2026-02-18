import 'package:flutter/material.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({Key? key}) : super(key: key);

  @override
  State<NewUserPage> createState() => NewUserPageState();
}

class NewUserPageState extends State<NewUserPage> {
  int selectedRole = 1;
  bool showPassword = false;

  final roles = ["HOD", "Staff", "Student"];
  final departments = ["Computer Science", "Data science", "Maths", "commerce", "Statistics"];
  String? selectedDepartment;


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg = isDark ? const Color(0xff101922) : const Color(0xffF6F7F8);
    Color surface = isDark ? const Color(0xff1C242C) : Colors.white;
    Color border = isDark ? const Color(0xff2A3441) : const Color(0xffDCE0E5);
    Color primary = const Color(0xff137FEC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.close),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Create New User",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40)
                ],
              ),
            ),

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
                        color: isDark ? const Color(0xff1C242C) : const Color(0xffE0E2E6),
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
                                  color: isSelected ? primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  roles[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 25),

                    buildTextField("Full Name", "Purushotham", surface, border),
                    buildTextField("Email Address", "Purush@gmail.com", surface, border),


                    const SizedBox(height: 22),
                    const Text("Department", style: TextStyle(fontWeight: FontWeight.w600)),
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
                            Text(selectedDepartment ?? "Select Department"),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    if (roles[selectedRole] == 'Student')
                      buildTextField("Student ID", "STU-123456", surface, border)
                    else
                      buildTextField("Employee ID", "EMP-123456", surface, border),


                    const SizedBox(height: 22),
                    const Text("Temporary Password", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      "Password Must be at least 8 characters long",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  onPressed: () {},
                  child: const Text("Create User", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint, Color surface, Color border) {
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
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
