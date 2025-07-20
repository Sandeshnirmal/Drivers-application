import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'translation_service.dart';

class IntelligentAlarmService {
  static final IntelligentAlarmService _instance = IntelligentAlarmService._internal();
  factory IntelligentAlarmService() => _instance;
  IntelligentAlarmService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Location monitoring
  Timer? _locationMonitorTimer;
  Position? _lastKnownPosition;
  DateTime? _stationaryStartTime;
  bool _isMonitoring = false;
  
  // Time-based reminders
  Timer? _timeReminderTimer;
  DateTime? _assignedShiftTime;
  final List<Timer> _activeTimers = [];

  // Constants
  static const double _stationaryRadiusMeters = 30.0;
  static const Duration _stationaryDuration = Duration(minutes: 15);
  static const List<Duration> _reminderIntervals = [
    Duration(hours: 1),
    Duration(minutes: 30),
    Duration(minutes: 15),
  ];

  bool _isInitialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeNotifications();
    await _loadSettings();
    
    _isInitialized = true;
    debugPrint('🚨 IntelligentAlarmService initialized');
  }

  // Initialize notifications with high priority
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // For critical alerts
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for critical notifications
    await _requestCriticalPermissions();
  }

  // Request critical notification permissions
  Future<void> _requestCriticalPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting critical permissions: $e');
    }
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final shiftTimeString = prefs.getString('assigned_shift_time');
    if (shiftTimeString != null) {
      _assignedShiftTime = DateTime.parse(shiftTimeString);
    }
  }

  // Set assigned shift time
  Future<void> setAssignedShiftTime(DateTime shiftTime) async {
    _assignedShiftTime = shiftTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('assigned_shift_time', shiftTime.toIso8601String());
    
    await _scheduleTimeBasedReminders();
    debugPrint('🕐 Assigned shift time set: ${shiftTime.toString()}');
  }

  // Start location monitoring
  Future<void> startLocationMonitoring() async {
    if (_isMonitoring) return;

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Location permissions denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permissions permanently denied');
      return;
    }

    _isMonitoring = true;
    _locationMonitorTimer = Timer.periodic(
      const Duration(minutes: 1), // Check every minute
      (timer) => _checkLocationStatus(),
    );

    debugPrint('📍 Location monitoring started');
  }

  // Stop location monitoring
  void stopLocationMonitoring() {
    _locationMonitorTimer?.cancel();
    _locationMonitorTimer = null;
    _isMonitoring = false;
    _lastKnownPosition = null;
    _stationaryStartTime = null;
    debugPrint('📍 Location monitoring stopped');
  }

  // Check location status
  Future<void> _checkLocationStatus() async {
    try {
      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_lastKnownPosition == null) {
        _lastKnownPosition = currentPosition;
        _stationaryStartTime = DateTime.now();
        return;
      }

      // Calculate distance from last known position
      final double distance = Geolocator.distanceBetween(
        _lastKnownPosition!.latitude,
        _lastKnownPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (distance <= _stationaryRadiusMeters) {
        // Driver is still in the same location
        if (_stationaryStartTime != null) {
          final Duration stationaryDuration = DateTime.now().difference(_stationaryStartTime!);
          
          if (stationaryDuration >= _stationaryDuration) {
            await _triggerStationaryAlarm(stationaryDuration);
            // Reset timer to avoid repeated alarms
            _stationaryStartTime = DateTime.now();
          }
        }
      } else {
        // Driver has moved, reset stationary tracking
        _lastKnownPosition = currentPosition;
        _stationaryStartTime = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
    }
  }

  // Schedule time-based reminders
  Future<void> _scheduleTimeBasedReminders() async {
    if (_assignedShiftTime == null) return;

    // Cancel existing timers
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    final DateTime now = DateTime.now();
    
    for (final Duration interval in _reminderIntervals) {
      final DateTime reminderTime = _assignedShiftTime!.subtract(interval);
      
      if (reminderTime.isAfter(now)) {
        final Duration delay = reminderTime.difference(now);
        
        final Timer timer = Timer(delay, () {
          _triggerTimeBasedReminder(interval);
        });
        
        _activeTimers.add(timer);
        debugPrint('⏰ Scheduled reminder for ${interval.inMinutes} minutes before shift');
      }
    }
  }

  // Trigger stationary alarm
  Future<void> _triggerStationaryAlarm(Duration stationaryDuration) async {
    await _showCriticalNotification(
      id: 1001,
      title: 'stationary_alert_title'.tr,
      body: 'stationary_alert_message'.tr.replaceAll(
        '{duration}', 
        '${stationaryDuration.inMinutes}',
      ),
      payload: 'stationary_alert',
    );

    // Trigger haptic feedback
    await _triggerMaxVolumeAlert();
    
    debugPrint('🚨 Stationary alarm triggered - Duration: ${stationaryDuration.inMinutes} minutes');
  }

  // Trigger time-based reminder
  Future<void> _triggerTimeBasedReminder(Duration timeUntilShift) async {
    String title;
    String body;
    
    if (timeUntilShift.inHours >= 1) {
      title = 'shift_reminder_1h_title'.tr;
      body = 'shift_reminder_1h_message'.tr;
    } else if (timeUntilShift.inMinutes >= 30) {
      title = 'shift_reminder_30m_title'.tr;
      body = 'shift_reminder_30m_message'.tr;
    } else {
      title = 'shift_reminder_15m_title'.tr;
      body = 'shift_reminder_15m_message'.tr;
    }

    await _showCriticalNotification(
      id: 1002 + timeUntilShift.inMinutes,
      title: title,
      body: body,
      payload: 'shift_reminder_${timeUntilShift.inMinutes}',
    );

    await _triggerMaxVolumeAlert();
    
    debugPrint('⏰ Time-based reminder triggered - ${timeUntilShift.inMinutes} minutes until shift');
  }

  // Show critical notification with max priority
  Future<void> _showCriticalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'critical_alerts',
      'Critical Alerts',
      channelDescription: 'Critical driver alerts that override silent mode',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      autoCancel: false,
      ongoing: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: true,
      sound: null, // Use default system sound
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Trigger maximum volume alert with haptic feedback
  Future<void> _triggerMaxVolumeAlert() async {
    try {
      // Trigger strong haptic feedback
      await HapticFeedback.heavyImpact();
      
      // Wait and trigger again for emphasis
      await Future.delayed(const Duration(milliseconds: 500));
      await HapticFeedback.heavyImpact();
      
      await Future.delayed(const Duration(milliseconds: 500));
      await HapticFeedback.heavyImpact();
      
    } catch (e) {
      debugPrint('Error triggering haptic feedback: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    debugPrint('Critical notification tapped: $payload');
    
    if (payload != null) {
      _handleAlarmAction(payload);
    }
  }

  // Handle alarm actions
  void _handleAlarmAction(String payload) {
    switch (payload) {
      case 'stationary_alert':
        debugPrint('Handling stationary alert action');
        break;
      case 'shift_reminder_60':
      case 'shift_reminder_30':
      case 'shift_reminder_15':
        debugPrint('Handling shift reminder action');
        break;
      default:
        debugPrint('Unknown alarm payload: $payload');
    }
  }

  // Get monitoring status
  bool get isMonitoring => _isMonitoring;
  
  // Get assigned shift time
  DateTime? get assignedShiftTime => _assignedShiftTime;

  // Dispose service
  void dispose() {
    stopLocationMonitoring();
    _timeReminderTimer?.cancel();
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    debugPrint('🚨 IntelligentAlarmService disposed');
  }
}
