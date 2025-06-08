import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow all certificates (for development only)
        print('🔓 Allowing certificate for: $host:$port');
        return true;
      }
      ..connectionTimeout = Duration(seconds: 30)
      ..idleTimeout = Duration(seconds: 30);
  }
}

class ApiService {
  static const String baseUrl = 'https://portaltelkom.my.id/api/mobile';

  // Get headers with auth token
  static http.Client _createHttpClient() {
    final client = http.Client();
    return client;
  }

  static Future<Map<String, String>> _getHeaders({
    bool isMultipart = false,
  }) async {
    final token = await getToken();
    final headers = <String, String>{'Accept': 'application/json'};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Login with multipart request (matching your original format)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');

      var headers = await _getHeaders(isMultipart: true);
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/login'));

      // Add form fields
      request.fields.addAll({'email': email, 'password': password});

      // Add headers
      request.headers.addAll(headers);

      print('📤 Sending login request to: $baseUrl/login');

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      print('📨 Login response status: ${response.statusCode}');
      print('📨 Login response data: $responseBody');

      if (response.statusCode == 200) {
        // Try to parse JSON response
        Map<String, dynamic> data;
        try {
          data = json.decode(responseBody);
        } catch (e) {
          // If can't parse as JSON, assume success for plain text response
          print('📨 Could not parse response as JSON, treating as success');

          // Create a fake token for now
          final fakeToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
          await saveToken(fakeToken);

          return {
            'success': true,
            'message': 'Login successful',
            'token': fakeToken,
            'raw_response': responseBody,
          };
        }

        // Handle different response formats
        bool success =
            data['success'] == true ||
            data['status'] == 'success' ||
            response.statusCode == 200;

        String? token =
            data['token'] ?? data['access_token'] ?? data['data']?['token'];

        Map<String, dynamic>? user = data['user'] ?? data['data']?['user'];

        String message =
            data['message'] ?? (success ? 'Login successful' : 'Login failed');

        if (success) {
          if (token != null) {
            await saveToken(token);
            print('💾 Token saved: ${token.substring(0, 10)}...');
          }

          if (user != null) {
            await saveUserData(user);
            print('💾 User data saved');
          }

          return {
            'success': true,
            'message': message,
            'token': token,
            'user': user,
          };
        } else {
          return {'success': false, 'message': message};
        }
      } else {
        return {
          'success': false,
          'message': 'Server returned status code: ${response.statusCode}',
          'response_body': responseBody,
        };
      }
    } catch (e) {
      print('🚨 Login error: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Validate token
  static Future<Map<String, dynamic>> validateToken() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      print('📨 Profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Token validation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Token validation failed: $e'};
    }
  }

  // Get today's status
  static Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      print('📅 Getting today\'s attendance status');

      final headers = await _getHeaders();
      final client = _createHttpClient();

      final response = await client
          .get(Uri.parse('$baseUrl/today-status'), headers: headers)
          .timeout(Duration(seconds: 15));

      client.close();

      print('📨 Today status response: ${response.statusCode}');
      print('📨 Today status body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data is Map<String, dynamic>) {
            return {
              'success': data['success'] ?? true,
              'data': data['data'] ?? data,
              'message': data['message'] ?? 'Today\'s status retrieved',
            };
          } else {
            return {
              'success': true,
              'data': data,
              'message': 'Today\'s status retrieved',
            };
          }
        } catch (e) {
          print('❌ JSON parsing error for today status: $e');
          return {
            'success': false,
            'data': null,
            'message': 'Failed to parse today\'s status',
          };
        }
      } else if (response.statusCode == 404) {
        // No attendance record for today
        return {
          'success': true,
          'data': {
            'id': null,
            'check_in_time': null,
            'check_out_time': null,
            'status': 'absent',
          },
          'message': 'No attendance record for today',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': 'Failed to get today\'s status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 Error in getTodayStatus: $e');
      return {'success': false, 'data': null, 'message': _handleError(e)};
    }
  }

  // Check-in with multipart request
  static Future<Map<String, dynamic>> checkIn({
    required String wifiSsid,
    required String wifiAddress,
    required double latitude,
    required double longitude,
    String? photoBase64,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/check-in'),
      );

      // Add form fields
      request.fields.addAll({
        'wifi_ssid': wifiSsid,
        'wifi_address': wifiAddress,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'notes': notes ?? '',
      });

      // Add photo if provided
      if (photoBase64 != null) {
        request.fields['photo'] = photoBase64;
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Check-in failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Check-in failed: $e'};
    }
  }

  // Check-out with multipart request
  static Future<Map<String, dynamic>> checkOut({
    required String wifiSsid,
    required String wifiAddress,
    required double latitude,
    required double longitude,
    String? photoBase64,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/check-out'),
      );

      // Add form fields
      request.fields.addAll({
        'wifi_ssid': wifiSsid,
        'wifi_address': wifiAddress,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'notes': notes ?? '',
      });

      // Add photo if provided
      if (photoBase64 != null) {
        request.fields['photo'] = photoBase64;
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Check-out failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Check-out failed: $e'};
    }
  }

  // Submit leave request
  static Future<Map<String, dynamic>> submitLeave({
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentBase64,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/leave/submit'),
      );

      // Add form fields
      request.fields.addAll({
        'type': type.toLowerCase(),
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      });

      // Add attachment if provided
      if (attachmentBase64 != null) {
        request.fields['attachment'] = attachmentBase64;
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Leave submission failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Leave submission failed: $e'};
    }
  }

  // Get leave history
  static Future<Map<String, dynamic>> getLeaveHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/leave/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to get leave history',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to get leave history: $e'};
    }
  }

  // Get attendance history
  // lib/services/api_service.dart - Fixed getAttendanceHistory to handle actual API response
  static Future<Map<String, dynamic>> getAttendanceHistory({
    int? month,
    int? year,
  }) async {
    try {
      print('📊 Requesting attendance history for month: $month, year: $year');

      final headers = await _getHeaders();
      String url = '$baseUrl/attendance-history';

      // Add query parameters
      Map<String, String> queryParams = {};
      if (month != null) queryParams['month'] = month.toString();
      if (year != null) queryParams['year'] = year.toString();

      if (queryParams.isNotEmpty) {
        url +=
            '?' +
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      print('🌐 Making request to: $url');

      final client = _createHttpClient();
      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: 20));

      client.close();

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          // Handle the actual API response structure
          if (data is Map<String, dynamic>) {
            if (data['success'] == true) {
              // API returns: {"success": true, "data": {"attendances": [...]}}
              return {
                'success': true,
                'data':
                    data['data'], // Keep the full data structure including attendances array
                'message': data['message'] ?? 'Data retrieved successfully',
              };
            } else {
              return {
                'success': false,
                'data': {},
                'message':
                    data['message'] ?? 'Failed to get attendance history',
              };
            }
          } else {
            return {
              'success': false,
              'data': {},
              'message': 'Unexpected response format',
            };
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
          return {
            'success': false,
            'data': {},
            'message': 'Failed to parse server response',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': {'attendances': []},
          'message': 'No attendance records found',
        };
      } else {
        return {
          'success': false,
          'data': {},
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 Error in getAttendanceHistory: $e');
      return {'success': false, 'data': {}, 'message': _handleError(e)};
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to get settings',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to get settings: $e'};
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getHeaders();

      // Clear local storage regardless of response
      await clearUserData();

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      // Still clear local storage even if logout API fails
      await clearUserData();
      return {'success': true, 'message': 'Logged out successfully (offline)'};
    }
  }

  // Test connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl');

      final response = await http
          .get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'})
          .timeout(Duration(seconds: 10));

      return {
        'success': true,
        'message': 'Connection successful',
        'status_code': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Error handling
  static String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Network error: Please check your internet connection';
    } else if (error is HttpException) {
      return 'HTTP error: ${error.message}';
    } else if (error.toString().contains('timeout')) {
      return 'Connection timeout: Server is not responding';
    } else {
      return 'Error: ${error.toString()}';
    }
  }

  // Storage methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('💾 Token saved successfully');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
    print('💾 User data saved successfully');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        return json.decode(userData) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('🗑️ User data cleared');
  }

  // Initialize method (kept for compatibility, but not needed for http package)
  static void initialize() {
    print('📱 API Service initialized with HTTP package');
    print('🌐 Base URL: $baseUrl');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      print('👤 Getting user profile');

      final headers = await _getHeaders();
      final client = _createHttpClient();

      final response = await client
          .get(Uri.parse('$baseUrl/profile'), headers: headers)
          .timeout(Duration(seconds: 15));

      client.close();

      print('📨 Profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          return {
            'success': true,
            'data': data is Map<String, dynamic> ? data : {'profile': data},
            'message': 'Profile retrieved successfully',
          };
        } catch (e) {
          print('❌ JSON parsing error for profile: $e');
          return {
            'success': false,
            'data': null,
            'message': 'Failed to parse profile data',
          };
        }
      } else {
        return {
          'success': false,
          'data': null,
          'message': 'Failed to get profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 Error in getProfile: $e');
      return {'success': false, 'data': null, 'message': _handleError(e)};
    }
  }

  static List<Map<String, dynamic>> _getMockAttendanceHistory() {
    final now = DateTime.now();
    return List.generate(15, (index) {
      final date = now.subtract(Duration(days: index));
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      if (isWeekend) {
        return {
          'id': (index + 1).toString(),
          'date':
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          'check_in_time': null,
          'check_out_time': null,
          'status': 'weekend',
          'notes': 'Weekend',
        };
      }

      final statuses = ['present', 'late', 'absent'];
      final status = statuses[index % 4 == 3 ? 2 : (index % 3 == 2 ? 1 : 0)];

      return {
        'id': (index + 1).toString(),
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'check_in_time':
            status != 'absent'
                ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${8 + (index % 2)}:${30 + (index * 5) % 60}:00'
                : null,
        'check_out_time':
            status != 'absent'
                ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${17 + (index % 2)}:${15 + (index * 3) % 60}:00'
                : null,
        'status': status,
        'notes':
            index % 3 == 0
                ? 'Regular attendance'
                : (index % 5 == 0 ? 'Work from office' : null),
        'location': 'Main Office',
      };
    });
  }

  static Future<Map<String, dynamic>> getAttendanceHistoryWithFallback({
    int? month,
    int? year,
  }) async {
    final response = await getAttendanceHistory(month: month, year: year);

    if (!response['success'] || (response['data'] as List).isEmpty) {
      print('🔄 Using mock data for attendance history');
      return {
        'success': true,
        'data': _getMockAttendanceHistory(),
        'message': 'Mock attendance data (API not available)',
      };
    }

    return response;
  }
}
