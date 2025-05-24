// screens/report_screen.dart
import 'package:flutter/material.dart';
import '../widgets/period_selector.dart';
import '../widgets/summary_cards.dart';
import '../widgets/attendance_chart.dart';
import '../widgets/detailed_report.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedPeriod = 'This Month';
  List<String> periods = ['This Week', 'This Month', 'Last Month', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance Report'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _exportReport();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeriodSelector(
              selectedPeriod: selectedPeriod,
              periods: periods,
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                });
              },
            ),
            SizedBox(height: 20),
            SummaryCards(),
            SizedBox(height: 20),
            AttendanceChart(),
            SizedBox(height: 20),
            DetailedReport(),
          ],
        ),
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Report'),
          content: Text(
            'Report for $selectedPeriod has been exported successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
