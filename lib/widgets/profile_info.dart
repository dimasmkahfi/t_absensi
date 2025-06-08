// lib/widgets/profile_info.dart - Enhanced with dynamic data
import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class ProfileInfo extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileInfo({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = userData?['email'] ?? 'N/A';
    final phone = userData?['phone'] ?? userData?['phone_number'] ?? 'N/A';
    final department = userData?['department'] ?? 'N/A';
    final joinDate = userData?['join_date'] ?? userData?['created_at'];

    String formattedJoinDate = 'N/A';
    if (joinDate != null) {
      try {
        final date = DateTime.parse(joinDate);
        formattedJoinDate = DateTimeUtils.formatDate(date);
      } catch (e) {
        formattedJoinDate = joinDate.toString();
      }
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue[600], size: 24),
              SizedBox(width: 12),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoRow('Email', email, Icons.email_outlined),
          _buildInfoRow('Phone', phone, Icons.phone_outlined),
          _buildInfoRow('Department', department, Icons.business_outlined),
          _buildInfoRow(
            'Join Date',
            formattedJoinDate,
            Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
