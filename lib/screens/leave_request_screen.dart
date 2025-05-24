// screens/leave_request_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/leave_form_card.dart';
import '../widgets/recent_requests_section.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String selectedType = 'Cuti';
  List<String> leaveTypes = ['Cuti', 'Izin', 'Sakit'];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text('Leave Request'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeaveFormCard(
              selectedType: selectedType,
              leaveTypes: leaveTypes,
              startDate: startDate,
              endDate: endDate,
              reasonController: reasonController,
              onTypeChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              onStartDateChanged: (date) {
                setState(() {
                  startDate = date;
                  if (endDate.isBefore(startDate)) {
                    endDate = startDate;
                  }
                });
              },
              onEndDateChanged: (date) {
                setState(() {
                  endDate = date;
                });
              },
            ),
            SizedBox(height: 20),
            _buildSubmitButton(),
            SizedBox(height: 20),
            RecentRequestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _submitLeaveRequest();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Submit Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _submitLeaveRequest() {
    if (reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a reason for leave')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Submitted'),
          content: Text(
            'Your $selectedType request has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                reasonController.clear();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
