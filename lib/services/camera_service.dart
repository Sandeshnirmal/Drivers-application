import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;

  // Initialize camera service
  Future<bool> initialize() async {
    try {
      debugPrint('🔍 Initializing camera service...');
      
      // Request camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        debugPrint('❌ Camera permission denied');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('❌ No cameras available');
        return false;
      }

      debugPrint('✅ Camera service initialized with ${_cameras!.length} cameras');
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      return false;
    }
  }

  // Get front camera for selfies
  CameraDescription? get frontCamera {
    if (_cameras == null) return null;
    
    try {
      return _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      // If no front camera, return the first available camera
      return _cameras!.isNotEmpty ? _cameras!.first : null;
    }
  }

  // Take a photo and return as base64 string
  Future<String?> takePhoto({bool useFrontCamera = true}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      // Select camera
      final camera = useFrontCamera ? frontCamera : _cameras!.first;
      if (camera == null) {
        debugPrint('❌ No suitable camera found');
        return null;
      }

      // Initialize camera controller
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      debugPrint('📸 Camera controller initialized');

      // Take picture
      final XFile photo = await _controller!.takePicture();
      debugPrint('📸 Photo captured: ${photo.path}');

      // Read image file
      final File imageFile = File(photo.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Compress and resize image
      final compressedBytes = await _compressImage(imageBytes);

      // Convert to base64
      final base64String = base64Encode(compressedBytes);
      debugPrint('📸 Photo converted to base64 (${compressedBytes.length} bytes)');

      // Clean up
      await _controller!.dispose();
      _controller = null;

      // Delete temporary file
      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('⚠️ Could not delete temp file: $e');
      }

      return base64String;
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      
      // Clean up on error
      if (_controller != null) {
        try {
          await _controller!.dispose();
          _controller = null;
        } catch (e) {
          debugPrint('⚠️ Error disposing camera controller: $e');
        }
      }
      
      return null;
    }
  }

  // Compress image to reduce size
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize image (max 800px width/height)
      const maxSize = 800;
      if (image.width > maxSize || image.height > maxSize) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: maxSize);
        } else {
          image = img.copyResize(image, height: maxSize);
        }
      }

      // Compress as JPEG with 85% quality
      final compressedBytes = img.encodeJpg(image, quality: 85);
      
      debugPrint('📸 Image compressed: ${imageBytes.length} -> ${compressedBytes.length} bytes');
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('⚠️ Error compressing image: $e');
      return imageBytes; // Return original if compression fails
    }
  }

  // Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Dispose resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

// Camera capture widget for easy integration
class CameraCaptureWidget extends StatefulWidget {
  final Function(String base64Photo) onPhotoTaken;
  final String buttonText;
  final IconData buttonIcon;

  const CameraCaptureWidget({
    super.key,
    required this.onPhotoTaken,
    this.buttonText = 'Take Photo',
    this.buttonIcon = Icons.camera_alt,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  final CameraService _cameraService = CameraService();
  bool _isCapturing = false;

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Check camera permission
      final hasPermission = await _cameraService.hasCameraPermission();
      if (!hasPermission) {
        final granted = await _cameraService.requestCameraPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera permission is required')),
            );
          }
          return;
        }
      }

      // Take photo
      final base64Photo = await _cameraService.takePhoto(useFrontCamera: true);
      if (base64Photo != null) {
        widget.onPhotoTaken(base64Photo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo captured successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture photo')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isCapturing ? null : _capturePhoto,
      icon: _isCapturing 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.buttonIcon),
      label: Text(_isCapturing ? 'Capturing...' : widget.buttonText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
