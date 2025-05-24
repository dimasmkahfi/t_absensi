// utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background Colors
  static const Color background = grey50;
  static const Color surface = white;
  static const Color cardBackground = white;

  // Text Colors
  static const Color textPrimary = grey800;
  static const Color textSecondary = grey600;
  static const Color textHint = grey400;
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = white;

  // Border Colors
  static const Color borderLight = grey200;
  static const Color borderMedium = grey300;
  static const Color borderDark = grey400;

  // Shadow Colors
  static Color shadowLight = grey400.withOpacity(0.1);
  static Color shadowMedium = grey400.withOpacity(0.2);
  static Color shadowDark = grey400.withOpacity(0.3);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successDark, success],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningDark, warning],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorDark, error],
  );

  // Special Colors for Features
  static const Color checkIn = success;
  static const Color checkOut = error;
  static const Color leave = warning;
  static const Color present = success;
  static const Color absent = error;
  static const Color late = warning;

  // Status Color Map
  static const Map<String, Color> statusColors = {
    'present': success,
    'absent': error,
    'late': warning,
    'early_leave': warning,
    'approved': success,
    'pending': warning,
    'rejected': error,
  };

  // Get color by status
  static Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? grey500;
  }

  // Get light version of color
  static Color getLightColor(Color color, [double opacity = 0.1]) {
    return color.withOpacity(opacity);
  }
}
