import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/intelligent_alarm_service.dart';
import 'services/translation_service.dart';

class AlarmManagementScreen extends StatefulWidget {
  const AlarmManagementScreen({super.key});

  @override
  State<AlarmManagementScreen> createState() => _AlarmManagementScreenState();
}

class _AlarmManagementScreenState extends State<AlarmManagementScreen> {
  final IntelligentAlarmService _alarmService = IntelligentAlarmService();
  DateTime? _selectedShiftTime;
  bool _isLocationMonitoring = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    await _alarmService.initialize();
    if (mounted) {
      setState(() {
        _selectedShiftTime = _alarmService.assignedShiftTime;
        _isLocationMonitoring = _alarmService.isMonitoring;
      });
    }
  }

  Future<void> _selectShiftTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedShiftTime != null 
          ? TimeOfDay.fromDateTime(_selectedShiftTime!)
          : TimeOfDay.now(),
    );

    if (time != null) {
      final DateTime now = DateTime.now();
      final DateTime shiftDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time is in the past, set it for tomorrow
      final DateTime finalShiftTime = shiftDateTime.isBefore(now)
          ? shiftDateTime.add(const Duration(days: 1))
          : shiftDateTime;

      await _alarmService.setAssignedShiftTime(finalShiftTime);
      
      if (mounted) {
        setState(() {
          _selectedShiftTime = finalShiftTime;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shift time set for ${DateFormat('MMM dd, yyyy HH:mm').format(finalShiftTime)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleLocationMonitoring() async {
    if (_isLocationMonitoring) {
      _alarmService.stopLocationMonitoring();
    } else {
      await _alarmService.startLocationMonitoring();
    }

    if (mounted) {
      setState(() {
        _isLocationMonitoring = _alarmService.isMonitoring;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLocationMonitoring 
                ? 'Location monitoring started'
                : 'Location monitoring stopped'
          ),
          backgroundColor: _isLocationMonitoring ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('intelligent_alarms'.tr),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm, color: Colors.red.shade600, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'intelligent_alarms'.tr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure intelligent alerts for location monitoring and shift reminders',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Location Monitoring Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'location_monitoring'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Monitor if you stay in the same 30-meter radius for more than 15 minutes',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'monitoring_status'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: _isLocationMonitoring,
                          onChanged: (value) => _toggleLocationMonitoring(),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    if (_isLocationMonitoring)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Location monitoring is active',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Reminders Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.orange.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'time_reminders'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get reminders 1 hour, 30 minutes, and 15 minutes before your shift',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'set_shift_time'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectShiftTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedShiftTime != null 
                              ? DateFormat('HH:mm').format(_selectedShiftTime!)
                              : 'Select Time'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedShiftTime != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange.shade600, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Next shift: ${DateFormat('MMM dd, yyyy HH:mm').format(_selectedShiftTime!)}',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reminders will be sent at:',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '• ${DateFormat('HH:mm').format(_selectedShiftTime!.subtract(const Duration(hours: 1)))} (1 hour before)',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '• ${DateFormat('HH:mm').format(_selectedShiftTime!.subtract(const Duration(minutes: 30)))} (30 min before)',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '• ${DateFormat('HH:mm').format(_selectedShiftTime!.subtract(const Duration(minutes: 15)))} (15 min before)',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Features Info Card
            Card(
              elevation: 2,
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'Max Volume Alerts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Alerts will sound at maximum volume even in silent mode\n'
                      '• Strong haptic feedback for critical notifications\n'
                      '• Full-screen alerts that override other apps\n'
                      '• Persistent notifications until acknowledged',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't dispose the service here as it should run in background
    super.dispose();
  }
}
