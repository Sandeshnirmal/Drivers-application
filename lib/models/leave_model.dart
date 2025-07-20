class LeaveType {
  final int id;
  final String name;
  final String? description;
  final int maxDaysPerYear;
  final int maxConsecutiveDays;
  final bool requiresApproval;
  final bool requiresDocument;
  final int advanceNoticeDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveType({
    required this.id,
    required this.name,
    this.description,
    required this.maxDaysPerYear,
    required this.maxConsecutiveDays,
    required this.requiresApproval,
    required this.requiresDocument,
    required this.advanceNoticeDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      maxDaysPerYear: json['max_days_per_year'] as int,
      maxConsecutiveDays: json['max_consecutive_days'] as int,
      requiresApproval: json['requires_approval'] as bool,
      requiresDocument: json['requires_document'] as bool,
      advanceNoticeDays: json['advance_notice_days'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'max_days_per_year': maxDaysPerYear,
      'max_consecutive_days': maxConsecutiveDays,
      'requires_approval': requiresApproval,
      'requires_document': requiresDocument,
      'advance_notice_days': advanceNoticeDays,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LeaveRequest {
  final int? id;
  final int driverId;
  final String? driverName;
  final int leaveTypeId;
  final String? leaveTypeName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String? emergencyContact;
  final String? supportingDocument;
  final String status; // pending, approved, rejected, cancelled
  final DateTime appliedDate;
  final int? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedDate;
  final String? adminComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    this.id,
    required this.driverId,
    this.driverName,
    required this.leaveTypeId,
    this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.emergencyContact,
    this.supportingDocument,
    required this.status,
    required this.appliedDate,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedDate,
    this.adminComments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] != null ? json['id'] as int : null,
      driverId: json['driver'] as int,
      driverName: json['driver_name'] as String?,
      leaveTypeId: json['leave_type'] as int,
      leaveTypeName: json['leave_type_name'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalDays: json['total_days'] != null ? json['total_days'] as int : 0,
      reason: json['reason'] as String,
      emergencyContact: json['emergency_contact'] as String?,
      supportingDocument: json['supporting_document'] as String?,
      status: json['status'] as String,
      appliedDate: json['applied_date'] != null
          ? DateTime.parse(json['applied_date'] as String)
          : DateTime.now(),
      reviewedBy: json['reviewed_by'] != null ? json['reviewed_by'] as int : null,
      reviewedByName: json['reviewed_by_name'] as String?,
      reviewedDate: json['reviewed_date'] != null
          ? DateTime.parse(json['reviewed_date'] as String)
          : null,
      adminComments: json['admin_comments'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver': driverId,
      'leave_type': leaveTypeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_days': totalDays,
      'reason': reason,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (supportingDocument != null) 'supporting_document': supportingDocument,
      'status': status,
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}

class LeaveBalance {
  final int id;
  final int driverId;
  final int leaveTypeId;
  final String? leaveTypeName;
  final int year;
  final int allocatedDays;
  final int usedDays;
  final int pendingDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveBalance({
    required this.id,
    required this.driverId,
    required this.leaveTypeId,
    this.leaveTypeName,
    required this.year,
    required this.allocatedDays,
    required this.usedDays,
    required this.pendingDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'] as int,
      driverId: json['driver'] as int,
      leaveTypeId: json['leave_type'] as int,
      leaveTypeName: json['leave_type_name'] as String?,
      year: json['year'] as int,
      allocatedDays: json['allocated_days'] as int,
      usedDays: json['used_days'] as int,
      pendingDays: json['pending_days'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driverId,
      'leave_type': leaveTypeId,
      'year': year,
      'allocated_days': allocatedDays,
      'used_days': usedDays,
      'pending_days': pendingDays,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  int get remainingDays => allocatedDays - usedDays - pendingDays;
  int get availableDays => allocatedDays - usedDays;
  bool get hasRemainingDays => remainingDays > 0;
}

// Response wrapper for API responses
class LeaveApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final String? message;

  LeaveApiResponse({
    required this.isSuccess,
    this.data,
    this.error,
    this.message,
  });

  factory LeaveApiResponse.success(T data, {String? message}) {
    return LeaveApiResponse(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  factory LeaveApiResponse.error(String error) {
    return LeaveApiResponse(
      isSuccess: false,
      error: error,
    );
  }
}
