class AttendanceModel {
  final String id;
  final String userId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? notes;
  final String status;
  final Duration? workDuration;

  AttendanceModel({
    required this.id,
    required this.userId,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.notes,
    required this.status,
    this.workDuration,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      checkInTime:
          json['check_in_time'] != null
              ? DateTime.parse(json['check_in_time'])
              : null,
      checkOutTime:
          json['check_out_time'] != null
              ? DateTime.parse(json['check_out_time'])
              : null,
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      checkInLatitude: json['check_in_latitude']?.toDouble(),
      checkInLongitude: json['check_in_longitude']?.toDouble(),
      checkOutLatitude: json['check_out_latitude']?.toDouble(),
      checkOutLongitude: json['check_out_longitude']?.toDouble(),
      notes: json['notes'],
      status: json['status'] ?? 'absent',
    );
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  Duration get calculatedWorkDuration {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return Duration.zero;
  }

  String get formattedWorkDuration {
    final duration = calculatedWorkDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
