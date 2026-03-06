import 'package:flutter/material.dart';
import '../Widgets/class_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Schedule'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            tabs: const [
              Tab(text: "MON"),
              Tab(text: "TUE"),
              Tab(text: "WED"),
              Tab(text: "THU"),
              Tab(text: "FRI"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DayScheduleView(day: "Monday"),
            _DayScheduleView(day: "Tuesday"),
            _DayScheduleView(day: "Wednesday"),
            _DayScheduleView(day: "Thursday"),
            _DayScheduleView(day: "Friday"),
          ],
        ),
      ),
    );
  }
}

class _DayScheduleView extends StatelessWidget {
  final String day;

  const _DayScheduleView({required this.day});

  @override
  Widget build(BuildContext context) {
    // TODO: Backend - Replace mock data with actual schedule fetched from API based on the `day`
    final List<Map<String, dynamic>> mockClasses = _getMockClassesForDay(day);

    if (mockClasses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No classes scheduled",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockClasses.length,
      itemBuilder: (context, index) {
        final classData = mockClasses[index];
        return IntrinsicHeight(
          child: ClassCard(
            subject: classData['subject'],
            time: classData['time'],
            room: classData['room'],
            course: classData['course'],
            isLive: classData['isLive'] ?? false,
          ),
        );
      },
    );
  }

  // --- Mock Data Generator ---
  List<Map<String, dynamic>> _getMockClassesForDay(String day) {
    if (day == "Monday" || day == "Wednesday") {
      return [
        {
          "subject": "Data Structures",
          "time": "09:00 AM - 10:30 AM",
          "room": "Lecture Hall 101",
          "course": "BCA - Semester 3",
          "isLive": day == "Monday", // Make one live for demo purposes
        },
        {
          "subject": "Computer Networks",
          "time": "11:00 AM - 12:30 PM",
          "room": "Lab 4",
          "course": "BSc Comp Sci - Year 2",
        },
        {
          "subject": "System Design",
          "time": "02:00 PM - 03:30 PM",
          "room": "Lecture Hall 305",
          "course": "BCA - Semester 5",
        },
      ];
    } else if (day == "Tuesday" || day == "Thursday") {
      return [
        {
          "subject": "Operating Systems",
          "time": "09:00 AM - 10:30 AM",
          "room": "Room 202",
          "course": "BCA - Semester 3",
        },
        {
          "subject": "Database Management",
          "time": "02:00 PM - 04:00 PM",
          "room": "Lab 2",
          "course": "BCA - Semester 4",
        },
      ];
    }
    // Return empty for Friday to show the empty state design
    return [];
  }
}
