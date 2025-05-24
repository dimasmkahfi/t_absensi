// widgets/attendance_bottom_sheet.dart
import 'package:flutter/material.dart';

class AttendanceBottomSheet extends StatefulWidget {
  @override
  _AttendanceBottomSheetState createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  String selectedShift = 'Morning Shift';
  List<String> shifts = ['Morning Shift', 'Afternoon Shift', 'Night Shift'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Attendance Check',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedShift,
                  isExpanded: true,
                  items:
                      shifts.map((String shift) {
                        return DropdownMenuItem<String>(
                          value: shift,
                          child: Text(shift),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedShift = newValue!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showFaceCapture(context);
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
                  'Proceed to Face Capture',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showFaceCapture(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Face Capture'),
          content: Text(
            'Face capture feature will be implemented here.\n\nSelected Shift: $selectedShift',
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
