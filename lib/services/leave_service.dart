import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/leave_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Cache for leave types and balances
  List<LeaveType>? _cachedLeaveTypes;
  List<LeaveBalance>? _cachedLeaveBalances;
  List<LeaveRequest>? _cachedLeaveRequests;

  // Cache timestamps for expiry management
  DateTime? _leaveTypesLastFetch;
  DateTime? _leaveBalancesLastFetch;
  DateTime? _leaveRequestsLastFetch;

  // Cache expiry duration (5 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Stream controllers for real-time updates
  final StreamController<List<LeaveRequest>> _leaveRequestsController =
      StreamController<List<LeaveRequest>>.broadcast();
  final StreamController<List<LeaveBalance>> _leaveBalancesController =
      StreamController<List<LeaveBalance>>.broadcast();

  // Streams for UI to listen to
  Stream<List<LeaveRequest>> get leaveRequestsStream => _leaveRequestsController.stream;
  Stream<List<LeaveBalance>> get leaveBalancesStream => _leaveBalancesController.stream;

  // Initialize the service
  Future<void> initialize() async {
    debugPrint('LeaveService: Initializing...');
    await clearCache();
  }

  // Dispose resources
  void dispose() {
    _leaveRequestsController.close();
    _leaveBalancesController.close();
  }

  // ==================== CACHE MANAGEMENT ====================

  // Check if cache is expired
  bool _isCacheExpired(DateTime? lastFetch) {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > _cacheExpiry;
  }

  // Clear all cached data
  Future<void> clearCache() async {
    debugPrint('LeaveService: Clearing cache...');
    _cachedLeaveTypes = null;
    _cachedLeaveBalances = null;
    _cachedLeaveRequests = null;
    _leaveTypesLastFetch = null;
    _leaveBalancesLastFetch = null;
    _leaveRequestsLastFetch = null;
  }

  // ==================== LEAVE TYPES ====================

  // Get all available leave types
  Future<LeaveApiResponse<List<LeaveType>>> getLeaveTypes({
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('LeaveService: Getting leave types...');

      // Return cached data if available and not expired
      if (!forceRefresh && 
          _cachedLeaveTypes != null && 
          !_isCacheExpired(_leaveTypesLastFetch)) {
        debugPrint('LeaveService: Returning cached leave types');
        return LeaveApiResponse.success(_cachedLeaveTypes!);
      }

      // Fetch from API
      final response = await _apiService.getLeaveTypes();
      
      if (response.isSuccess && response.data != null) {
        // Cache the data
        _cachedLeaveTypes = response.data!;
        _leaveTypesLastFetch = DateTime.now();
        
        debugPrint('LeaveService: Successfully fetched ${_cachedLeaveTypes!.length} leave types');
        return LeaveApiResponse.success(_cachedLeaveTypes!);
      } else {
        debugPrint('LeaveService: Failed to fetch leave types: ${response.error}');
        return LeaveApiResponse.error(response.error ?? 'Failed to fetch leave types');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in getLeaveTypes: $e');
      return LeaveApiResponse.error('An error occurred while fetching leave types: $e');
    }
  }

  // Get a specific leave type by ID
  Future<LeaveApiResponse<LeaveType?>> getLeaveTypeById(int leaveTypeId) async {
    try {
      final leaveTypesResponse = await getLeaveTypes();
      
      if (leaveTypesResponse.isSuccess && leaveTypesResponse.data != null) {
        final leaveType = leaveTypesResponse.data!
            .firstWhere((type) => type.id == leaveTypeId, orElse: () => throw Exception('Leave type not found'));
        
        return LeaveApiResponse.success(leaveType);
      } else {
        return LeaveApiResponse.error(leaveTypesResponse.error ?? 'Failed to fetch leave types');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in getLeaveTypeById: $e');
      return LeaveApiResponse.error('Leave type not found');
    }
  }

  // ==================== LEAVE REQUESTS ====================

  // Get leave requests for current driver
  Future<LeaveApiResponse<List<LeaveRequest>>> getLeaveRequests({
    String? status,
    int? year,
    int? month,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('LeaveService: Getting leave requests...');

      final driver = _authService.currentDriver;
      if (driver == null) {
        debugPrint('LeaveService: No driver logged in');
        return LeaveApiResponse.error('No driver logged in');
      }

      // Return cached data if available and not expired (only for unfiltered requests)
      if (!forceRefresh && 
          _cachedLeaveRequests != null && 
          !_isCacheExpired(_leaveRequestsLastFetch) &&
          status == null && year == null && month == null) {
        debugPrint('LeaveService: Returning cached leave requests');
        return LeaveApiResponse.success(_cachedLeaveRequests!);
      }

      // Fetch from API
      final response = await _apiService.getLeaveRequests(
        driver.id,
        status: status,
        year: year,
        month: month,
      );

      if (response.isSuccess && response.data != null) {
        // Cache only if no filters applied
        if (status == null && year == null && month == null) {
          _cachedLeaveRequests = response.data!;
          _leaveRequestsLastFetch = DateTime.now();
        }
        
        debugPrint('LeaveService: Successfully fetched ${response.data!.length} leave requests');
        
        // Emit to stream for real-time updates
        _leaveRequestsController.add(response.data!);
        
        return LeaveApiResponse.success(response.data!);
      } else {
        debugPrint('LeaveService: Failed to fetch leave requests: ${response.error}');
        return LeaveApiResponse.error(response.error ?? 'Failed to fetch leave requests');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in getLeaveRequests: $e');
      return LeaveApiResponse.error('An error occurred while fetching leave requests: $e');
    }
  }

  // Create a new leave request
  Future<LeaveApiResponse<LeaveRequest>> createLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      debugPrint('LeaveService: Creating leave request...');

      final driver = _authService.currentDriver;
      if (driver == null) {
        return LeaveApiResponse.error('No driver logged in');
      }

      // Validate leave request
      final validationResult = await _validateLeaveRequest(leaveRequest);
      if (!validationResult.isSuccess) {
        return LeaveApiResponse.error(validationResult.error!);
      }

      // Create the request
      final response = await _apiService.createLeaveRequest(leaveRequest);

      if (response.isSuccess && response.data != null) {
        debugPrint('LeaveService: Successfully created leave request');
        
        // Clear cache to force refresh
        await clearCache();
        
        // Refresh data and emit updates
        await _refreshLeaveData();
        
        return LeaveApiResponse.success(response.data!, message: 'Leave request submitted successfully');
      } else {
        debugPrint('LeaveService: Failed to create leave request: ${response.error}');
        return LeaveApiResponse.error(response.error ?? 'Failed to create leave request');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in createLeaveRequest: $e');
      return LeaveApiResponse.error('An error occurred while creating leave request: $e');
    }
  }

  // Cancel a leave request
  Future<LeaveApiResponse<LeaveRequest>> cancelLeaveRequest(int requestId) async {
    try {
      debugPrint('LeaveService: Cancelling leave request $requestId...');

      final response = await _apiService.cancelLeaveRequest(requestId);

      if (response.isSuccess && response.data != null) {
        debugPrint('LeaveService: Successfully cancelled leave request');
        
        // Clear cache to force refresh
        await clearCache();
        
        // Refresh data and emit updates
        await _refreshLeaveData();
        
        return LeaveApiResponse.success(response.data!, message: 'Leave request cancelled successfully');
      } else {
        debugPrint('LeaveService: Failed to cancel leave request: ${response.error}');
        return LeaveApiResponse.error(response.error ?? 'Failed to cancel leave request');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in cancelLeaveRequest: $e');
      return LeaveApiResponse.error('An error occurred while cancelling leave request: $e');
    }
  }

  // ==================== LEAVE BALANCES ====================

  // Get leave balances for current driver
  Future<LeaveApiResponse<List<LeaveBalance>>> getLeaveBalances({
    int? year,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('LeaveService: Getting leave balances...');

      final driver = _authService.currentDriver;
      if (driver == null) {
        debugPrint('LeaveService: No driver logged in');
        return LeaveApiResponse.error('No driver logged in');
      }

      // Return cached data if available and not expired (only for current year)
      if (!forceRefresh && 
          _cachedLeaveBalances != null && 
          !_isCacheExpired(_leaveBalancesLastFetch) &&
          (year == null || year == DateTime.now().year)) {
        debugPrint('LeaveService: Returning cached leave balances');
        return LeaveApiResponse.success(_cachedLeaveBalances!);
      }

      // Fetch from API
      final response = await _apiService.getLeaveBalances(
        driver.id,
        year: year,
      );

      if (response.isSuccess && response.data != null) {
        // Cache only if current year or no year specified
        if (year == null || year == DateTime.now().year) {
          _cachedLeaveBalances = response.data!;
          _leaveBalancesLastFetch = DateTime.now();
        }
        
        debugPrint('LeaveService: Successfully fetched ${response.data!.length} leave balances');
        
        // Emit to stream for real-time updates
        _leaveBalancesController.add(response.data!);
        
        return LeaveApiResponse.success(response.data!);
      } else {
        debugPrint('LeaveService: Failed to fetch leave balances: ${response.error}');
        return LeaveApiResponse.error(response.error ?? 'Failed to fetch leave balances');
      }
    } catch (e) {
      debugPrint('LeaveService: Exception in getLeaveBalances: $e');
      return LeaveApiResponse.error('An error occurred while fetching leave balances: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  // Refresh all leave data and emit to streams
  Future<void> _refreshLeaveData() async {
    try {
      // Refresh leave requests
      final requestsResponse = await getLeaveRequests(forceRefresh: true);
      if (requestsResponse.isSuccess && requestsResponse.data != null) {
        _leaveRequestsController.add(requestsResponse.data!);
      }

      // Refresh leave balances
      final balancesResponse = await getLeaveBalances(forceRefresh: true);
      if (balancesResponse.isSuccess && balancesResponse.data != null) {
        _leaveBalancesController.add(balancesResponse.data!);
      }
    } catch (e) {
      debugPrint('LeaveService: Error refreshing leave data: $e');
    }
  }

  // Validate leave request before submission
  Future<LeaveApiResponse<bool>> _validateLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      // Basic validation
      if (leaveRequest.startDate.isAfter(leaveRequest.endDate)) {
        return LeaveApiResponse.error('Start date cannot be after end date');
      }

      if (leaveRequest.startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return LeaveApiResponse.error('Cannot apply for leave in the past');
      }

      if (leaveRequest.reason.trim().isEmpty) {
        return LeaveApiResponse.error('Reason is required');
      }

      // Get leave type to check advance notice requirement
      final leaveTypeResponse = await getLeaveTypeById(leaveRequest.leaveTypeId);
      if (leaveTypeResponse.isSuccess && leaveTypeResponse.data != null) {
        final leaveType = leaveTypeResponse.data!;

        // Check advance notice requirement
        final daysDifference = leaveRequest.startDate.difference(DateTime.now()).inDays;
        if (daysDifference < leaveType.advanceNoticeDays) {
          return LeaveApiResponse.error(
            'This leave type requires ${leaveType.advanceNoticeDays} days advance notice'
          );
        }
      }

      // Check leave balance
      final balancesResponse = await getLeaveBalances();
      if (balancesResponse.isSuccess && balancesResponse.data != null) {
        final balance = balancesResponse.data!
            .firstWhere((b) => b.leaveTypeId == leaveRequest.leaveTypeId,
                       orElse: () => throw Exception('Leave balance not found'));

        if (balance.remainingDays < leaveRequest.totalDays) {
          return LeaveApiResponse.error(
            'Insufficient leave balance. Available: ${balance.remainingDays} days'
          );
        }
      }

      return LeaveApiResponse.success(true);
    } catch (e) {
      debugPrint('LeaveService: Validation error: $e');
      return LeaveApiResponse.error('Validation failed: $e');
    }
  }

  // Get pending leave requests count
  Future<int> getPendingRequestsCount() async {
    try {
      final response = await getLeaveRequests(status: 'pending');
      if (response.isSuccess && response.data != null) {
        return response.data!.length;
      }
      return 0;
    } catch (e) {
      debugPrint('LeaveService: Error getting pending requests count: $e');
      return 0;
    }
  }

  // Get total remaining leave days
  Future<int> getTotalRemainingDays() async {
    try {
      final response = await getLeaveBalances();
      if (response.isSuccess && response.data != null) {
        return response.data!.fold<int>(0, (sum, balance) => sum + balance.remainingDays);
      }
      return 0;
    } catch (e) {
      debugPrint('LeaveService: Error getting total remaining days: $e');
      return 0;
    }
  }

  // Check if driver can apply for leave on specific dates
  Future<LeaveApiResponse<bool>> canApplyForLeave(DateTime startDate, DateTime endDate, int leaveTypeId) async {
    try {
      // Create a temporary leave request for validation
      final tempRequest = LeaveRequest(
        driverId: _authService.currentDriverId ?? 0,
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        totalDays: endDate.difference(startDate).inDays + 1,
        reason: 'Validation check',
        status: 'pending',
        appliedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _validateLeaveRequest(tempRequest);
    } catch (e) {
      debugPrint('LeaveService: Error checking leave availability: $e');
      return LeaveApiResponse.error('Error checking leave availability: $e');
    }
  }

  // Get leave requests by status
  Future<LeaveApiResponse<List<LeaveRequest>>> getLeaveRequestsByStatus(String status) async {
    return await getLeaveRequests(status: status);
  }

  // Get leave balance for specific leave type
  Future<LeaveApiResponse<LeaveBalance?>> getLeaveBalanceByType(int leaveTypeId) async {
    try {
      final response = await getLeaveBalances();
      if (response.isSuccess && response.data != null) {
        final balance = response.data!
            .firstWhere((b) => b.leaveTypeId == leaveTypeId,
                       orElse: () => throw Exception('Leave balance not found'));
        return LeaveApiResponse.success(balance);
      } else {
        return LeaveApiResponse.error(response.error ?? 'Failed to fetch leave balances');
      }
    } catch (e) {
      debugPrint('LeaveService: Error getting leave balance by type: $e');
      return LeaveApiResponse.error('Leave balance not found for this type');
    }
  }

  // Calculate total days between two dates (inclusive)
  int calculateLeaveDays(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays + 1;
  }

  // Check if a date falls within any approved leave period
  Future<bool> isDateInApprovedLeave(DateTime date) async {
    try {
      final response = await getLeaveRequests(status: 'approved');
      if (response.isSuccess && response.data != null) {
        for (final request in response.data!) {
          if (date.isAfter(request.startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(request.endDate.add(const Duration(days: 1)))) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('LeaveService: Error checking date in approved leave: $e');
      return false;
    }
  }
}
