class Trip {
  final int id;
  final String tripId;
  final int driverId;
  final String? driverName;
  final int? companyId;
  final String? companyName;
  final int? vehicleId;
  final String? vehicleNumber;
  
  // Customer Information
  final String customerName;
  final String? customerPhone;
  final double? customerRating;
  
  // Trip Details
  final String tripType;
  final String pickupLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final DateTime? pickupTime;
  final String dropoffLocation;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final DateTime? dropoffTime;
  
  // Trip Metrics
  final double distanceKm;
  final int durationMinutes;
  final int waitingTimeMinutes;
  
  // Financial Information
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double waitingCharges;
  final double surgeMultiplier;
  final double totalFare;
  final double tipAmount;
  final double tollCharges;
  final double parkingCharges;
  final double additionalCharges;
  
  // Commission and Earnings
  final double platformCommissionRate;
  final double platformCommissionAmount;
  final double driverEarnings;
  final double totalEarnings;
  
  // Payment Information
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentReference;
  
  // Status and Tracking
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  // Additional Information
  final String? notes;
  final double? driverRating;
  final String? customerFeedback;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Trip({
    required this.id,
    required this.tripId,
    required this.driverId,
    this.driverName,
    this.companyId,
    this.companyName,
    this.vehicleId,
    this.vehicleNumber,
    required this.customerName,
    this.customerPhone,
    this.customerRating,
    required this.tripType,
    required this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupTime,
    required this.dropoffLocation,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.dropoffTime,
    required this.distanceKm,
    required this.durationMinutes,
    required this.waitingTimeMinutes,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.waitingCharges,
    required this.surgeMultiplier,
    required this.totalFare,
    required this.tipAmount,
    required this.tollCharges,
    required this.parkingCharges,
    required this.additionalCharges,
    required this.platformCommissionRate,
    required this.platformCommissionAmount,
    required this.driverEarnings,
    required this.totalEarnings,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentReference,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.notes,
    this.driverRating,
    this.customerFeedback,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      tripId: json['trip_id'] ?? '',
      driverId: json['driver'] ?? 0, // May be null in summary responses
      driverName: json['driver_name'],
      companyId: json['company'],
      companyName: json['company_name'],
      vehicleId: json['vehicle'],
      vehicleNumber: json['vehicle_number'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      customerRating: json['customer_rating']?.toDouble(),
      tripType: json['trip_type'] ?? 'regular',
      pickupLocation: json['pickup_location'] ?? '',
      pickupLatitude: json['pickup_latitude']?.toDouble(),
      pickupLongitude: json['pickup_longitude']?.toDouble(),
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'])
          : null,
      dropoffLocation: json['dropoff_location'] ?? '',
      dropoffLatitude: json['dropoff_latitude']?.toDouble(),
      dropoffLongitude: json['dropoff_longitude']?.toDouble(),
      dropoffTime: json['dropoff_time'] != null
          ? DateTime.parse(json['dropoff_time'])
          : null,
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 0,
      waitingTimeMinutes: json['waiting_time_minutes'] ?? 0,
      baseFare: double.tryParse(json['base_fare']?.toString() ?? '0') ?? 0.0,
      distanceFare: double.tryParse(json['distance_fare']?.toString() ?? '0') ?? 0.0,
      timeFare: double.tryParse(json['time_fare']?.toString() ?? '0') ?? 0.0,
      waitingCharges: double.tryParse(json['waiting_charges']?.toString() ?? '0') ?? 0.0,
      surgeMultiplier: double.tryParse(json['surge_multiplier']?.toString() ?? '1') ?? 1.0,
      totalFare: double.tryParse(json['total_fare']?.toString() ?? '0') ?? 0.0,
      tipAmount: double.tryParse(json['tip_amount']?.toString() ?? '0') ?? 0.0,
      tollCharges: double.tryParse(json['toll_charges']?.toString() ?? '0') ?? 0.0,
      parkingCharges: double.tryParse(json['parking_charges']?.toString() ?? '0') ?? 0.0,
      additionalCharges: double.tryParse(json['additional_charges']?.toString() ?? '0') ?? 0.0,
      platformCommissionRate: double.tryParse(json['platform_commission_rate']?.toString() ?? '0') ?? 0.0,
      platformCommissionAmount: double.tryParse(json['platform_commission_amount']?.toString() ?? '0') ?? 0.0,
      driverEarnings: double.tryParse(json['driver_earnings']?.toString() ?? '0') ?? 0.0,
      totalEarnings: json['total_earnings'] is num
          ? (json['total_earnings'] as num).toDouble()
          : double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentStatus: json['payment_status'] ?? 'completed',
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'completed',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      notes: json['notes'],
      driverRating: json['driver_rating']?.toDouble(),
      customerFeedback: json['customer_feedback'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      createdBy: json['created_by'] ?? 'mobile_app',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver': driverId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'trip_type': tripType,
      'pickup_location': pickupLocation,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_time': pickupTime?.toIso8601String(),
      'dropoff_location': dropoffLocation,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'dropoff_time': dropoffTime?.toIso8601String(),
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'waiting_time_minutes': waitingTimeMinutes,
      'base_fare': baseFare,
      'tip_amount': tipAmount,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }
}

class TripStats {
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double totalEarnings;
  final double totalTips;
  final double totalDistance;
  final int totalDuration;
  final double averageTripEarnings;
  final double averageTripDistance;
  final int cashTrips;
  final int digitalTrips;
  final double cashEarnings;
  final double digitalEarnings;

  TripStats({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.totalEarnings,
    required this.totalTips,
    required this.totalDistance,
    required this.totalDuration,
    required this.averageTripEarnings,
    required this.averageTripDistance,
    required this.cashTrips,
    required this.digitalTrips,
    required this.cashEarnings,
    required this.digitalEarnings,
  });

  factory TripStats.fromJson(Map<String, dynamic> json) {
    return TripStats(
      totalTrips: json['total_trips'] ?? 0,
      completedTrips: json['completed_trips'] ?? 0,
      cancelledTrips: json['cancelled_trips'] ?? 0,
      totalEarnings: double.parse(json['total_earnings']?.toString() ?? '0'),
      totalTips: double.parse(json['total_tips']?.toString() ?? '0'),
      totalDistance: double.parse(json['total_distance']?.toString() ?? '0'),
      totalDuration: json['total_duration'] ?? 0,
      averageTripEarnings: double.parse(json['average_trip_earnings']?.toString() ?? '0'),
      averageTripDistance: double.parse(json['average_trip_distance']?.toString() ?? '0'),
      cashTrips: json['cash_trips'] ?? 0,
      digitalTrips: json['digital_trips'] ?? 0,
      cashEarnings: double.parse(json['cash_earnings']?.toString() ?? '0'),
      digitalEarnings: double.parse(json['digital_earnings']?.toString() ?? '0'),
    );
  }
}
