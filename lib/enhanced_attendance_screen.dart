import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'models/attendance_model.dart';
import 'models/leave_model.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/leave_service.dart';
import 'services/translation_service.dart';
import 'widgets/attendance_status_card.dart';
import 'widgets/leave_status_card.dart';
import 'widgets/leave_request_dialog.dart';
import 'widgets/attendance_dialog.dart';
import 'widgets/enhanced_bottom_navigation.dart';

class EnhancedAttendanceScreen extends StatefulWidget {
  const EnhancedAttendanceScreen({super.key});

  @override
  State<EnhancedAttendanceScreen> createState() => _EnhancedAttendanceScreenState();
}

class _EnhancedAttendanceScreenState extends State<EnhancedAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();
  final LeaveService _leaveService = LeaveService();

  DriverStatus? _driverStatus;
  List<CheckinLocation> _authorizedLocations = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Leave-related state
  List<LeaveType> _leaveTypes = [];
  List<LeaveRequest> _leaveRequests = [];
  List<LeaveBalance> _leaveBalances = [];
  bool _isLoadingLeave = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Load driver status, locations, and leave data in parallel
      final results = await Future.wait([
        _attendanceService.getDriverStatus(),
        _attendanceService.getDriverLocations(),
        _loadLeaveData(),
      ]);

      if (mounted) {
        setState(() {
          _driverStatus = results[0] as DriverStatus?;
          _authorizedLocations = results[1] as List<CheckinLocation>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load driver data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLeaveData() async {
    if (mounted) {
      setState(() {
        _isLoadingLeave = true;
      });
    }

    try {
      // Load leave types, requests, and balances sequentially to avoid type issues
      final leaveTypesResponse = await _leaveService.getLeaveTypes();
      final leaveRequestsResponse = await _leaveService.getLeaveRequests();
      final leaveBalancesResponse = await _leaveService.getLeaveBalances();

      if (mounted) {
        setState(() {
          if (leaveTypesResponse.isSuccess) _leaveTypes = leaveTypesResponse.data!;
          if (leaveRequestsResponse.isSuccess) _leaveRequests = leaveRequestsResponse.data!;
          if (leaveBalancesResponse.isSuccess) _leaveBalances = leaveBalancesResponse.data!;
          _isLoadingLeave = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLeave = false;
        });
      }
      debugPrint('Failed to load leave data: $e');
    }
  }

  Future<void> _handleCheckIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttendanceDialog(
        isCheckIn: true,
        onComplete: (success, message) {
          setState(() {
            if (success) {
              _successMessage = message;
              _errorMessage = null;
            } else {
              _errorMessage = message;
              _successMessage = null;
            }
          });

          if (success) {
            HapticFeedback.lightImpact();
            _loadDriverData(); // Refresh attendance data
          } else {
            HapticFeedback.heavyImpact();
          }
        },
      ),
    );
  }

  Future<void> _handleCheckOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttendanceDialog(
        isCheckIn: false,
        onComplete: (success, message) {
          setState(() {
            if (success) {
              _successMessage = message;
              _errorMessage = null;
            } else {
              _errorMessage = message;
              _successMessage = null;
            }
          });

          if (success) {
            HapticFeedback.lightImpact();
            _loadDriverData(); // Refresh attendance data
          } else {
            HapticFeedback.heavyImpact();
          }
        },
      ),
    );
  }

  Future<void> _handleLeaveRequest() async {
    if (_leaveTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading leave types...')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => LeaveRequestDialog(
        leaveTypes: _leaveTypes,
        onLeaveRequestSubmitted: (leaveRequest) {
          setState(() {
            _leaveRequests.insert(0, leaveRequest);
          });
          _loadLeaveData(); // Refresh leave data
        },
      ),
    );
  }

  Future<void> _handleCancelLeaveRequest(LeaveRequest request) async {
    try {
      final response = await _leaveService.cancelLeaveRequest(request.id!);

      if (response.isSuccess) {
        setState(() {
          final index = _leaveRequests.indexWhere((r) => r.id == request.id);
          if (index != -1) {
            _leaveRequests[index] = response.data!;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Leave request cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadLeaveData(); // Refresh leave data
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to cancel leave request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'attendance'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDriverData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDriverData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver Info Card
                    _buildDriverInfoCard(),
                    const SizedBox(height: 16),
                    
                    // Status Messages
                    if (_errorMessage != null) _buildErrorMessage(),
                    if (_successMessage != null) _buildSuccessMessage(),
                    
                    // Driver Status Card
                    if (_driverStatus != null) 
                      AttendanceStatusCard(driverStatus: _driverStatus!),
                    const SizedBox(height: 16),
                    
                    // Mandatory Requirements Card
                    _buildMandatoryRequirementsCard(),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 16),

                    // Leave Management Card
                    if (!_isLoadingLeave)
                      LeaveStatusCard(
                        leaveRequests: _leaveRequests,
                        leaveBalances: _leaveBalances,
                        onRequestLeave: _handleLeaveRequest,
                        onCancelRequest: _handleCancelLeaveRequest,
                      ),
                    const SizedBox(height: 16),

                    // Authorized Locations
                    _buildAuthorizedLocationsCard(),
                    const SizedBox(height: 16),

                    // Current Attendance Details
                    if (_attendanceService.currentAttendance != null)
                      _buildCurrentAttendanceCard(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const EnhancedBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildDriverInfoCard() {
    final driver = _authService.currentDriver;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                driver?.driverName.isNotEmpty == true
                    ? driver!.driverName.substring(0, 1).toUpperCase()
                    : 'D',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver?.driverName ?? 'Driver',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${driver?.id ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryRequirementsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Mandatory Requirements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            icon: Icons.camera_alt,
            title: 'Photo Capture',
            description: 'Take a selfie for attendance verification',
            color: Colors.blue[600]!,
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            icon: Icons.location_on,
            title: 'Location Sharing',
            description: 'Enable GPS to share your current location',
            color: Colors.green[600]!,
          ),
          const SizedBox(height: 12),
          Text(
            '⚠️ Both photo and location are required for check-in and check-out',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canCheckIn = _driverStatus?.canCheckIn ?? false;
    final canCheckOut = _driverStatus?.canCheckOut ?? false;

    return Column(
      children: [
        // Check In/Out Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canCheckIn ? _handleCheckIn : null,
                icon: const Icon(Icons.login),
                label: const Text('Check In\n📸 📍'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canCheckOut ? _handleCheckOut : null,
                icon: const Icon(Icons.logout),
                label: const Text('Check Out\n📸 📍'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Leave Request Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _leaveTypes.isNotEmpty ? _handleLeaveRequest : null,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Request Leave'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorizedLocationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Authorized Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_authorizedLocations.isEmpty)
              Text(
                'No authorized locations found',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...(_authorizedLocations.map((location) => _buildLocationItem(location))),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(CheckinLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: location.isDriverSpecific ? Colors.blue[600] : Colors.green[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Radius: ${location.radiusMeters}m • ${location.isDriverSpecific ? 'Personal' : 'General'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAttendanceCard() {
    final attendance = _attendanceService.currentAttendance!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Current Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAttendanceDetail('Status', attendance.statusDisplayText),
            if (attendance.loginTime != null)
              _buildAttendanceDetail('Check-in Time', attendance.loginTime!),
            if (attendance.logoutTime != null)
              _buildAttendanceDetail('Check-out Time', attendance.logoutTime!),
            if (attendance.checkedInLocation != null)
              _buildAttendanceDetail('Location', attendance.checkedInLocation!.name),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
