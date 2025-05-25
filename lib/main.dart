import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_absensi/screens/splash_screen.dart';
import 'package:t_absensi/services/api_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  ApiService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[700],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
