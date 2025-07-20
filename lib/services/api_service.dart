import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model.dart';
import '../models/trip_model.dart';
import '../models/leave_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL configuration
  static const String _baseUrl = kDebugMode
      ? 'http://43.204.238.225:8000/'  // Updated to current network IP
      : 'https://your-production-api.com';  // Production URL

  // API endpoints
  static const String _authEndpoint = '/auth/';

  // Authentication tokens
  String? _accessToken;
  String? _refreshToken;

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // Headers for HR endpoints (no authentication required)
  Map<String, String> get _hrHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers for trips endpoints (no authentication required for now)
  Map<String, String> get _tripsHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _multipartHeaders => {
    'Accept': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // Initialize API service with stored tokens
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Save authentication tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // Clear authentication tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
  }

  // Clear expired tokens to prevent 401 errors
  Future<void> clearExpiredTokens() async {
    debugPrint('Clearing any expired tokens to prevent 401 errors');
    await clearTokens();
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${_authEndpoint}refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return false;
  }

  // Generic API request handler with token refresh
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = customHeaders ?? _headers;

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle token refresh for 401 errors
      if (response.statusCode == 401 && _refreshToken != null) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          final newHeaders = customHeaders ?? _headers;
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(uri, headers: newHeaders);
              break;
            case 'POST':
              response = await http.post(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PUT':
              response = await http.put(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PATCH':
              response = await http.patch(
                uri,
                headers: newHeaders,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'DELETE':
              response = await http.delete(uri, headers: newHeaders);
              break;
          }
        }
      }

      return _handleResponse<T>(response, fromJson: fromJson, fromJsonList: fromJsonList);
    } catch (e) {
      debugPrint('API request error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  }) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse.success(null);
        }

        final dynamic data = jsonDecode(response.body);

        if (fromJson != null && data is Map<String, dynamic>) {
          try {
            return ApiResponse.success(fromJson(data));
          } catch (e) {
            debugPrint('Response parsing error: $e');
            debugPrint('Response body: ${response.body}');
            return ApiResponse.error('Failed to parse response: $e');
          }
        } else if (fromJsonList != null && data is List) {
          try {
            return ApiResponse.success(fromJsonList(data));
          } catch (e) {
            debugPrint('Response parsing error: $e');
            debugPrint('Response body: ${response.body}');
            return ApiResponse.error('Failed to parse response: $e');
          }
        } else if (fromJson != null) {
          // If fromJson is provided but data is not a Map, it's an error
          debugPrint('Response parsing error: Expected Map<String, dynamic> but got ${data.runtimeType}');
          debugPrint('Response body: ${response.body}');
          return ApiResponse.error('Invalid response format: Expected object but got ${data.runtimeType}');
        } else if (fromJsonList != null) {
          // If fromJsonList is provided but data is not a List, it's an error
          debugPrint('Response parsing error: Expected List but got ${data.runtimeType}');
          debugPrint('Response body: ${response.body}');
          return ApiResponse.error('Invalid response format: Expected array but got ${data.runtimeType}');
        } else {
          return ApiResponse.success(data as T);
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage;

          // Handle Django validation errors
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('non_field_errors')) {
              final errors = errorData['non_field_errors'] as List;
              errorMessage = errors.isNotEmpty ? errors.first.toString() : 'Validation error';
            } else if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'].toString();
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            } else {
              // Handle field-specific errors
              final fieldErrors = <String>[];
              errorData.forEach((key, value) {
                if (value is List && value.isNotEmpty) {
                  fieldErrors.add('$key: ${value.first}');
                } else if (value is String) {
                  fieldErrors.add('$key: $value');
                }
              });
              errorMessage = fieldErrors.isNotEmpty
                  ? fieldErrors.join(', ')
                  : 'Request failed with status ${response.statusCode}';
            }
          } else {
            errorMessage = 'Request failed with status ${response.statusCode}';
          }

          return ApiResponse.error(errorMessage);
        } catch (e) {
          return ApiResponse.error('Request failed with status ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Response parsing error: $e');
      debugPrint('Response body: ${response.body}');
      return ApiResponse.error('Failed to parse response: ${e.toString()}');
    }
  }

  // Authentication APIs
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    // Use dedicated driver mobile login endpoint
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await _makeRequest<Map<String, dynamic>>(
      'POST',
      'mobile/login/',  // Driver mobile login endpoint
      body: {
        'username': username,  // Driver login uses username, not email
        'password': password,
        'device_info': 'Flutter Mobile App',
      },
      customHeaders: headers,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      // Driver login returns 'access_token' and 'refresh_token'
      String? accessToken = data['access_token'];
      String? refreshToken = data['refresh_token'];

      if (accessToken != null && refreshToken != null) {
        await _saveTokens(accessToken, refreshToken);
      }
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> userData) async {
    return await _makeRequest<Map<String, dynamic>>(
      'POST',
      '${_authEndpoint}register/',
      body: userData,
    );
  }

  Future<void> logout() async {
    await clearTokens();
  }

  // Check if we have valid tokens (for driver mobile app)
  Future<bool> hasValidTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      // Basic check - we have both tokens
      if (accessToken != null && refreshToken != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }

  // User profile API (for admin dashboard - not used in driver mobile app)
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await _makeRequest<Map<String, dynamic>>(
      'GET',
      '${_authEndpoint}me/',
    );
  }

  // Get driver profile by user ID
  Future<ApiResponse<Map<String, dynamic>>> getDriverByUserId(int userId) async {
    return await _makeRequest<Map<String, dynamic>>(
      'GET',
      '/by-user/$userId/',
    );
  }

  // Get driver profile by driver ID (no authentication required)
  Future<ApiResponse<Map<String, dynamic>>> getDriverProfile(int driverId) async {
    return await _makeRequest<Map<String, dynamic>>(
      'GET',
      'Register/drivers/$driverId/',
      customHeaders: _hrHeaders, // Use non-authenticated headers
    );
  }

  // Update driver profile
  Future<ApiResponse<Map<String, dynamic>>> updateDriverProfile(int driverId, Map<String, dynamic> updateData) async {
    return await _makeRequest<Map<String, dynamic>>(
      'PATCH',
      'Register/drivers/$driverId/',
      body: updateData,
      customHeaders: _hrHeaders,
      fromJson: (json) => json,
    );
  }

  // Attendance APIs
  Future<ApiResponse<DriverStatus>> getCurrentDayAttendance(int driverId) async {
    return await _makeRequest<DriverStatus>(
      'GET',
      'hr/attendance/driver-status/$driverId/',
      customHeaders: _hrHeaders,
      fromJson: (json) => DriverStatus.fromJson(json),
    );
  }

  Future<ApiResponse<AttendanceResponse>> driverLogin({
    required int driverId,
    required String loginTime,
    required double latitude,
    required double longitude,
    String? photoBase64,
  }) async {
    return await _makeRequest<AttendanceResponse>(
      'POST',
      'hr/attendance/login/',
      customHeaders: _hrHeaders,
      body: {
        'driver': driverId,
        'login_time': loginTime,
        'login_latitude': latitude.toString(),
        'login_longitude': longitude.toString(),
        if (photoBase64 != null) 'login_photo_base64': photoBase64,
        'platform': 'mobile_app',
      },
      fromJson: (json) => AttendanceResponse.fromJson(json),
    );
  }

  Future<ApiResponse<AttendanceResponse>> driverLogout({
    required int attendanceId,
    required String logoutTime,
    required double latitude,
    required double longitude,
    String? photoBase64,
  }) async {
    return await _makeRequest<AttendanceResponse>(
      'PATCH',
      'hr/attendance/$attendanceId/logout/',
      customHeaders: _hrHeaders,
      body: {
        'logout_time': logoutTime,
        'logout_latitude': latitude.toString(),
        'logout_longitude': longitude.toString(),
        if (photoBase64 != null) 'logout_photo_base64': photoBase64,
      },
      fromJson: (json) => AttendanceResponse.fromJson(json),
    );
  }

  // Get driver status
  Future<ApiResponse<DriverStatus>> getDriverStatus(int driverId) async {
    return await _makeRequest<DriverStatus>(
      'GET',
      'hr/attendance/driver-status/$driverId/',
      customHeaders: _hrHeaders,
      fromJson: (json) => DriverStatus.fromJson(json),
    );
  }

  // Get driver authorized locations
  Future<ApiResponse<DriverLocationsResponse>> getDriverLocations(int driverId) async {
    return await _makeRequest<DriverLocationsResponse>(
      'GET',
      'hr/attendance/locations/$driverId/',
      customHeaders: _hrHeaders,
      fromJson: (json) => DriverLocationsResponse.fromJson(json),
    );
  }

  Future<ApiResponse<List<Attendance>>> getAttendanceHistory(
    int driverId, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = 'hr/attendance/?driver=$driverId';
    if (startDate != null) endpoint += '&start_date=$startDate';
    if (endDate != null) endpoint += '&end_date=$endDate';

    return await _makeRequest<List<Attendance>>(
      'GET',
      endpoint,
      customHeaders: _hrHeaders,
      fromJsonList: (jsonList) => jsonList
          .map((json) => Attendance.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  // ==================== LEAVE MANAGEMENT APIs ====================

  // Get leave types
  Future<ApiResponse<List<LeaveType>>> getLeaveTypes() async {
    return await _makeRequest<List<LeaveType>>(
      'GET',
      'hr/leave-types/',
      customHeaders: _hrHeaders,
      fromJson: (json) {
        // Handle paginated response
        if (json.containsKey('results')) {
          final results = json['results'] as List;
          return results
              .map((item) => LeaveType.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Handle direct array response
        else if (json is List) {
          return (json as List)
              .map((item) => LeaveType.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  // Get leave requests for a driver
  Future<ApiResponse<List<LeaveRequest>>> getLeaveRequests(
    int driverId, {
    String? status,
    int? year,
    int? month,
  }) async {
    String endpoint = 'hr/leave-requests/?driver=$driverId';
    if (status != null) endpoint += '&status=$status';
    if (year != null) endpoint += '&year=$year';
    if (month != null) endpoint += '&month=$month';

    return await _makeRequest<List<LeaveRequest>>(
      'GET',
      endpoint,
      customHeaders: _hrHeaders,
      fromJson: (json) {
        // Handle paginated response
        if (json.containsKey('results')) {
          final results = json['results'] as List;
          return results
              .map((item) => LeaveRequest.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Handle direct array response
        else if (json is List) {
          return (json as List)
              .map((item) => LeaveRequest.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  // Create a new leave request
  Future<ApiResponse<LeaveRequest>> createLeaveRequest(LeaveRequest leaveRequest) async {
    return await _makeRequest<LeaveRequest>(
      'POST',
      'hr/leave-requests/',
      customHeaders: _hrHeaders,
      body: leaveRequest.toJson(),
      fromJson: (json) => LeaveRequest.fromJson(json),
    );
  }

  // Get leave balances for a driver
  Future<ApiResponse<List<LeaveBalance>>> getLeaveBalances(
    int driverId, {
    int? year,
  }) async {
    String endpoint = 'hr/leave-balances/?driver=$driverId';
    if (year != null) endpoint += '&year=$year';

    return await _makeRequest<List<LeaveBalance>>(
      'GET',
      endpoint,
      customHeaders: _hrHeaders,
      fromJson: (json) {
        // Handle paginated response
        if (json.containsKey('results')) {
          final results = json['results'] as List;
          return results
              .map((item) => LeaveBalance.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Handle direct array response
        else if (json is List) {
          return (json as List)
              .map((item) => LeaveBalance.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  // Cancel a leave request (driver can cancel pending requests)
  Future<ApiResponse<LeaveRequest>> cancelLeaveRequest(int requestId) async {
    return await _makeRequest<LeaveRequest>(
      'PATCH',
      'hr/leave-requests/$requestId/',
      customHeaders: _hrHeaders,
      body: {'status': 'cancelled'},
      fromJson: (json) => LeaveRequest.fromJson(json),
    );
  }

  // ==================== TRIP MANAGEMENT APIs ====================

  // Create a new trip
  Future<ApiResponse<Trip>> createTrip({
    required int driverId,
    required String customerName,
    required String pickupLocation,
    required String dropoffLocation,
    required double distanceKm,
    required int durationMinutes,
    required double baseFare,
    required double tipAmount,
    required String paymentMethod,
    String? notes,
  }) async {
    return await _makeRequest<Trip>(
      'POST',
      'trips/trips/',
      customHeaders: _tripsHeaders,
      body: {
        'driver': driverId,
        'customer_name': customerName,
        'pickup_location': pickupLocation,
        'dropoff_location': dropoffLocation,
        'distance_km': distanceKm,
        'duration_minutes': durationMinutes,
        'base_fare': baseFare,
        'tip_amount': tipAmount,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => Trip.fromJson(json),
    );
  }

  // Get trips for a driver
  Future<ApiResponse<List<Trip>>> getDriverTrips(
    int driverId, {
    String? startDate,
    String? endDate,
    int? page,
    int? pageSize,
  }) async {
    String endpoint = 'trips/trips/driver_trips/?driver_id=$driverId';

    if (startDate != null) endpoint += '&start_date=$startDate';
    if (endDate != null) endpoint += '&end_date=$endDate';
    if (page != null) endpoint += '&page=$page';
    if (pageSize != null) endpoint += '&page_size=$pageSize';

    return await _makeRequest<List<Trip>>(
      'GET',
      endpoint,
      customHeaders: _tripsHeaders,
      fromJsonList: (jsonList) => jsonList
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get recent trips for a driver (last 10)
  Future<ApiResponse<List<Trip>>> getRecentTrips(int driverId) async {
    return await _makeRequest<List<Trip>>(
      'GET',
      'trips/trips/recent_trips/?driver_id=$driverId',
      customHeaders: _tripsHeaders,
      fromJsonList: (jsonList) => jsonList
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get driver trip statistics
  Future<ApiResponse<TripStats>> getDriverTripStats(
    int driverId, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = 'trips/trips/driver_stats/?driver_id=$driverId';

    if (startDate != null) endpoint += '&start_date=$startDate';
    if (endDate != null) endpoint += '&end_date=$endDate';

    return await _makeRequest<TripStats>(
      'GET',
      endpoint,
      customHeaders: _tripsHeaders,
      fromJson: (json) => TripStats.fromJson(json), // Fixed: backend returns stats directly
    );
  }

  // Get a specific trip by ID
  Future<ApiResponse<Trip>> getTripById(int tripId) async {
    return await _makeRequest<Trip>(
      'GET',
      'trips/trips/$tripId/',
      customHeaders: _tripsHeaders,
      fromJson: (json) => Trip.fromJson(json),
    );
  }

  // Update a trip
  Future<ApiResponse<Trip>> updateTrip(int tripId, Map<String, dynamic> updates) async {
    return await _makeRequest<Trip>(
      'PATCH',
      'trips/trips/$tripId/',
      customHeaders: _tripsHeaders,
      body: updates,
      fromJson: (json) => Trip.fromJson(json),
    );
  }

  // Delete a trip
  Future<ApiResponse<void>> deleteTrip(int tripId) async {
    return await _makeRequest<void>(
      'DELETE',
      'trips/trips/$tripId/',
      customHeaders: _tripsHeaders,
    );
  }
}

// API Response wrapper class
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : isSuccess = true, error = null;
  ApiResponse.error(this.error) : isSuccess = false, data = null;
}
