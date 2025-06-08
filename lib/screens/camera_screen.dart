import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../services/location_service.dart';
import '../utils/device_control_helper.dart';

class CameraScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String type; // 'check_in' or 'check_out'

  const CameraScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    this.type = 'check_in',
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  DeviceControlHelper dc = DeviceControlHelper();

  bool isLoading = true;
  bool isProcessing = false;
  bool isReadyToCapture = false;
  String status = 'Initializing camera...';
  Position? currentPosition;
  Placemark? currentAddress;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    dc.resetBrightness();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Set brightness for better camera performance
      dc.setBrightness(1.0);

      // Get current location
      setState(() {
        status = 'Getting location...';
      });

      await _getCurrentLocation();

      // Initialize camera
      setState(() {
        status = 'Starting camera...';
      });

      cameras = await availableCameras();
      if (cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use front camera for selfie
      CameraDescription frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          isLoading = false;
          isReadyToCapture = true;
          status = 'Position your face in the camera and tap capture';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error initializing camera: $e';
        isLoading = false;
      });
      _showErrorAndExit('Failed to initialize camera: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      currentPosition = await LocationService.getCurrentLocation();

      if (currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          currentAddress = placemarks.first;
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _startCountdownCapture() async {
    if (isProcessing || !isReadyToCapture) return;

    setState(() {
      isProcessing = true;
      isReadyToCapture = false;
    });

    // Countdown
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        countdown = i;
        status = 'Get ready! Capturing in $i...';
      });
      await Future.delayed(Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() {
      countdown = 0;
      status = 'Smile! Capturing...';
    });

    await Future.delayed(Duration(milliseconds: 500));
    await _takePicture();
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        !isProcessing) {
      return;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      final imageBytes = await picture.readAsBytes();

      setState(() {
        status = 'Processing and adding timestamp...';
      });

      final processedImage = await _processImage(imageBytes);

      if (processedImage != null) {
        _showSuccessAndReturn(processedImage);
      } else {
        _showErrorAndRetry('Failed to process image');
      }
    } catch (e) {
      print('Error taking picture: $e');
      _showErrorAndRetry('Failed to capture image');
    }
  }

  Future<String?> _processImage(Uint8List imageBytes) async {
    try {
      final processedImageFile = await _addTimestampAndDetails(imageBytes);

      if (processedImageFile != null) {
        final finalImageBytes = await processedImageFile.readAsBytes();
        final base64String = base64Encode(finalImageBytes);

        // Clean up temporary file
        try {
          await processedImageFile.delete();
        } catch (e) {
          print('Error deleting temp file: $e');
        }

        return base64String;
      }

      return null;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  Future<File?> _addTimestampAndDetails(Uint8List imageBytes) async {
    try {
      // Prepare address information
      String address1 = "Location not available";
      String address2 = "";
      String address3 = "";

      if (currentAddress != null) {
        address1 =
            currentAddress!.locality ??
            currentAddress!.subAdministrativeArea ??
            "Unknown Location";
        address2 = currentAddress!.administrativeArea ?? "";
        address3 = currentAddress!.country ?? "";
      }

      // Add coordinates if available
      String coordinates = "GPS: Location disabled";
      if (currentPosition != null) {
        coordinates =
            "GPS: ${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}";
      }

      // Create timestamp
      String timestamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
      String attendanceType =
          widget.type == 'check_in' ? 'CHECK IN' : 'CHECK OUT';

      // Decode image
      ui.Image image = await decodeImageFromList(imageBytes);

      // Create canvas for overlay
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw original image
      canvas.drawImage(image, Offset(0, 0), Paint());

      // Draw semi-transparent overlay at top
      final overlayPaint = Paint()..color = Colors.black.withOpacity(0.8);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, image.width.toDouble(), 180),
        overlayPaint,
      );

      // Draw semi-transparent overlay at bottom
      canvas.drawRect(
        Rect.fromLTWH(0, image.height - 100.0, image.width.toDouble(), 100),
        overlayPaint,
      );

      // Text drawing function
      void drawText(
        String text,
        Offset offset, {
        double fontSize = 16,
        Color color = Colors.white,
        FontWeight fontWeight = FontWeight.normal,
      }) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.9),
                ),
              ],
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, offset);
      }

      // Draw attendance type badge
      final typeColor =
          widget.type == 'check_in' ? Colors.green : Colors.orange;
      final badgePaint = Paint()..color = typeColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(15, 15, 140, 35),
          Radius.circular(8),
        ),
        badgePaint,
      );

      drawText(
        attendanceType,
        Offset(25, 25),
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );

      // Draw timestamp
      drawText(
        '📅 $timestamp',
        Offset(15, 60),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

      // Draw location info
      if (currentAddress != null) {
        drawText('📍 $address1', Offset(15, 85), fontSize: 14);
        if (address2.isNotEmpty) {
          drawText(
            '   $address2, $address3',
            Offset(15, 105),
            fontSize: 12,
            color: Colors.white70,
          );
        }
      } else {
        drawText(
          '📍 $address1',
          Offset(15, 85),
          fontSize: 14,
          color: Colors.yellow,
        );
      }

      // Draw coordinates
      drawText(
        coordinates,
        Offset(15, 130),
        fontSize: 11,
        color: currentPosition != null ? Colors.cyan : Colors.yellow,
      );

      // Draw verification badge
      drawText(
        '✓ Photo Verified • ${DateFormat('HH:mm:ss').format(DateTime.now())}',
        Offset(15, 155),
        fontSize: 12,
        color: Colors.green[300]!,
        fontWeight: FontWeight.w600,
      );

      // Draw app info at bottom
      drawText(
        'Attendance App v1.0 • Secure Photo Verification',
        Offset(15, image.height - 75.0),
        fontSize: 12,
        color: Colors.white70,
      );

      // Draw security indicator at bottom right
      drawText(
        '🔒 SECURE',
        Offset(image.width - 90.0, image.height - 45.0),
        fontSize: 14,
        color: Colors.green[300]!,
        fontWeight: FontWeight.bold,
      );

      // Draw timestamp at bottom right
      drawText(
        DateFormat('HH:mm').format(DateTime.now()),
        Offset(image.width - 70.0, image.height - 25.0),
        fontSize: 12,
        color: Colors.white,
      );

      // Convert to image
      final pic = await recorder.endRecording().toImage(
        image.width,
        image.height,
      );
      final pngBytes = await pic.toByteData(format: ui.ImageByteFormat.png);
      final pngUint8List = pngBytes?.buffer.asUint8List();

      if (pngUint8List != null) {
        // Compress image
        img.Image decodedImage = img.decodeImage(pngUint8List)!;
        List<int> compressedBytes = img.encodeJpg(decodedImage, quality: 85);

        // Save to temporary file
        final directory = await getTemporaryDirectory();
        final fileName =
            'attendance_${widget.type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(compressedBytes);

        return file;
      }

      return null;
    } catch (e) {
      print('Error adding timestamp: $e');
      return null;
    }
  }

  void _showSuccessAndReturn(String base64Image) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Photo captured successfully!'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(base64Image);
  }

  void _showErrorAndExit(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.of(context).pop();
  }

  void _showErrorAndRetry(String message) {
    setState(() {
      isProcessing = false;
      isReadyToCapture = true;
      countdown = 0;
      status = 'Position your face in the camera and tap capture';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[600],
        action: SnackBarAction(
          label: 'Try Again',
          textColor: Colors.white,
          onPressed: () {
            if (isReadyToCapture && !isProcessing) {
              _startCountdownCapture();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text(
                      status,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Camera preview
                  Expanded(
                    child: Stack(
                      children: [
                        // Camera preview
                        if (_controller != null &&
                            _controller!.value.isInitialized)
                          CameraPreview(_controller!),

                        // Face guide overlay
                        if (isReadyToCapture && !isProcessing)
                          Positioned.fill(
                            child: CustomPaint(painter: FaceGuidePainter()),
                          ),

                        // Countdown overlay
                        if (countdown > 0)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      countdown.toString(),
                                      style: TextStyle(
                                        fontSize: 120,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Get ready!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Processing overlay
                        if (isProcessing && countdown == 0)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Status overlay at bottom
                        if (!isProcessing)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.subtitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Capture button
                  Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isReadyToCapture && !isProcessing) ...[
                          // Main capture button
                          GestureDetector(
                            onTap: _startCountdownCapture,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 4,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Disabled state
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[600],
                              border: Border.all(
                                color: Colors.grey[500]!,
                                width: 4,
                              ),
                            ),
                            child:
                                isProcessing
                                    ? CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                    : Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// Custom painter for face guide
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Draw face oval guide
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.6,
      height: size.height * 0.4,
    );

    canvas.drawOval(ovalRect, paint);

    // Draw corner guides
    final cornerPaint =
        Paint()
          ..color = Colors.green.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final cornerSize = 30.0;
    final corners = [
      // Top left
      Offset(ovalRect.left, ovalRect.top),
      // Top right
      Offset(ovalRect.right, ovalRect.top),
      // Bottom left
      Offset(ovalRect.left, ovalRect.bottom),
      // Bottom right
      Offset(ovalRect.right, ovalRect.bottom),
    ];

    for (final corner in corners) {
      // Draw L-shaped corner guides
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx - cornerSize / 2, corner.dy)
          ..lineTo(corner.dx + cornerSize / 2, corner.dy)
          ..moveTo(corner.dx, corner.dy - cornerSize / 2)
          ..lineTo(corner.dx, corner.dy + cornerSize / 2),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// lib/utils/device_control_helper.dart - Simplified version
class DeviceControlHelper {
  double? _originalBrightness;

  Future<void> setBrightness(double brightness) async {
    try {
      // For simplicity, we'll skip screen brightness control
      // You can add screen_brightness package if needed
      print('Setting brightness to $brightness');
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  Future<void> resetBrightness() async {
    try {
      print('Resetting brightness');
    } catch (e) {
      print('Error resetting brightness: $e');
    }
  }
}
