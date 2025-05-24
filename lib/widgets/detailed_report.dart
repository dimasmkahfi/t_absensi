// widgets/detailed_report.dart
import 'package:flutter/material.dart';

class DetailedReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildReportItem(
                'Dec 20, 2024',
                '08:00 AM',
                '17:30 PM',
                '9h 30m',
                Colors.green,
              ),
              Divider(height: 1),
              _buildReportItem(
                'Dec 19, 2024',
                '08:15 AM',
                '17:45 PM',
                '9h 30m',
                Colors.green,
              ),
              Divider(height: 1),
              _buildReportItem(
                'Dec 18, 2024',
                '08:30 AM',
                '16:00 PM',
                '7h 30m',
                Colors.orange,
              ),
              Divider(height: 1),
              _buildReportItem('Dec 17, 2024', 'Absent', '-', '-', Colors.red),
              Divider(height: 1),
              _buildReportItem(
                'Dec 16, 2024',
                '08:00 AM',
                '17:30 PM',
                '9h 30m',
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(
    String date,
    String checkIn,
    String checkOut,
    String duration,
    Color statusColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              checkIn,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              checkOut,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                duration,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
