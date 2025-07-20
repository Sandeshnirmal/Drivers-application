import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationCaptureDialog extends StatefulWidget {
  final String context; // 'check-in' or 'check-out'
  final Function(Position?) onLocationObtained;

  const LocationCaptureDialog({
    super.key,
    required this.context,
    required this.onLocationObtained,
  });

  @override
  State<LocationCaptureDialog> createState() => _LocationCaptureDialogState();
}

class _LocationCaptureDialogState extends State<LocationCaptureDialog>
    with TickerProviderStateMixin {
  bool _isGettingLocation = true;
  String? _error;
  Position? _currentPosition;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isGettingLocation = true;
        _error = null;
      });

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission is required for ${widget.context}';
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission is permanently denied. Please enable it in settings.';
          _isGettingLocation = false;
        });
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable them in settings.';
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isGettingLocation = false;
        });

        // Auto-close after showing success for 2 seconds
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onLocationObtained(position);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to get location: $e';
          _isGettingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Getting Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                if (!_isGettingLocation && _error != null)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onLocationObtained(null);
                    },
                  ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Content
            _buildContent(),
            
            SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Column(
        children: [
          Icon(
            Icons.location_off,
            color: Colors.red,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_currentPosition != null) {
      return Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Location captured successfully!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.my_location, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.my_location, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Loading state
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                Icons.gps_fixed,
                color: Colors.blue.shade600,
                size: 64,
              ),
            );
          },
        ),
        SizedBox(height: 16),
        Text(
          'Obtaining your current location for ${widget.context}...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_currentPosition != null) {
      return SizedBox.shrink(); // Auto-closes, no buttons needed
    }

    if (_error != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLocationObtained(null);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      );
    }

    // Loading state - show cancel button
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        widget.onLocationObtained(null);
      },
      child: Text('Cancel'),
    );
  }
}
