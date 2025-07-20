import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../services/translation_service.dart';

class LeaveStatusCard extends StatelessWidget {
  final List<LeaveRequest> leaveRequests;
  final List<LeaveBalance> leaveBalances;
  final VoidCallback onRequestLeave;
  final Function(LeaveRequest) onCancelRequest;

  const LeaveStatusCard({
    super.key,
    required this.leaveRequests,
    required this.leaveBalances,
    required this.onRequestLeave,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    final pendingRequests = leaveRequests.where((r) => r.isPending).toList();
    final totalRemainingDays = leaveBalances.fold(0, (sum, balance) => sum + balance.remainingDays);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.beach_access,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'leave_management'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'manage_your_leave_requests'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onRequestLeave,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('request'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Leave Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'remaining_days'.tr,
                      totalRemainingDays.toString(),
                      Colors.green.shade600,
                      Icons.calendar_today,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'pending_requests'.tr,
                      pendingRequests.length.toString(),
                      Colors.orange.shade600,
                      Icons.pending_actions,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recent Leave Requests
            if (leaveRequests.isNotEmpty) ...[
              Text(
                'recent_requests'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...leaveRequests.take(3).map((request) => _buildLeaveRequestTile(context, request)),
              if (leaveRequests.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to full leave requests list
                    },
                    child: Text('view_all_requests'.tr),
                  ),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.beach_access,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'no_leave_requests'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'tap_request_to_submit_leave'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLeaveRequestTile(BuildContext context, LeaveRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.pending_actions;
        break;
      case 'approved':
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      request.leaveTypeName ?? 'Leave',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.statusDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${request.totalDays} day${request.totalDays > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (request.isPending) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showCancelConfirmation(context, request),
              icon: Icon(Icons.cancel_outlined, color: Colors.red.shade600),
              tooltip: 'Cancel Request',
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, LeaveRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancel_leave_request'.tr),
        content: Text('are_you_sure_cancel_leave'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('no'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancelRequest(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text('yes_cancel'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
