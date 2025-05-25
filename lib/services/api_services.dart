// lib/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static late Dio _dio;
  static const String baseUrl = 'http://localhost/absen-api/api/mobile';

  // Initialize Dio with interceptors
  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests automatically
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR: ${error.response?.statusCode} ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      final response = await _dio.post('/login', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          // Save token and user data
          await saveToken(data['token']);
          await saveUserData(data['user']);

          return {'success': true, 'message': 'Login successful', 'data': data};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        return {'success': false, 'message': 'Server error. Please try again.'};
      }
    } on DioException catch (e) {
      return {'success': false, 'message': _handleDioError(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  static Future<Map<String, dynamic>> validateToken() async {
    try {
      final response = await _dio.get('/profile');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Token validation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Token validation failed'};
    }
  }

  // Data Storage Methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', userData.toString());
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Get today's status
  static Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final response = await _dio.get('/today-status');
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Check-in
  static Future<Map<String, dynamic>> checkIn({
    required String wifiSsid,
    required String wifiAddress,
    required double latitude,
    required double longitude,
    String? photoBase64,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/check-in',
        data: {
          'wifi_ssid': wifiSsid,
          'wifi_address': wifiAddress,
          'latitude': latitude,
          'longitude': longitude,
          'photo': photoBase64,
          'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Check-out
  static Future<Map<String, dynamic>> checkOut({
    required String wifiSsid,
    required String wifiAddress,
    required double latitude,
    required double longitude,
    String? photoBase64,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/check-out',
        data: {
          'wifi_ssid': wifiSsid,
          'wifi_address': wifiAddress,
          'latitude': latitude,
          'longitude': longitude,
          'photo': photoBase64,
          'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
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
      final response = await _dio.post(
        '/leave/submit',
        data: {
          'type': type.toLowerCase(), // Convert to match API (cuti/izin/sakit)
          'start_date': startDate,
          'end_date': endDate,
          'reason': reason,
          'attachment': attachmentBase64,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Get leave history
  static Future<Map<String, dynamic>> getLeaveHistory() async {
    try {
      final response = await _dio.get('/leave/history');
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Get attendance history
  static Future<Map<String, dynamic>> getAttendanceHistory({
    int? month,
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        '/attendance-history',
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/logout');

      // Clear local storage regardless of response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      return response.data;
    } on DioException catch (e) {
      // Still clear local storage even if logout API fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      return _handleDioError(e);
    }
  }

  // Handle Dio errors
  static Map<String, dynamic> _handleDioError(DioException e) {
    String message = 'Network error occurred';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          // Try to extract error message from API response
          final responseData = e.response!.data;
          if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'];
          } else {
            message = 'Server error (${e.response!.statusCode})';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'Network error. Please check your connection.';
        break;
      default:
        message = 'An unexpected error occurred';
    }

    return {
      'success': false,
      'message': message,
      'status_code': e.response?.statusCode,
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
