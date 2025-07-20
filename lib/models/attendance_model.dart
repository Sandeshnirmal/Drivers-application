// Enhanced Attendance Model with Location Validation Support
import 'package:flutter/foundation.dart';

class Attendance {
  final int id;
  final int driverId;
  final String date;
  final String? assignedTime;
  final String? loginTime;
  final String? loginPhoto;
  final String? loginLatitude;
  final String? loginLongitude;
  final CheckinLocation? checkedInLocation;
  final String? logoutTime;
  final String? logoutPhoto;
  final String? logoutLatitude;
  final String? logoutLongitude;
  final String status;
  final String? reasonForDeduction;
  final double? deductAmount;
  final String? platform;
  final String createdAt;
  final String updatedAt;
  final double? activeTimeHours;

  Attendance({
    required this.id,
    required this.driverId,
    required this.date,
    this.assignedTime,
    this.loginTime,
    this.loginPhoto,
    this.loginLatitude,
    this.loginLongitude,
    this.checkedInLocation,
    this.logoutTime,
    this.logoutPhoto,
    this.logoutLatitude,
    this.logoutLongitude,
    required this.status,
    this.reasonForDeduction,
    this.deductAmount,
    this.platform,
    required this.createdAt,
    required this.updatedAt,
    this.activeTimeHours,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing Attendance - driver field type: ${json['driver'].runtimeType}');
    debugPrint('Parsing Attendance - driver field value: ${json['driver']}');
    return Attendance(
      id: json['id'] as int,
      driverId: json['driver'] is Map<String, dynamic>
          ? (json['driver'] as Map<String, dynamic>)['id'] as int
          : json['driver'] as int,
      date: json['date'] as String,
      assignedTime: json['assigned_time'] as String?,
      loginTime: json['login_time'] as String?,
      loginPhoto: json['login_photo'] as String?,
      loginLatitude: json['login_latitude'] as String?,
      loginLongitude: json['login_longitude'] as String?,
      checkedInLocation: json['checked_in_location'] != null
          ? CheckinLocation.fromJson(json['checked_in_location'] as Map<String, dynamic>)
          : null,
      logoutTime: json['logout_time'] as String?,
      logoutPhoto: json['logout_photo'] as String?,
      logoutLatitude: json['logout_latitude'] as String?,
      logoutLongitude: json['logout_longitude'] as String?,
      status: json['status'] as String,
      reasonForDeduction: json['reason_for_deduction'] as String?,
      deductAmount: (json['deduct_amount'] as num?)?.toDouble(),
      platform: json['platform'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      activeTimeHours: (json['active_time_hours'] as num?)?.toDouble(),
    );
  }

  bool get isLoggedIn => loginTime != null && logoutTime == null;
  bool get isLoggedOut => loginTime != null && logoutTime != null;
  bool get canCheckOut => isLoggedIn;
  bool get canCheckIn => !isLoggedIn;

  String get statusDisplayText {
    switch (status) {
      case 'logged_in':
        return 'Checked In';
      case 'logged_out':
        return 'Checked Out';
      case 'pending':
        return 'Pending';
      case 'absent':
        return 'Absent';
      case 'leave':
        return 'On Leave';
      default:
        return status.toUpperCase();
    }
  }
}

// Check-in Location Model
class CheckinLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final bool isActive;
  final bool isDriverSpecific;
  final String createdAt;

  CheckinLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.isDriverSpecific,
    required this.createdAt,
  });

  factory CheckinLocation.fromJson(Map<String, dynamic> json) {
    return CheckinLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      radiusMeters: json['radius_meters'] as int,
      isActive: json['is_active'] ?? true,
      isDriverSpecific: json['is_driver_specific'] ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'is_active': isActive,
      'is_driver_specific': isDriverSpecific,
      'created_at': createdAt,
    };
  }
}

// Enhanced Location Validation Models
class LocationValidation {
  final bool validated;
  final MatchedLocation? matchedLocation;
  final ValidationDetails? validationDetails;

  LocationValidation({
    required this.validated,
    this.matchedLocation,
    this.validationDetails,
  });

  factory LocationValidation.fromJson(Map<String, dynamic> json) {
    return LocationValidation(
      validated: json['validated'] ?? false,
      matchedLocation: json['matched_location'] != null
          ? MatchedLocation.fromJson(json['matched_location'])
          : null,
      validationDetails: json['validation_details'] != null
          ? ValidationDetails.fromJson(json['validation_details'])
          : null,
    );
  }
}

class MatchedLocation {
  final int? id;
  final String? name;
  final double? distanceFromCenter;
  final int? allowedRadius;

  MatchedLocation({
    this.id,
    this.name,
    this.distanceFromCenter,
    this.allowedRadius,
  });

  factory MatchedLocation.fromJson(Map<String, dynamic> json) {
    return MatchedLocation(
      id: json['id'],
      name: json['name'],
      distanceFromCenter: json['distance_from_center']?.toDouble(),
      allowedRadius: json['allowed_radius'],
    );
  }
}

class ValidationDetails {
  final String validationType;
  final String? locationName;
  final int? allowedRadius;
  final double? actualDistance;
  final double? accuracyPercentage;
  final int? allLocationsChecked;

  ValidationDetails({
    required this.validationType,
    this.locationName,
    this.allowedRadius,
    this.actualDistance,
    this.accuracyPercentage,
    this.allLocationsChecked,
  });

  factory ValidationDetails.fromJson(Map<String, dynamic> json) {
    return ValidationDetails(
      validationType: json['validation_type'] ?? '',
      locationName: json['location_name'],
      allowedRadius: json['allowed_radius'],
      actualDistance: json['actual_distance']?.toDouble(),
      accuracyPercentage: json['accuracy_percentage']?.toDouble(),
      allLocationsChecked: json['all_locations_checked'],
    );
  }
}

// Driver Status Model
class DriverStatus {
  final String driverId;
  final String driverName;
  final String date;
  final String status;
  final String message;
  final int? attendanceId;
  final String? loginTime;
  final String? logoutTime;
  final String? checkedInLocation;
  final bool canCheckIn;
  final bool canCheckOut;

  DriverStatus({
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.status,
    required this.message,
    this.attendanceId,
    this.loginTime,
    this.logoutTime,
    this.checkedInLocation,
    required this.canCheckIn,
    required this.canCheckOut,
  });

  factory DriverStatus.fromJson(Map<String, dynamic> json) {
    return DriverStatus(
      driverId: json['driver_id'].toString(),
      driverName: json['driver_name'],
      date: json['date'],
      status: json['status'],
      message: json['message'],
      attendanceId: json['attendance_id'],
      loginTime: json['login_time'],
      logoutTime: json['logout_time'],
      checkedInLocation: json['checked_in_location'],
      canCheckIn: json['can_check_in'] ?? false,
      canCheckOut: json['can_check_out'] ?? false,
    );
  }

  String get statusDisplayText {
    switch (status) {
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      case 'not_checked_in':
        return 'Not Checked In';
      case 'pending':
        return 'Pending';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}

// Enhanced API Response Models
class AttendanceResponse {
  final bool success;
  final String message;
  final Attendance? attendance;
  final LocationValidation? locationValidation;
  final CheckInDetails? checkInDetails;
  final WorkSession? workSession;
  final String? error;
  final Map<String, dynamic>? details;

  AttendanceResponse({
    required this.success,
    required this.message,
    this.attendance,
    this.locationValidation,
    this.checkInDetails,
    this.workSession,
    this.error,
    this.details,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      attendance: json['attendance'] != null
          ? Attendance.fromJson(json['attendance'])
          : null,
      locationValidation: json['location_validation'] != null
          ? LocationValidation.fromJson(json['location_validation'])
          : null,
      checkInDetails: json['check_in_details'] != null
          ? CheckInDetails.fromJson(json['check_in_details'])
          : null,
      workSession: json['work_session'] != null
          ? WorkSession.fromJson(json['work_session'])
          : null,
      error: json['error'],
      details: json['details'],
    );
  }
}

class CheckInDetails {
  final String time;
  final String date;
  final Map<String, double>? coordinates;
  final bool photoUploaded;
  final String platform;

  CheckInDetails({
    required this.time,
    required this.date,
    this.coordinates,
    required this.photoUploaded,
    required this.platform,
  });

  factory CheckInDetails.fromJson(Map<String, dynamic> json) {
    return CheckInDetails(
      time: json['time'],
      date: json['date'],
      coordinates: json['coordinates'] != null
          ? Map<String, double>.from(json['coordinates'])
          : null,
      photoUploaded: json['photo_uploaded'] ?? false,
      platform: json['platform'] ?? 'mobile_app',
    );
  }
}

class WorkSession {
  final String? checkInTime;
  final String? checkOutTime;
  final WorkDuration? workDuration;
  final String date;

  WorkSession({
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    required this.date,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      workDuration: json['work_duration'] != null
          ? WorkDuration.fromJson(json['work_duration'])
          : null,
      date: json['date'],
    );
  }
}

class WorkDuration {
  final double totalSeconds;
  final double hours;
  final double minutes;
  final String formatted;

  WorkDuration({
    required this.totalSeconds,
    required this.hours,
    required this.minutes,
    required this.formatted,
  });

  factory WorkDuration.fromJson(Map<String, dynamic> json) {
    return WorkDuration(
      totalSeconds: json['total_seconds']?.toDouble() ?? 0.0,
      hours: json['hours']?.toDouble() ?? 0.0,
      minutes: json['minutes']?.toDouble() ?? 0.0,
      formatted: json['formatted'] ?? '0:00:00',
    );
  }
}

// Driver Locations Response Model
class DriverLocationsResponse {
  final String driverId;
  final String driverName;
  final int totalLocations;
  final List<CheckinLocation> locations;

  DriverLocationsResponse({
    required this.driverId,
    required this.driverName,
    required this.totalLocations,
    required this.locations,
  });

  factory DriverLocationsResponse.fromJson(Map<String, dynamic> json) {
    return DriverLocationsResponse(
      driverId: json['driver_id'].toString(),
      driverName: json['driver_name'] ?? '',
      totalLocations: json['total_locations'] ?? 0,
      locations: (json['locations'] as List? ?? [])
          .map((location) => CheckinLocation.fromJson(location))
          .toList(),
    );
  }
}

// TEMPORARILY DISABLED: Check-in location feature
/*
class CheckedInLocation {
  final int id;
  final String name;
  final String latitude;
  final String longitude;
  final int radiusMeters;
  final bool isActive;
  final int? driverId; // Nullable if not always linked directly
  final String createdAt;
  final String updatedAt;

  CheckedInLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    this.driverId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckedInLocation.fromJson(Map<String, dynamic> json) {
    return CheckedInLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      radiusMeters: json['radius_meters'] as int,
      isActive: json['is_active'] as bool,
      driverId: json['driver'] as int?, // In CheckedInLocation, driver is always an int
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
*/
