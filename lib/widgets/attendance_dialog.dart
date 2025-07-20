import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import '../services/attendance_service.dart';
import '../services/auth_service.dart';

class AttendanceDialog extends StatefulWidget {
  final bool isCheckIn;
  final Function(bool success, String message) onComplete;

  const AttendanceDialog({
    super.key,
    required this.isCheckIn,
    required this.onComplete,
  });

  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  // Step tracking
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // Data collection
  File? _capturedPhoto;
  Position? _currentLocation;
  String? _locationName;

  
  // Controllers
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint('AttendanceDialog: Starting camera capture...');

      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      debugPrint('AttendanceDialog: Camera permission status: $cameraStatus');

      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        throw Exception('Camera permission is required for attendance verification');
      }

      debugPrint('AttendanceDialog: Opening camera...');

      // Capture photo from camera only
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.front, // Front camera for selfies
      );

      if (photo != null) {
        debugPrint('AttendanceDialog: Photo captured successfully: ${photo.path}');
        setState(() {
          _capturedPhoto = File(photo.path);
          _currentStep = 1; // Move to location step
        });
      } else {
        debugPrint('AttendanceDialog: Photo capture was cancelled by user');
        // User cancelled camera
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo capture is required for attendance'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('AttendanceDialog: Camera capture error: $e');

      if (mounted) {
        String errorMessage;

        if (e.toString().toLowerCase().contains('permission')) {
          errorMessage = 'Camera permission denied. Please allow camera access in settings.';
        } else if (e.toString().toLowerCase().contains('camera_access_denied')) {
          errorMessage = 'Camera access denied. Please check app permissions.';
        } else if (e.toString().toLowerCase().contains('camera')) {
          errorMessage = 'Camera unavailable. Please close other camera apps and try again.';
        } else {
          errorMessage = 'Failed to open camera. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _capturePhoto,
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentLocation = position;
        _locationName = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _currentStep = 2; // Move to confirmation step
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_capturedPhoto == null || _currentLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo and location are required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final driver = _authService.currentDriver;
      if (driver == null) {
        throw Exception('Driver not authenticated');
      }

      // Convert photo to base64
      final bytes = await _capturedPhoto!.readAsBytes();
      final base64Photo = base64Encode(bytes);

      final response = widget.isCheckIn
          ? await _attendanceService.checkIn(photoBase64: base64Photo)
          : await _attendanceService.checkOut(photoBase64: base64Photo);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete(
          response.isSuccess,
          response.error ?? (widget.isCheckIn ? 'Check-in successful' : 'Check-out successful'),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onComplete(false, 'Error: $e');
        Navigator.of(context).pop();
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(0, 'Photo', Icons.camera_alt),
        _buildStepLine(0),
        _buildStepCircle(1, 'Location', Icons.location_on),
        _buildStepLine(1),
        _buildStepCircle(2, 'Confirm', Icons.check_circle),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.blue
                    : Colors.grey.shade300,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey.shade600,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = _currentStep > step;
    
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isCompleted ? Colors.green : Colors.grey.shade300,
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.camera_alt,
          size: 80,
          color: Colors.blue.shade600,
        ),
        const SizedBox(height: 20),
        Text(
          widget.isCheckIn ? 'Take Check-in Photo' : 'Take Check-out Photo',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Please take a clear selfie for attendance verification',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _capturePhoto,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(_isProcessing ? 'Opening Camera...' : 'Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.location_on,
          size: 80,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 20),
        const Text(
          'Get Current Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We need your location to verify attendance',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _getCurrentLocation,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(_isProcessing ? 'Getting Location...' : 'Get Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.orange.shade600,
        ),
        const SizedBox(height: 20),
        Text(
          widget.isCheckIn ? 'Confirm Check-in' : 'Confirm Check-out',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Photo Preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Photo Captured',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                ],
              ),
              if (_capturedPhoto != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _capturedPhoto!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Location Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Location Captured',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                ],
              ),
              if (_locationName != null) ...[
                const SizedBox(height: 8),
                Text(
                  _locationName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _submitAttendance,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(widget.isCheckIn ? Icons.login : Icons.logout),
            label: Text(_isProcessing
                ? (widget.isCheckIn ? 'Checking In...' : 'Checking Out...')
                : (widget.isCheckIn ? 'Confirm Check-in' : 'Confirm Check-out')),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isCheckIn ? Colors.green.shade600 : Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isCheckIn ? Colors.green.shade600 : Colors.red.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isCheckIn ? Icons.login : Icons.logout,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isCheckIn ? 'Check In' : 'Check Out',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Step Indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildStepIndicator(),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _currentStep == 0
                    ? _buildPhotoStep()
                    : _currentStep == 1
                        ? _buildLocationStep()
                        : _buildConfirmationStep(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
