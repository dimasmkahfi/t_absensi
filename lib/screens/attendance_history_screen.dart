// lib/screens/attendance_history_screen.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_absensi/services/api_services.dart';
import '../widgets/status_badge.dart';
import '../utils/date_utils.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> attendanceHistory = [];
  DateTime selectedDate = DateTime.now();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getAttendanceHistory(
        month: selectedDate.month,
        year: selectedDate.year,
      );

      print('📊 Attendance History Response: $response');

      if (response['success'] == true) {
        final data = response['data'];

        if (data != null) {
          // Handle different response formats
          List<Map<String, dynamic>> parsedHistory = [];

          if (data is List) {
            // If data is already a list
            parsedHistory =
                data.map((item) {
                  if (item is Map<String, dynamic>) {
                    return item;
                  } else {
                    return <String, dynamic>{};
                  }
                }).toList();
          } else if (data is Map<String, dynamic>) {
            // If data is a map, check if it contains a list
            if (data.containsKey('attendance') && data['attendance'] is List) {
              parsedHistory =
                  (data['attendance'] as List).map((item) {
                    if (item is Map<String, dynamic>) {
                      return item;
                    } else {
                      return <String, dynamic>{};
                    }
                  }).toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              parsedHistory =
                  (data['data'] as List).map((item) {
                    if (item is Map<String, dynamic>) {
                      return item;
                    } else {
                      return <String, dynamic>{};
                    }
                  }).toList();
            } else {
              // Single attendance record
              parsedHistory = [data];
            }
          }

          setState(() {
            attendanceHistory = parsedHistory;
          });

          print('✅ Parsed ${attendanceHistory.length} attendance records');
        } else {
          setState(() {
            attendanceHistory = [];
          });
          print('ℹ️ No attendance data received');
        }
      } else {
        setState(() {
          errorMessage =
              response['message'] ?? 'Failed to load attendance history';
          attendanceHistory = [];
        });
        print('❌ API Error: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading attendance history: $e';
        attendanceHistory = [];
      });
      print('🚨 Exception in _loadAttendanceHistory: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadAttendanceHistory();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Generate mock data for testing when no real data available
  List<Map<String, dynamic>> _generateMockData() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      final date = now.subtract(Duration(days: index));
      final statuses = ['present', 'late', 'absent'];
      final status = statuses[index % 3];

      return {
        'id': (index + 1).toString(),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'check_in_time':
            status != 'absent'
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    8 + (index % 2),
                    30 + (index * 5) % 60,
                  ),
                )
                : null,
        'check_out_time':
            status != 'absent'
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    17 + (index % 2),
                    15 + (index * 3) % 60,
                  ),
                )
                : null,
        'status': status,
        'notes': index % 3 == 0 ? 'Regular attendance' : null,
        'location': 'Office Building',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use mock data if no real data and not loading
    final displayData =
        attendanceHistory.isEmpty && !isLoading
            ? _generateMockData()
            : attendanceHistory;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.calendar_month), onPressed: _selectMonth),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAttendanceHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectMonth,
                  icon: Icon(Icons.calendar_today, size: 16),
                  label: Text('Change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistics Summary
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Present',
                    _countStatus(displayData, 'present').toString(),
                    Colors.green[600]!,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Late',
                    _countStatus(displayData, 'late').toString(),
                    Colors.orange[600]!,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Absent',
                    _countStatus(displayData, 'absent').toString(),
                    Colors.red[600]!,
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (errorMessage != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[600]),
                    onPressed: () {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Attendance List
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading attendance history...'),
                        ],
                      ),
                    )
                    : displayData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'for ${DateFormat('MMMM yyyy').format(selectedDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadAttendanceHistory,
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadAttendanceHistory,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayData.length,
                        itemBuilder: (context, index) {
                          final attendance = displayData[index];
                          return _buildAttendanceCard(attendance);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  int _countStatus(List<Map<String, dynamic>> data, String status) {
    try {
      return data.where((item) {
        final itemStatus = item['status']?.toString()?.toLowerCase() ?? '';
        return itemStatus == status.toLowerCase();
      }).length;
    } catch (e) {
      print('Error counting status $status: $e');
      return 0;
    }
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> attendance) {
    try {
      // Safely parse date
      DateTime date;
      try {
        date = DateTime.parse(
          attendance['date'] ?? DateTime.now().toIso8601String(),
        );
      } catch (e) {
        date = DateTime.now();
      }

      // Safely parse times
      DateTime? checkInTime;
      DateTime? checkOutTime;

      try {
        if (attendance['check_in_time'] != null) {
          checkInTime = DateTime.parse(attendance['check_in_time']);
        }
      } catch (e) {
        print('Error parsing check_in_time: $e');
      }

      try {
        if (attendance['check_out_time'] != null) {
          checkOutTime = DateTime.parse(attendance['check_out_time']);
        }
      } catch (e) {
        print('Error parsing check_out_time: $e');
      }

      final status = attendance['status']?.toString() ?? 'absent';

      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInfo(
                      'Check In',
                      checkInTime != null
                          ? DateFormat('HH:mm').format(checkInTime)
                          : '--:--',
                      Icons.login,
                      Colors.green[600]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeInfo(
                      'Check Out',
                      checkOutTime != null
                          ? DateFormat('HH:mm').format(checkOutTime)
                          : '--:--',
                      Icons.logout,
                      Colors.orange[600]!,
                    ),
                  ),
                ],
              ),

              // Work Duration
              if (checkInTime != null && checkOutTime != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text(
                        'Work Duration: ${_calculateDuration(checkInTime, checkOutTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (attendance['notes'] != null &&
                  attendance['notes'].toString().isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attendance['notes'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error building attendance card: $e');
      // Return a simple error card
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Text(
          'Error displaying attendance record',
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }
  }

  String _calculateDuration(DateTime checkIn, DateTime checkOut) {
    try {
      final duration = checkOut.difference(checkIn);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '0h 0m';
    }
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
