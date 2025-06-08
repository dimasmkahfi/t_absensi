// lib/screens/profile_screen.dart - Fixed with correct API parsing
import 'package:flutter/material.dart';
import 'package:t_absensi/services/api_services.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_stats.dart';
import '../widgets/settings_menu.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? profileStats;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load user data from storage
      final user = await ApiService.getUserData();

      // Try to get fresh profile data from server
      final profileResponse = await ApiService.getProfile();

      // Get attendance stats for current month
      final now = DateTime.now();
      final attendanceResponse =
          await ApiService.getAttendanceHistoryWithFallback(
            month: now.month,
            year: now.year,
          );

      print('📊 Profile - User data: $user');
      print('📊 Profile - Profile response: $profileResponse');
      print('📊 Profile - Attendance response: $attendanceResponse');

      setState(() {
        userData = user;

        // Merge server data if available
        if (profileResponse['success'] && profileResponse['data'] != null) {
          userData = {...?userData, ...?profileResponse['data']};
        }

        // Calculate stats from attendance data
        if (attendanceResponse['success']) {
          profileStats = _calculateStatsFromResponse(
            attendanceResponse['data'],
          );
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: $e';
      });
      print('🚨 Error loading profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateStatsFromResponse(dynamic attendanceData) {
    try {
      print('📊 Calculating stats from: $attendanceData');
      print('📊 Data type: ${attendanceData.runtimeType}');

      List<dynamic> attendances = [];

      // Handle different response structures
      if (attendanceData is Map<String, dynamic>) {
        // Check if it's wrapped in a data object
        if (attendanceData.containsKey('attendances')) {
          attendances = attendanceData['attendances'] as List<dynamic>;
        } else if (attendanceData.containsKey('data')) {
          final data = attendanceData['data'];
          if (data is List) {
            attendances = data;
          } else if (data is Map && data.containsKey('attendances')) {
            attendances = data['attendances'] as List<dynamic>;
          }
        } else {
          // Single attendance record
          attendances = [attendanceData];
        }
      } else if (attendanceData is List) {
        attendances = attendanceData;
      }

      print('📊 Processing ${attendances.length} attendance records');

      if (attendances.isEmpty) {
        return {
          'presentDays': 0,
          'totalHours': 0.0,
          'avgHours': 0.0,
          'lateCount': 0,
          'totalDays': 0,
        };
      }

      int presentDays = 0;
      int lateCount = 0;
      double totalHours = 0.0;
      int totalWorkingDays = 0;

      for (var attendance in attendances) {
        if (attendance is Map<String, dynamic>) {
          final status = attendance['status']?.toString().toLowerCase() ?? '';
          final isWeekend = attendance['is_weekend'] == true;

          print(
            '📅 Processing: ${attendance['date']} - Status: $status, Weekend: $isWeekend',
          );

          // Only count working days (not weekends)
          if (!isWeekend) {
            totalWorkingDays++;

            if (status == 'present' || status == 'late') {
              presentDays++;

              if (status == 'late') {
                lateCount++;
              }

              // Calculate work hours
              try {
                double workHours = 0.0;

                // Try to get work_hours field first
                if (attendance['work_hours'] != null) {
                  final workHoursStr = attendance['work_hours'].toString();
                  if (workHoursStr != 'null' && workHoursStr.isNotEmpty) {
                    workHours = double.parse(workHoursStr);
                  }
                }

                // Fallback: calculate from check_in and check_out times
                if (workHours == 0.0 &&
                    attendance['check_in'] != null &&
                    attendance['check_out'] != null) {
                  final date =
                      attendance['date'] ??
                      DateTime.now().toString().split(' ')[0];
                  final checkInStr = '${date} ${attendance['check_in']}';
                  final checkOutStr = '${date} ${attendance['check_out']}';

                  final checkIn = DateTime.parse(checkInStr);
                  final checkOut = DateTime.parse(checkOutStr);
                  final duration = checkOut.difference(checkIn);
                  workHours = duration.inMinutes / 60.0;
                }

                totalHours += workHours;
                print('📊 Work hours for ${attendance['date']}: $workHours');
              } catch (e) {
                print(
                  '❌ Error calculating work hours for ${attendance['date']}: $e',
                );
              }
            }
          }
        }
      }

      final avgHours = presentDays > 0 ? (totalHours / presentDays) : 0.0;

      final stats = {
        'presentDays': presentDays,
        'totalHours': totalHours,
        'avgHours': avgHours,
        'lateCount': lateCount,
        'totalDays': totalWorkingDays,
        'attendanceRate':
            totalWorkingDays > 0
                ? ((presentDays / totalWorkingDays) * 100)
                : 0.0,
      };

      print('📊 Calculated stats: $stats');
      return stats;
    } catch (e) {
      print('🚨 Error calculating stats: $e');
      return {
        'presentDays': 0,
        'totalHours': 0.0,
        'avgHours': 0.0,
        'lateCount': 0,
        'totalDays': 0,
        'attendanceRate': 0.0,
      };
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600]),
                SizedBox(width: 12),
                Text('Logout'),
              ],
            ),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Logging out...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  await ApiService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadProfileData),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading profile...'),
                  ],
                ),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfileData,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadProfileData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileHeader(userData: userData),
                      SizedBox(height: 20),
                      ProfileInfo(userData: userData),
                      SizedBox(height: 20),
                      ProfileStats(stats: profileStats),
                      SizedBox(height: 20),
                      SettingsMenu(onLogout: _handleLogout),
                    ],
                  ),
                ),
              ),
    );
  }
}
