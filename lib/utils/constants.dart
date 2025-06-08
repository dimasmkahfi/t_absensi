// utils/constants.dart

class AppConstants {
  // API Configuration
  // static const String baseUrl = 'https://your-api-url.com/api';
  String faceRecognitionUrl = 'https://your-face-api-url.com';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/user/profile';
  static const String checkinEndpoint = '/attendance/checkin';
  static const String checkoutEndpoint = '/attendance/checkout';
  static const String attendanceHistoryEndpoint = '/attendance/history';
  static const String leaveRequestEndpoint = '/leave/request';
  static const String leaveHistoryEndpoint = '/leave/history';
  static const String faceVerifyEndpoint = '/face/verify';

  // App Settings
  static const String appName = 'Attendance App';
  static const String appVersion = '1.0.0';
  static const int requestTimeout = 30; // seconds

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String lastSyncKey = 'last_sync';
  static const String settingsKey = 'app_settings';

  // Shift Types
  static const List<String> shiftTypes = [
    'Morning Shift',
    'Afternoon Shift',
    'Night Shift',
  ];

  // Leave Types
  static const List<String> leaveTypes = ['Cuti', 'Izin', 'Sakit'];

  // Status Types
  static const List<String> attendanceStatus = [
    'Present',
    'Absent',
    'Late',
    'Early Leave',
  ];

  static const List<String> leaveStatus = ['Pending', 'Approved', 'Rejected'];

  // Report Periods
  static const List<String> reportPeriods = [
    'This Week',
    'This Month',
    'Last Month',
    'Custom',
  ];

  // Face Recognition Settings
  static const double faceMatchThreshold = 0.65;
  static const int maxFaceDetectionRetries = 3;
  static const int faceImageQuality = 80;

  // Work Hours
  static const Map<String, Map<String, String>> shiftHours = {
    'Morning Shift': {'start': '08:00', 'end': '17:00'},
    'Afternoon Shift': {'start': '14:00', 'end': '23:00'},
    'Night Shift': {'start': '22:00', 'end': '07:00'},
  };

  // Error Messages
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String noFaceDetected = 'No face detected. Please try again.';
  static const String faceNotRecognized =
      'Face not recognized. Please try again.';
  static const String invalidCredentials =
      'Invalid credentials. Please check your login details.';

  // Success Messages
  static const String checkinSuccess = 'Check-in successful!';
  static const String checkoutSuccess = 'Check-out successful!';
  static const String leaveRequestSuccess =
      'Leave request submitted successfully!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
}
