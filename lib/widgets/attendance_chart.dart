// widgets/attendance_chart.dart
import 'package:flutter/material.dart';

class AttendanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 0.9, Colors.green),
                _buildChartBar('Tue', 1.0, Colors.green),
                _buildChartBar('Wed', 0.8, Colors.orange),
                _buildChartBar('Thu', 1.0, Colors.green),
                _buildChartBar('Fri', 0.0, Colors.red),
                _buildChartBar('Sat', 0.7, Colors.orange),
                _buildChartBar('Sun', 0.0, Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        SizedBox(height: 10),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
