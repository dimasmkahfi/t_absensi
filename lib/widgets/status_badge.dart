import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({Key? key, required this.status, this.fontSize = 12})
    : super(key: key);

  Color get backgroundColor {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green[100]!;
      case 'late':
        return Colors.orange[100]!;
      case 'absent':
        return Colors.red[100]!;
      case 'permission':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color get textColor {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green[700]!;
      case 'late':
        return Colors.orange[700]!;
      case 'absent':
        return Colors.red[700]!;
      case 'permission':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String get displayText {
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
