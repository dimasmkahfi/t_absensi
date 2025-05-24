// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/welcome_card.dart';
import '../widgets/today_status_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/attendance_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(),
            SizedBox(height: 20),
            TodayStatusCard(),
            SizedBox(height: 20),
            QuickActionsSection(),
            SizedBox(height: 20),
            RecentActivitySection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAttendanceSheet(context);
        },
        icon: Icon(Icons.fingerprint),
        label: Text('Check In/Out'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  void _showAttendanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttendanceBottomSheet(),
    );
  }
}
