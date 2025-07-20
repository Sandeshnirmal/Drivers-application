import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'mobile_features_service.dart';
import '../models/driver_profile_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final MobileFeaturesService _mobileService = MobileFeaturesService();

  // Current user state
  DriverProfile? _currentDriver;
  bool _isAuthenticated = false;

  // Getters
  DriverProfile? get currentDriver => _currentDriver;
  bool get isAuthenticated => _isAuthenticated;
  int? get currentDriverId => _currentDriver?.id;

  // Initialize auth service
  Future<void> initialize() async {
    await _apiService.initialize();
    // Clear any expired tokens to prevent 401 errors
    await _apiService.clearExpiredTokens();
    await _loadStoredUser();
  }

  // Load stored user data
  Future<void> _loadStoredUser() async {
    try {
      // Disable auto-login - always require credentials on app launch
      debugPrint('Auto-login disabled - user must login manually');
      await _clearStoredUser();
    } catch (e) {
      debugPrint('Error clearing stored user: $e');
      await _clearStoredUser();
    }
  }

  // Save user data to storage
  Future<void> _saveUserData(DriverProfile driver) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_driver', jsonEncode(driver.toJson()));
      await prefs.setBool('is_authenticated', true);
      _currentDriver = driver;
      _isAuthenticated = true;
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Clear stored user data
  Future<void> _clearStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_driver');
      await prefs.setBool('is_authenticated', false);
      _currentDriver = null;
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  // Login with username and password (Driver Mobile Login)
  Future<AuthResult> login(String username, String password) async {
    try {
      _mobileService.mediumHaptic();

      // Attempt login via driver mobile API
      final loginResponse = await _apiService.login(username, password);

      if (!loginResponse.isSuccess) {
        _mobileService.heavyHaptic();
        return AuthResult.error(loginResponse.error ?? 'Login failed');
      }

      final loginData = loginResponse.data!;

      // Driver mobile login returns driver data directly
      if (loginData['driver'] != null) {
        debugPrint('Driver login successful: ${loginData['message']}');
        try {
          // Create driver profile from login response data
          final driverData = loginData['driver'];
          debugPrint('Creating driver profile from login data: $driverData');

          // Create a basic driver profile with the available data
          final driverProfile = DriverProfile(
            id: driverData['id'],
            driverName: driverData['name'] ?? 'Unknown Driver',
            mobile: driverData['mobile'] ?? '',
            iqama: driverData['iqama'] ?? '',
            status: driverData['status'] ?? 'active',
            driverProfileImg: driverData['profile_image'],
            // Set default values for required fields that aren't in login response
            vehicle: Vehicle(
              id: 0,
              vehicleName: 'Not Assigned',
              vehicleNumber: 'N/A',
              vehicleType: 'N/A',
            ),
            company: Company(
              id: 0,
              companyName: 'Default Company',
            ),
            gender: 'male', // Default value
            city: 'Riyadh', // Default value
            nationality: 'Saudi Arabia', // Default value
            dob: '1990-01-01', // Default value
            iqamaDocument: null,
            iqamaExpiry: null,
            passportDocument: null,
            passportExpiry: null,
            licenseDocument: null,
            licenseExpiry: null,
            visaDocument: null,
            visaExpiry: null,
            medicalDocument: null,
            medicalExpiry: null,
            insurancePaidBy: 'company', // Default value
            accommodationPaidBy: 'company', // Default value
            phoneBillPaidBy: 'company', // Default value
            remarks: 'Mobile app user',
            createdAt: DateTime.now().toIso8601String(),
          );

          await _saveUserData(driverProfile);
          _mobileService.lightHaptic();
          return AuthResult.success(driverProfile);
        } catch (e) {
          debugPrint('Error creating driver profile: $e');
          _mobileService.heavyHaptic();
          return AuthResult.error('Error creating driver profile: $e');
        }
      } else {
        debugPrint('Driver data not found in login response');
        _mobileService.heavyHaptic();
        return AuthResult.error('Driver profile not found. Please contact your administrator.');
      }
    } catch (e) {
      _mobileService.heavyHaptic();
      debugPrint('Login error: $e');
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Biometric login
  Future<AuthResult> biometricLogin() async {
    try {
      // Check if biometric is available and enabled
      final isAvailable = await _mobileService.isBiometricAvailable();
      final isEnabled = await _mobileService.isBiometricEnabled();

      if (!isAvailable || !isEnabled) {
        return AuthResult.error('Biometric authentication not available or disabled');
      }

      // Check if we have stored credentials
      final storedEmail = await _mobileService.getSecureData('stored_email');
      final storedUserId = await _mobileService.getSecureData('stored_user_id');

      if (storedEmail == null || storedUserId == null) {
        return AuthResult.error('No stored credentials for biometric login');
      }

      // Perform biometric authentication
      final authenticated = await _mobileService.authenticateWithBiometrics(
        reason: 'Authenticate to access your driver account',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (!authenticated) {
        _mobileService.heavyHaptic();
        return AuthResult.error('Biometric authentication failed');
      }

      // For biometric login, just return the stored user data
      if (_currentDriver != null) {
        _mobileService.lightHaptic();
        return AuthResult.success(_currentDriver!);
      } else {
        _mobileService.heavyHaptic();
        return AuthResult.error('No stored driver profile found');
      }
    } catch (e) {
      _mobileService.heavyHaptic();
      debugPrint('Biometric login error: $e');
      return AuthResult.error('Biometric login failed: ${e.toString()}');
    }
  }

  // Enable biometric login (store credentials securely)
  Future<bool> enableBiometricLogin(String email, int userId) async {
    try {
      final success1 = await _mobileService.saveSecureData('stored_email', email);
      final success2 = await _mobileService.saveSecureData('stored_user_id', userId.toString());
      final success3 = await _mobileService.setBiometricEnabled(true);

      return success1 && success2 && success3;
    } catch (e) {
      debugPrint('Error enabling biometric login: $e');
      return false;
    }
  }

  // Disable biometric login
  Future<bool> disableBiometricLogin() async {
    try {
      await _mobileService.removeSecureData('stored_email');
      await _mobileService.removeSecureData('stored_user_id');
      await _mobileService.setBiometricEnabled(false);
      return true;
    } catch (e) {
      debugPrint('Error disabling biometric login: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _mobileService.selectionHaptic();
      
      // Clear API tokens
      await _apiService.logout();
      
      // Clear stored user data
      await _clearStoredUser();
      
      // Clear biometric data if user chooses
      // Note: We don't automatically clear biometric data on logout
      // User can disable it manually in settings
      
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Refresh current user data
  Future<bool> refreshUserData() async {
    if (!_isAuthenticated || _currentDriver == null) return false;

    try {
      final userResponse = await _apiService.getCurrentUser();

      if (userResponse.isSuccess && userResponse.data != null) {
        // Update driver profile with fresh data from server
        final userData = userResponse.data!;
        final updatedProfile = DriverProfile(
          id: userData['id'] as int,
          vehicle: _currentDriver!.vehicle, // Keep existing vehicle data
          company: _currentDriver!.company, // Keep existing company data
          status: 'active',
          remarks: '',
          driverName: userData['first_name'] + ' ' + userData['last_name'],
          driverProfileImg: _currentDriver!.driverProfileImg,
          gender: _currentDriver!.gender,
          iqama: _currentDriver!.iqama,
          mobile: userData['phone'] ?? _currentDriver!.mobile,
          city: _currentDriver!.city,
          nationality: _currentDriver!.nationality,
          dob: _currentDriver!.dob,
          iqamaDocument: _currentDriver!.iqamaDocument,
          iqamaExpiry: _currentDriver!.iqamaExpiry,
          passportDocument: _currentDriver!.passportDocument,
          passportExpiry: _currentDriver!.passportExpiry,
          licenseDocument: _currentDriver!.licenseDocument,
          licenseExpiry: _currentDriver!.licenseExpiry,
          visaDocument: _currentDriver!.visaDocument,
          visaExpiry: _currentDriver!.visaExpiry,
          medicalDocument: _currentDriver!.medicalDocument,
          medicalExpiry: _currentDriver!.medicalExpiry,
          insurancePaidBy: _currentDriver!.insurancePaidBy,
          accommodationPaidBy: _currentDriver!.accommodationPaidBy,
          phoneBillPaidBy: _currentDriver!.phoneBillPaidBy,
          createdAt: _currentDriver!.createdAt,
        );
        await _saveUserData(updatedProfile);
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
    return false;
  }

  // Update driver profile (placeholder - would need proper endpoint)
  Future<AuthResult> updateProfile(Map<String, dynamic> updateData) async {
    if (!_isAuthenticated || _currentDriver == null) {
      return AuthResult.error('Not authenticated');
    }

    try {
      // For now, just update local data since we don't have update endpoint
      _mobileService.lightHaptic();
      return AuthResult.success(_currentDriver!);
    } catch (e) {
      _mobileService.heavyHaptic();
      debugPrint('Update profile error: $e');
      return AuthResult.error('Update failed: ${e.toString()}');
    }
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    if (!_isAuthenticated || _currentDriver == null) return false;

    // For driver mobile app, we rely on stored authentication state
    // and token validity rather than calling the admin auth endpoint
    try {
      // Check if we have valid tokens
      return await _apiService.hasValidTokens();
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }
}

// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final DriverProfile? driver;
  final String? error;

  AuthResult.success(this.driver) : isSuccess = true, error = null;
  AuthResult.error(this.error) : isSuccess = false, driver = null;
}

// Extension to add toJson method to DriverProfile if not exists
extension DriverProfileExtension on DriverProfile {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle': {
        'id': vehicle.id,
        'vehicle_name': vehicle.vehicleName,
        'vehicle_number': vehicle.vehicleNumber,
        'vehicle_type': vehicle.vehicleType,
      },
      'company': {
        'id': company.id,
        'company_name': company.companyName,
      },
      'status': status,
      'remarks': remarks,
      'driver_name': driverName,
      'driver_profile_img': driverProfileImg,
      'gender': gender,
      'iqama': iqama,
      'mobile': mobile,
      'city': city,
      'nationality': nationality,
      'dob': dob,
      'iqama_document': iqamaDocument,
      'iqama_expiry': iqamaExpiry,
      'passport_document': passportDocument,
      'passport_expiry': passportExpiry,
      'license_document': licenseDocument,
      'license_expiry': licenseExpiry,
      'visa_document': visaDocument,
      'visa_expiry': visaExpiry,
      'medical_document': medicalDocument,
      'medical_expiry': medicalExpiry,
      'insurance_paid_by': insurancePaidBy,
      'accommodation_paid_by': accommodationPaidBy,
      'phone_bill_paid_by': phoneBillPaidBy,
      'created_at': createdAt,
    };
  }
}
