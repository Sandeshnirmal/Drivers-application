import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceStatusCard extends StatelessWidget {
  final DriverStatus driverStatus;

  const AttendanceStatusCard({
    super.key,
    required this.driverStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _getStatusColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          driverStatus.statusDisplayText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildStatusDetail('Message', driverStatus.message),
                    if (driverStatus.loginTime != null)
                      _buildStatusDetail('Check-in Time', driverStatus.loginTime!),
                    if (driverStatus.logoutTime != null)
                      _buildStatusDetail('Check-out Time', driverStatus.logoutTime!),
                    if (driverStatus.checkedInLocation != null)
                      _buildStatusDetail('Location', driverStatus.checkedInLocation!),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionChip(
                    'Can Check In',
                    driverStatus.canCheckIn,
                    Icons.login,
                  ),
                  const SizedBox(width: 8),
                  _buildActionChip(
                    'Can Check Out',
                    driverStatus.canCheckOut,
                    Icons.logout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getStatusColors() {
    switch (driverStatus.status) {
      case 'checked_in':
        return [Colors.green[600]!, Colors.green[400]!];
      case 'checked_out':
        return [Colors.blue[600]!, Colors.blue[400]!];
      case 'not_checked_in':
        return [Colors.orange[600]!, Colors.orange[400]!];
      default:
        return [Colors.grey[600]!, Colors.grey[400]!];
    }
  }

  IconData _getStatusIcon() {
    switch (driverStatus.status) {
      case 'checked_in':
        return Icons.work;
      case 'checked_out':
        return Icons.home;
      case 'not_checked_in':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildStatusDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, bool isEnabled, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled 
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isEnabled 
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isEnabled 
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
