// widgets/today_status_card.dart
import 'package:flutter/material.dart';
import 'package:t_absensi/services/api_services.dart';

class TodayStatusCard extends StatefulWidget {
  @override
  _TodayStatusCardState createState() => _TodayStatusCardState();
}

class _TodayStatusCardState extends State<TodayStatusCard> {
  Map<String, dynamic>? todayData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getTodayStatus();
      if (response['success']) {
        setState(() {
          todayData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showError(response['message']);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load today\'s status');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  onPressed: _loadTodayStatus,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 15),
          if (isLoading)
            _buildLoadingStatus()
          else if (todayData != null)
            _buildStatusContent()
          else
            _buildErrorStatus(),
        ],
      ),
    );
  }

  Widget _buildLoadingStatus() {
    return Row(
      children: [
        Expanded(child: _buildSkeletonStatusItem()),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(horizontal: 15),
        ),
        Expanded(child: _buildSkeletonStatusItem()),
      ],
    );
  }

  Widget _buildSkeletonStatusItem() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 50,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusContent() {
    final attendance = todayData!['attendance'];
    final hasCheckedIn = todayData!['has_checked_in'] ?? false;
    final hasCheckedOut = todayData!['has_checked_out'] ?? false;

    final checkInTime = hasCheckedIn ? attendance['check_in'] : null;
    final checkOutTime = hasCheckedOut ? attendance['check_out'] : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusItem(
                'Check In',
                checkInTime != null ? _formatTime(checkInTime) : 'Not yet',
                Icons.login,
                hasCheckedIn ? Colors.green : Colors.grey,
                hasCheckedIn,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
              margin: EdgeInsets.symmetric(horizontal: 15),
            ),
            Expanded(
              child: _buildStatusItem(
                'Check Out',
                checkOutTime != null ? _formatTime(checkOutTime) : 'Not yet',
                Icons.logout,
                hasCheckedOut ? Colors.red : Colors.orange,
                hasCheckedOut,
              ),
            ),
          ],
        ),
        if (attendance != null && attendance['work_hours'] != null) ...[
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Hours',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${attendance['work_hours']}h',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (attendance != null && attendance['status'] != null) ...[
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(attendance['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(attendance['status']),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(attendance['status']),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorStatus() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.grey, size: 48),
          SizedBox(height: 10),
          Text(
            'Failed to load status',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 10),
          TextButton(onPressed: _loadTodayStatus, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String time,
    IconData icon,
    Color color,
    bool isCompleted,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Icon(icon, color: color, size: 24),
              if (isCompleted)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 8),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    return timeString;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'early_leave':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'early_leave':
        return 'Early Leave';
      default:
        return status.toUpperCase();
    }
  }
}
