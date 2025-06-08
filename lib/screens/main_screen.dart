// lib/screens/main_screen.dart - Complete implementation
import 'package:flutter/material.dart';
import 'package:t_absensi/screens/camera_screen.dart';
import 'package:t_absensi/services/api_services.dart';
import '../services/wifi_service.dart';
import '../services/location_service.dart';

import '../utils/date_utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';
import 'login_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_request_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLoading = true;
  bool isCheckingIn = false;
  bool isCheckingOut = false;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? todayStatus;
  String connectionStatus = 'Testing...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load user data
      final user = await ApiService.getUserData();

      // Test connection
      final connectionTest = await ApiService.testConnection();

      // Get today's status
      final todayResponse = await ApiService.getTodayStatus();

      setState(() {
        userData = user;
        connectionStatus =
            connectionTest['success']
                ? '✅ Connected'
                : '❌ ${connectionTest['message']}';

        if (todayResponse['success']) {
          todayStatus = todayResponse['data'];
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        connectionStatus = '❌ Error loading data';
      });
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() {
      isCheckingIn = true;
    });

    try {
      // Get location
      _showLoadingDialog('Getting location...');
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        Navigator.pop(context);
        _showErrorSnackBar(
          'Unable to get location. Please enable location services.',
        );
        return;
      }

      // Get WiFi info
      Navigator.pop(context);
      _showLoadingDialog('Getting WiFi information...');
      final wifiInfo = await WiFiService.getWiFiInfo();

      // Take photo
      Navigator.pop(context);
      final photo = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder:
              (context) => CameraScreen(
                title: 'Check-in Photo',
                subtitle: 'Take a photo for check-in verification',
              ),
        ),
      );

      if (photo == null) {
        _showErrorSnackBar('Photo is required for check-in');
        return;
      }

      // Send check-in request
      _showLoadingDialog('Processing check-in...');
      final response = await ApiService.checkIn(
        wifiSsid: wifiInfo['ssid'] ?? 'Unknown',
        wifiAddress: wifiInfo['bssid'] ?? 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: '123123',
        notes: 'Mobile check-in',
      );

      Navigator.pop(context);

      if (response['success']) {
        _showSuccessSnackBar('Check-in successful!');
        await _loadData(); // Refresh data
      } else {
        _showErrorSnackBar(response['message'] ?? 'Check-in failed');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Check-in failed: $e');
    } finally {
      setState(() {
        isCheckingIn = false;
      });
    }
  }

  Future<void> _handleCheckOut() async {
    setState(() {
      isCheckingOut = true;
    });

    try {
      // Get location
      _showLoadingDialog('Getting location...');
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        Navigator.pop(context);

        _showErrorSnackBar(
          'Unable to get location. Please enable location services.',
        );
        LocationService.requestLocationPermission();
        return;
      }

      // Get WiFi info
      Navigator.pop(context);
      _showLoadingDialog('Getting WiFi information...');
      final wifiInfo = await WiFiService.getWiFiInfo();

      // Take photo
      Navigator.pop(context);
      // final photo = await Navigator.push<String>(
      //   context,
      //   MaterialPageRoute(
      //     builder:
      //         (context) => CameraScreen(
      //           title: 'Check-out Photo',
      //           subtitle: 'Take a photo for check-out verification',
      //         ),
      //   ),
      // );

      // if (photo == null) {
      //   _showErrorSnackBar('Photo is required for check-out');
      //   return;
      // }

      // Send check-out request
      _showLoadingDialog('Processing check-out...');
      final response = await ApiService.checkOut(
        wifiSsid: wifiInfo['ssid'] ?? 'Unknown',
        wifiAddress: wifiInfo['bssid'] ?? 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: '123123',
        notes: 'Mobile check-out',
      );

      Navigator.pop(context);

      if (response['success']) {
        _showSuccessSnackBar('Check-out successful!');
        await _loadData(); // Refresh data
      } else {
        _showErrorSnackBar(response['message'] ?? 'Check-out failed');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Check-out failed: $e');
    } finally {
      setState(() {
        isCheckingOut = false;
      });
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ApiService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
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
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    final hasCheckedIn = todayStatus?['check_in_time'] != null;
    final hasCheckedOut = todayStatus?['check_out_time'] != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance App'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      connectionStatus.contains('✅')
                          ? Colors.green[50]
                          : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        connectionStatus.contains('✅')
                            ? Colors.green[200]!
                            : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      connectionStatus.contains('✅')
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color:
                          connectionStatus.contains('✅')
                              ? Colors.green[600]
                              : Colors.red[600],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Server: $connectionStatus',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // User Greeting Card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[800]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Text(
                            userData?['name']?.substring(0, 1)?.toUpperCase() ??
                                'U',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${DateTimeUtils.getGreeting()}!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                userData?['name'] ?? 'User',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      DateTimeUtils.formatDate(DateTime.now()),
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Today's Status
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
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
                        StatusBadge(status: todayStatus?['status'] ?? 'absent'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeCard(
                            'Check In',
                            todayStatus?['check_in_time'] != null
                                ? DateTimeUtils.formatTime(
                                  DateTime.parse(todayStatus!['check_in_time']),
                                )
                                : '--:--',
                            Icons.login,
                            hasCheckedIn ? Colors.green : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeCard(
                            'Check Out',
                            todayStatus?['check_out_time'] != null
                                ? DateTimeUtils.formatTime(
                                  DateTime.parse(
                                    todayStatus!['check_out_time'],
                                  ),
                                )
                                : '--:--',
                            Icons.logout,
                            hasCheckedOut ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Action Buttons
              if (!hasCheckedIn) ...[
                CustomButton(
                  text: 'Check In',
                  icon: Icons.login,
                  onPressed: isCheckingIn ? null : _handleCheckIn,
                  isLoading: isCheckingIn,
                  backgroundColor: Colors.green[600],
                ),
              ] else if (!hasCheckedOut) ...[
                CustomButton(
                  text: 'Check Out',
                  icon: Icons.logout,
                  onPressed: isCheckingOut ? null : _handleCheckOut,
                  isLoading: isCheckingOut,
                  backgroundColor: Colors.orange[600],
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Work completed for today!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Attendance History',
                      Icons.history,
                      Colors.blue[600]!,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'Leave Request',
                      Icons.event_busy,
                      Colors.purple[600]!,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveRequestScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String time, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
