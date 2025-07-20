import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'api_service.dart';
import 'auth_service.dart';
import 'camera_service.dart';
import 'mobile_features_service.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final MobileFeaturesService _mobileService = MobileFeaturesService();
  final CameraService _cameraService = CameraService();

  // Current attendance state
  Attendance? _currentAttendance;
  bool _isActive = false;
  bool _isLoading = false;

  // Getters
  Attendance? get currentAttendance => _currentAttendance;
  bool get isActive => _isActive;
  bool get isLoading => _isLoading;

  // Helper method to convert DriverStatus to Attendance for compatibility
  Attendance? _convertDriverStatusToAttendance(DriverStatus driverStatus) {
    if (driverStatus.status == 'not_checked_in') {
      return null; // No attendance record yet
    }

    // Create a minimal Attendance object from DriverStatus
    return Attendance(
      id: driverStatus.attendanceId ?? 0,
      driverId: int.parse(driverStatus.driverId),
      date: driverStatus.date,
      loginTime: driverStatus.loginTime,
      logoutTime: driverStatus.logoutTime,
      status: driverStatus.status,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  // Helper method to capture photo with UI dialog
  Future<String?> _capturePhoto(String context) async {
    try {
      debugPrint('📸 Initializing camera for $context photo...');

      // Initialize camera service if needed
      final initialized = await _cameraService.initialize();
      if (!initialized) {
        debugPrint('❌ Camera initialization failed');
        return null;
      }

      // Capture photo using camera service directly for now
      // TODO: Integrate with PhotoCaptureDialog for better UX
      final photoBase64 = await _cameraService.takePhoto(useFrontCamera: true);
      if (photoBase64 != null) {
        debugPrint('✅ $context photo captured successfully');
        return photoBase64;
      } else {
        debugPrint('❌ Photo capture returned null');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error capturing $context photo: $e');
      return null;
    }
  }

  // Helper method to get current location with error handling
  Future<Position?> _getCurrentLocation() async {
    try {
      debugPrint('📍 Checking location permissions...');

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission permanently denied');
        return null;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return null;
      }

      debugPrint('📍 Getting current position...');

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      debugPrint('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  // Initialize attendance service
  Future<void> initialize() async {
    // Don't make API calls during initialization
    // The attendance data will be loaded when the user logs in
    debugPrint('AttendanceService initialized');
  }

  // Check and request location permissions
  Future<bool> _handleLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return false;
    }
  }

  // Get current position
  Future<Position?> _getCurrentPosition() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  // Refresh current day attendance
  Future<AttendanceResult> refreshCurrentAttendance() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return AttendanceResult.error('Not authenticated');
    }

    try {
      _isLoading = true;

      // Get actual driver ID from authenticated user
      final driverId = _authService.currentDriver?.id ?? 3; // Fallback to 3 for testing
      debugPrint('🔍 Refreshing attendance for driver ID: $driverId');

      final response = await _apiService.getCurrentDayAttendance(driverId);

      if (response.isSuccess && response.data != null) {
        // Convert DriverStatus to Attendance for compatibility
        final driverStatus = response.data!;
        _currentAttendance = _convertDriverStatusToAttendance(driverStatus);
        _isActive = driverStatus.status == 'checked_in';
        _isLoading = false;
        debugPrint('✅ Status refreshed - Active: $_isActive, Has attendance: ${_currentAttendance != null}');
        debugPrint('📊 Status: ${driverStatus.message}');
        return AttendanceResult.success(_currentAttendance);
      } else {
        // No attendance record for today (404 is expected)
        _currentAttendance = null;
        _isActive = false;
        _isLoading = false;
        return AttendanceResult.success(null);
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('Error refreshing attendance: $e');
      return AttendanceResult.error('Failed to refresh attendance: ${e.toString()}');
    }
  }

  // Driver check-in/login with mandatory photo and location capture
  Future<AttendanceResult> checkIn({String? photoBase64}) async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return AttendanceResult.error('Not authenticated');
    }

    if (_isActive) {
      return AttendanceResult.error('Already checked in');
    }

    try {
      _isLoading = true;
      _mobileService.mediumHaptic();
      debugPrint('🔍 Starting check-in process with photo and location capture...');

      // Step 1: Mandatory photo capture
      String? capturedPhoto = photoBase64;
      if (capturedPhoto == null) {
        debugPrint('📸 Capturing mandatory check-in selfie...');
        capturedPhoto = await _capturePhoto('check-in');
        if (capturedPhoto == null) {
          _isLoading = false;
          return AttendanceResult.error('Photo capture is required for check-in. Please allow camera access and try again.');
        }
        debugPrint('✅ Check-in photo captured successfully');
      }

      // Step 2: Mandatory location capture
      debugPrint('📍 Capturing current location...');
      Position? position = await _getCurrentLocation();
      if (position == null) {
        _isLoading = false;
        return AttendanceResult.error('Location access is required for check-in. Please enable location services and try again.');
      }
      debugPrint('✅ Location captured: ${position.latitude}, ${position.longitude}');

      // Step 3: Format current time
      final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      debugPrint('⏰ Check-in time: $currentTime');

      // Step 4: Call API
      final driverId = _authService.currentDriver?.id ?? 3;
      debugPrint('🚀 Calling check-in API for driver $driverId...');

      final response = await _apiService.driverLogin(
        driverId: driverId,
        loginTime: currentTime,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: capturedPhoto,
      );

      if (response.isSuccess && response.data != null) {
        final attendanceResponse = response.data!;
        if (attendanceResponse.success && attendanceResponse.attendance != null) {
          _currentAttendance = attendanceResponse.attendance;
          _isActive = true;
          _isLoading = false;
          _mobileService.lightHaptic();

          // Log location validation details
          if (attendanceResponse.locationValidation != null) {
            debugPrint('✅ Location validated: ${attendanceResponse.locationValidation!.validated}');
            if (attendanceResponse.locationValidation!.matchedLocation != null) {
              debugPrint('📍 Matched location: ${attendanceResponse.locationValidation!.matchedLocation!.name}');
            }
          }

          return AttendanceResult.success(_currentAttendance);
        } else {
          _isLoading = false;
          _mobileService.heavyHaptic();
          return AttendanceResult.error(attendanceResponse.message);
        }
      } else {
        _isLoading = false;
        _mobileService.heavyHaptic();
        return AttendanceResult.error(response.error ?? 'Check-in failed');
      }
    } catch (e) {
      _isLoading = false;
      _mobileService.heavyHaptic();
      debugPrint('Check-in error: $e');
      return AttendanceResult.error('Check-in failed: ${e.toString()}');
    }
  }

  // Driver check-out/logout with mandatory photo and location capture
  Future<AttendanceResult> checkOut({String? photoBase64}) async {
    if (!_authService.isAuthenticated || _currentAttendance == null) {
      return AttendanceResult.error('No active attendance record');
    }

    if (!_isActive) {
      return AttendanceResult.error('Not currently checked in');
    }

    try {
      _isLoading = true;
      _mobileService.mediumHaptic();
      debugPrint('🔍 Starting check-out process with photo and location capture...');

      // Step 1: Mandatory photo capture
      String? capturedPhoto = photoBase64;
      if (capturedPhoto == null) {
        debugPrint('📸 Capturing mandatory check-out selfie...');
        capturedPhoto = await _capturePhoto('check-out');
        if (capturedPhoto == null) {
          _isLoading = false;
          return AttendanceResult.error('Photo capture is required for check-out. Please allow camera access and try again.');
        }
        debugPrint('✅ Check-out photo captured successfully');
      }

      // Step 2: Mandatory location capture
      debugPrint('📍 Capturing current location...');
      Position? position = await _getCurrentLocation();
      if (position == null) {
        _isLoading = false;
        return AttendanceResult.error('Location access is required for check-out. Please enable location services and try again.');
      }
      debugPrint('✅ Location captured: ${position.latitude}, ${position.longitude}');

      // Step 3: Format current time
      final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      debugPrint('⏰ Check-out time: $currentTime');

      // Step 4: Call API
      debugPrint('🚀 Calling check-out API for attendance ${_currentAttendance!.id}...');
      final response = await _apiService.driverLogout(
        attendanceId: _currentAttendance!.id,
        logoutTime: currentTime,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: capturedPhoto,
      );

      if (response.isSuccess && response.data != null) {
        final attendanceResponse = response.data!;
        if (attendanceResponse.success && attendanceResponse.attendance != null) {
          _currentAttendance = attendanceResponse.attendance;
          _isActive = false;
          _isLoading = false;
          _mobileService.lightHaptic();

          // Log work session details
          if (attendanceResponse.workSession != null) {
            debugPrint('✅ Work session completed');
            if (attendanceResponse.workSession!.workDuration != null) {
              debugPrint('⏱️ Work duration: ${attendanceResponse.workSession!.workDuration!.formatted}');
            }
          }

          return AttendanceResult.success(_currentAttendance);
        } else {
          _isLoading = false;
          _mobileService.heavyHaptic();
          return AttendanceResult.error(attendanceResponse.message);
        }
      } else {
        _isLoading = false;
        _mobileService.heavyHaptic();
        return AttendanceResult.error(response.error ?? 'Check-out failed');
      }
    } catch (e) {
      _isLoading = false;
      _mobileService.heavyHaptic();
      debugPrint('Check-out error: $e');
      return AttendanceResult.error('Check-out failed: ${e.toString()}');
    }
  }

  // Get driver status
  Future<DriverStatus?> getDriverStatus() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return null;
    }

    try {
      final driverId = _authService.currentDriver?.id ?? 3;
      final response = await _apiService.getDriverStatus(driverId);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        debugPrint('Failed to get driver status: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting driver status: $e');
      return null;
    }
  }

  // Get driver authorized locations
  Future<List<CheckinLocation>> getDriverLocations() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return [];
    }

    try {
      final driverId = _authService.currentDriver?.id ?? 3;
      final response = await _apiService.getDriverLocations(driverId);

      if (response.isSuccess && response.data != null) {
        return response.data!.locations;
      } else {
        debugPrint('Failed to get driver locations: ${response.error}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting driver locations: $e');
      return [];
    }
  }

  // Get attendance history
  Future<AttendanceHistoryResult> getAttendanceHistory({
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return AttendanceHistoryResult.error('Not authenticated');
    }

    try {
      // For now, use hardcoded driver ID 3 (from our test setup)
      // TODO: Get actual driver ID from backend API
      const driverId = 3;

      final response = await _apiService.getAttendanceHistory(
        driverId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.isSuccess && response.data != null) {
        List<Attendance> attendanceList = response.data!;
        
        // Apply limit if specified
        if (limit != null && attendanceList.length > limit) {
          attendanceList = attendanceList.take(limit).toList();
        }

        return AttendanceHistoryResult.success(attendanceList);
      } else {
        return AttendanceHistoryResult.error(
          response.error ?? 'Failed to load attendance history',
        );
      }
    } catch (e) {
      debugPrint('Attendance history error: $e');
      return AttendanceHistoryResult.error(
        'Failed to load attendance history: ${e.toString()}',
      );
    }
  }

  // Get weekly summary
  Future<WeeklySummary> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
    final endDate = DateFormat('yyyy-MM-dd').format(endOfWeek);

    final historyResult = await getAttendanceHistory(
      startDate: startDate,
      endDate: endDate,
    );

    if (historyResult.isSuccess && historyResult.data != null) {
      return _calculateWeeklySummary(historyResult.data!);
    } else {
      return WeeklySummary.empty();
    }
  }

  // Calculate weekly summary from attendance data
  WeeklySummary _calculateWeeklySummary(List<Attendance> attendanceList) {
    int daysWorked = 0;
    double totalHours = 0.0;
    int totalTrips = attendanceList.length;

    for (final attendance in attendanceList) {
      if (attendance.loginTime != null) {
        daysWorked++;
        
        if (attendance.logoutTime != null) {
          // Calculate hours worked
          try {
            final loginTime = DateFormat('HH:mm:ss').parse(attendance.loginTime!);
            final logoutTime = DateFormat('HH:mm:ss').parse(attendance.logoutTime!);
            final duration = logoutTime.difference(loginTime);
            totalHours += duration.inMinutes / 60.0;
          } catch (e) {
            debugPrint('Error calculating hours: $e');
          }
        }
      }
    }

    return WeeklySummary(
      daysWorked: daysWorked,
      totalHours: totalHours,
      totalTrips: totalTrips,
      averageHoursPerDay: daysWorked > 0 ? totalHours / daysWorked : 0.0,
    );
  }

  // Convert image to base64
  String? imageToBase64(Uint8List? imageBytes) {
    if (imageBytes == null) return null;
    return base64Encode(imageBytes);
  }

  // Get current location as string
  Future<String?> getCurrentLocationString() async {
    final position = await _getCurrentPosition();
    if (position == null) return null;
    
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

// Attendance result wrapper
class AttendanceResult {
  final bool isSuccess;
  final Attendance? data;
  final String? error;

  AttendanceResult.success(this.data) : isSuccess = true, error = null;
  AttendanceResult.error(this.error) : isSuccess = false, data = null;
}

// Attendance history result wrapper
class AttendanceHistoryResult {
  final bool isSuccess;
  final List<Attendance>? data;
  final String? error;

  AttendanceHistoryResult.success(this.data) : isSuccess = true, error = null;
  AttendanceHistoryResult.error(this.error) : isSuccess = false, data = null;
}

// Weekly summary data class
class WeeklySummary {
  final int daysWorked;
  final double totalHours;
  final int totalTrips;
  final double averageHoursPerDay;

  WeeklySummary({
    required this.daysWorked,
    required this.totalHours,
    required this.totalTrips,
    required this.averageHoursPerDay,
  });

  factory WeeklySummary.empty() {
    return WeeklySummary(
      daysWorked: 0,
      totalHours: 0.0,
      totalTrips: 0,
      averageHoursPerDay: 0.0,
    );
  }
}
