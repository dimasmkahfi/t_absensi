// lib/widgets/profile_stats.dart - Enhanced to handle real API data
import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const ProfileStats({Key? key, this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presentDays = stats?['presentDays'] ?? 0;
    final totalHours = (stats?['totalHours'] ?? 0.0).toDouble();
    final avgHours = (stats?['avgHours'] ?? 0.0).toDouble();
    final lateCount = stats?['lateCount'] ?? 0;
    final totalDays = stats?['totalDays'] ?? 0;
    final attendanceRate = (stats?['attendanceRate'] ?? 0.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.blue[600], size: 24),
            SizedBox(width: 12),
            Text(
              'This Month Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Attendance Rate Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[800]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Attendance Rate',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${attendanceRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$presentDays of $totalDays working days',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Hours',
                '${totalHours.toStringAsFixed(1)}h',
                'Working time',
                Colors.green,
                Icons.schedule,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Average',
                '${avgHours.toStringAsFixed(1)}h',
                'Per day',
                Colors.orange,
                Icons.trending_up,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Present Days',
                presentDays.toString(),
                'This month',
                Colors.blue,
                Icons.check_circle_outline,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Late Count',
                lateCount.toString(),
                'Times late',
                lateCount > 0 ? Colors.red : Colors.green,
                Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
