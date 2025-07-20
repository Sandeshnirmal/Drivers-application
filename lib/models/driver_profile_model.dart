// driver_profile_model.dart

class DriverProfile {
  final int id;
  final Vehicle vehicle;
  final Company company;
  final String status;
  final String remarks;
  final String driverName;
  final String? driverProfileImg; // Can be null
  final String gender;
  final String iqama;
  final String mobile;
  final String city;
  final String nationality;
  final String dob;
  final String? iqamaDocument; // Can be null
  final String? iqamaExpiry; // Can be null
  final String? passportDocument; // Can be null
  final String? passportExpiry; // Can be null
  final String? licenseDocument; // Can be null
  final String? licenseExpiry; // Can be null
  final String? visaDocument; // Can be null
  final String? visaExpiry; // Can be null
  final String? medicalDocument; // Can be null
  final String? medicalExpiry; // Can be null
  final String insurancePaidBy;
  final String accommodationPaidBy;
  final String phoneBillPaidBy;
  final String createdAt;

  DriverProfile({
    required this.id,
    required this.vehicle,
    required this.company,
    required this.status,
    required this.remarks,
    required this.driverName,
    this.driverProfileImg,
    required this.gender,
    required this.iqama,
    required this.mobile,
    required this.city,
    required this.nationality,
    required this.dob,
    this.iqamaDocument,
    this.iqamaExpiry,
    this.passportDocument,
    this.passportExpiry,
    this.licenseDocument,
    this.licenseExpiry,
    this.visaDocument,
    this.visaExpiry,
    this.medicalDocument,
    this.medicalExpiry,
    required this.insurancePaidBy,
    required this.accommodationPaidBy,
    required this.phoneBillPaidBy,
    required this.createdAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as int,
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : Vehicle(
              id: (json['vehicle'] as int?) ?? 0,
              vehicleName: 'Loading...',
              vehicleNumber: 'Loading...',
              vehicleType: 'Loading...',
            ), // Handle both int and nested object
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      status: json['status']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      driverProfileImg: json['driver_profile_img'] as String?,
      gender: json['gender']?.toString() ?? '',
      iqama: json['iqama']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      iqamaDocument: json['iqama_document'] as String?,
      iqamaExpiry: json['iqama_expiry'] as String?,
      passportDocument: json['passport_document'] as String?,
      passportExpiry: json['passport_expiry'] as String?,
      licenseDocument: json['license_document'] as String?,
      licenseExpiry: json['license_expiry'] as String?,
      visaDocument: json['visa_document'] as String?,
      visaExpiry: json['visa_expiry'] as String?,
      medicalDocument: json['medical_document'] as String?,
      medicalExpiry: json['medical_expiry'] as String?,
      insurancePaidBy: json['insurance_paid_by']?.toString() ?? '',
      accommodationPaidBy: json['accommodation_paid_by']?.toString() ?? '',
      phoneBillPaidBy: json['phone_bill_paid_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Vehicle {
  final int id;
  final String vehicleName;
  final String vehicleNumber;
  final String vehicleType;

  Vehicle({
    required this.id,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] as int?) ?? 0,
      vehicleName: json['vehicle_name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
    );
  }
}

class Company {
  final int id;
  final String companyName;

  Company({
    required this.id,
    required this.companyName,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: (json['id'] as int?) ?? 0,
      companyName: json['company_name']?.toString() ?? '',
    );
  }
}