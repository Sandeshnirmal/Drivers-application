# Driver Attendance with Photo and Location Capture

This guide explains the enhanced driver attendance system that captures live photos and geolocation data for both check-in and check-out operations.

## Features

### 🔐 Mandatory Photo Capture
- **Front camera selfie** required for both check-in and check-out
- **Real-time capture** using device camera
- **Base64 encoding** for secure transmission
- **Error handling** with user-friendly messages
- **Permission management** for camera access

### 📍 Mandatory Location Capture
- **GPS coordinates** captured for both check-in and check-out
- **High accuracy** location services
- **Permission management** for location access
- **Timeout handling** (30 seconds max)
- **Service availability checks**

### 🎯 Enhanced User Experience
- **Real-time feedback** during capture process
- **Loading indicators** and progress bars
- **Error messages** with retry options
- **Permission request dialogs**
- **Success confirmations**

## Implementation Details

### Core Service: AttendanceService

The `AttendanceService` class handles all attendance operations with mandatory photo and location capture:

```dart
// Check-in with mandatory photo and location
Future<AttendanceResult> checkIn({String? photoBase64}) async {
  // 1. Capture mandatory photo
  String? capturedPhoto = await _capturePhoto('check-in');
  if (capturedPhoto == null) {
    return AttendanceResult.error('Photo capture is required for check-in');
  }
  
  // 2. Capture mandatory location
  Position? position = await _getCurrentLocation();
  if (position == null) {
    return AttendanceResult.error('Location access is required for check-in');
  }
  
  // 3. Submit to backend API
  final response = await _apiService.driverLogin(
    driverId: driverId,
    loginTime: currentTime,
    latitude: position.latitude,
    longitude: position.longitude,
    photoBase64: capturedPhoto,
  );
}
```

### Photo Capture Process

1. **Permission Check**: Requests camera permission if not granted
2. **Camera Initialization**: Sets up front camera for selfie capture
3. **Photo Capture**: Takes high-quality photo using front camera
4. **Image Processing**: Compresses and converts to base64
5. **Error Handling**: Provides clear error messages for failures

### Location Capture Process

1. **Permission Check**: Requests location permission if not granted
2. **Service Check**: Verifies location services are enabled
3. **Position Acquisition**: Gets current GPS coordinates with high accuracy
4. **Timeout Handling**: 30-second timeout to prevent hanging
5. **Error Handling**: Clear messages for permission/service issues

## API Integration

### Check-in API Call
```dart
POST /hr/attendance/login/
{
  "driver": 123,
  "login_time": "09:00:00",
  "login_latitude": "24.7136",
  "login_longitude": "46.6753",
  "login_photo_base64": "data:image/jpeg;base64,/9j/4AAQ...",
  "platform": "mobile_app"
}
```

### Check-out API Call
```dart
PATCH /hr/attendance/{attendance_id}/logout/
{
  "logout_time": "17:00:00",
  "logout_latitude": "24.7136",
  "logout_longitude": "46.6753",
  "logout_photo_base64": "data:image/jpeg;base64,/9j/4AAQ..."
}
```

## UI Components

### PhotoCaptureDialog
- **Camera preview** with face guide overlay
- **Capture button** with loading states
- **Error handling** with retry options
- **Permission requests** with explanations

### LocationCaptureDialog
- **GPS animation** during location acquisition
- **Progress indicators** with timeout handling
- **Coordinate display** when successful
- **Error messages** with retry options

## Error Handling

### Photo Capture Errors
- **Camera permission denied**: Clear message with settings guidance
- **Camera initialization failed**: Retry option provided
- **Photo capture failed**: Technical error with retry
- **No front camera**: Fallback to rear camera

### Location Capture Errors
- **Location permission denied**: Settings guidance provided
- **Location services disabled**: System settings prompt
- **GPS timeout**: Retry with extended timeout
- **Low accuracy**: Warning with option to continue

## Usage Examples

### Basic Check-in
```dart
final result = await attendanceService.checkIn();
if (result.isSuccess) {
  // Check-in successful with photo and location
  print('✅ Check-in completed');
} else {
  // Handle error (photo/location capture failed)
  print('❌ Check-in failed: ${result.error}');
}
```

### Basic Check-out
```dart
final result = await attendanceService.checkOut();
if (result.isSuccess) {
  // Check-out successful with photo and location
  print('✅ Check-out completed');
} else {
  // Handle error (photo/location capture failed)
  print('❌ Check-out failed: ${result.error}');
}
```

### With Custom Photo
```dart
// Pre-capture photo (optional)
String? customPhoto = await cameraService.takePhoto();
final result = await attendanceService.checkIn(photoBase64: customPhoto);
```

## Security Features

### Photo Security
- **Base64 encoding** prevents file system access
- **Front camera only** ensures driver selfie
- **Immediate processing** no temporary files stored
- **Compression** reduces data size while maintaining quality

### Location Security
- **High accuracy GPS** prevents spoofing
- **Real-time capture** prevents cached coordinates
- **Permission validation** ensures user consent
- **Coordinate validation** on backend

## Testing

### Development Mode
During development, you can temporarily disable mandatory capture:

```dart
// In attendance_service.dart - for testing only
const bool TESTING_MODE = true;

if (TESTING_MODE && capturedPhoto == null) {
  capturedPhoto = 'test_photo_base64_data';
}

if (TESTING_MODE && position == null) {
  position = Position(latitude: 24.7136, longitude: 46.6753, ...);
}
```

### Production Mode
In production, all captures are mandatory and cannot be bypassed.

## Troubleshooting

### Common Issues

1. **Camera not working**: Check camera permissions in device settings
2. **Location not found**: Ensure GPS is enabled and location permissions granted
3. **Slow capture**: Check network connectivity and device performance
4. **Permission denied**: Guide user to device settings to enable permissions

### Debug Logging
Enable debug logging to troubleshoot issues:

```dart
debugPrint('📸 Photo capture status: $photoStatus');
debugPrint('📍 Location capture status: $locationStatus');
```

## Future Enhancements

- **Face detection** to ensure driver is in photo
- **Location validation** against authorized check-in points
- **Offline support** with sync when connection restored
- **Photo quality validation** to ensure clear images
- **Biometric authentication** for additional security
