import 'package:flutter/material.dart';

import 'overview_screen.dart';
import 'settings_screen.dart';
import 'deductions_screen.dart';
import 'edit_profile_screen.dart';
import 'models/driver_profile_model.dart';
import 'widgets/enhanced_bottom_navigation.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  DriverProfile? _driverProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    // Check if user is authenticated
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      setState(() {
        _errorMessage = 'Please login to view your profile';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get the current authenticated driver's ID
      final driverId = _authService.currentDriver!.id;
      final response = await _apiService.getDriverProfile(driverId);

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          setState(() {
            _driverProfile = DriverProfile.fromJson(response.data!);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response.error ?? 'Failed to load profile';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _refreshProfile() async {
    await _fetchDriverProfile();
  }



  // Show profile details in a dialog
  void _showProfileDetails() {
    if (_driverProfile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_driverProfile!.driverName} - Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Driver ID', _driverProfile!.id.toString()),
              _buildDetailRow('Name', _driverProfile!.driverName),
              _buildDetailRow('Mobile', _driverProfile!.mobile),
              _buildDetailRow('Iqama', _driverProfile!.iqama),
              _buildDetailRow('Gender', _driverProfile!.gender),
              _buildDetailRow('Nationality', _driverProfile!.nationality),
              _buildDetailRow('City', _driverProfile!.city),
              _buildDetailRow('Status', _driverProfile!.status),
              if (_driverProfile!.remarks.isNotEmpty)
                _buildDetailRow('Remarks', _driverProfile!.remarks),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // Helper method to build info cards
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build documents grid
  Widget _buildDocumentsGrid() {
    final documents = [
      {
        'label': 'Iqama Document',
        'expiry': _driverProfile?.iqamaExpiry ?? 'N/A',
        'isUploaded': _driverProfile?.iqamaDocument != null,
        'icon': Icons.credit_card,
      },
      {
        'label': 'Passport Document',
        'expiry': _driverProfile?.passportExpiry ?? 'N/A',
        'isUploaded': _driverProfile?.passportDocument != null,
        'icon': Icons.book,
      },
      {
        'label': 'License Document',
        'expiry': _driverProfile?.licenseExpiry ?? 'N/A',
        'isUploaded': _driverProfile?.licenseDocument != null,
        'icon': Icons.drive_eta,
      },
      {
        'label': 'Medical Document',
        'expiry': _driverProfile?.medicalExpiry ?? 'N/A',
        'isUploaded': _driverProfile?.medicalDocument != null,
        'icon': Icons.medical_services,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: documents.map((doc) => _buildDocumentTile(
          doc['label'] as String,
          doc['expiry'] as String,
          doc['isUploaded'] as bool,
          doc['icon'] as IconData,
        )).toList(),
      ),
    );
  }

  // Helper method to build document tiles
  Widget _buildDocumentTile(String label, String expiry, bool isUploaded, IconData icon) {
    final isExpired = _isExpired(expiry);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isUploaded
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires: $expiry',
                  style: TextStyle(
                    fontSize: 14,
                    color: isExpired ? Colors.red.shade600 : Colors.grey.shade600,
                    fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
              color: isUploaded
                  ? Colors.green.shade600
                  : Colors.grey.shade600,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to check if document is expired
  bool _isExpired(String expiryDate) {
    if (expiryDate == 'N/A') return false;
    try {
      final DateTime now = DateTime.now();
      final DateTime expiry = DateTime.parse(expiryDate);
      return expiry.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  // Helper method to build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Reports Access Button
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Access Reports feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Access Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Deductions Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade500, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeductionsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.money_off, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'View Deductions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Modern light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OverviewScreen()),
            );
          },
        ),
        title: Text(
          'profile'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
            ),
            onPressed: _driverProfile != null ? _showProfileDetails : null,
            tooltip: 'View Details',
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.refresh, color: Colors.green.shade600, size: 20),
            ),
            onPressed: _refreshProfile,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings, color: Colors.black54, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: Colors.blue.shade600,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _refreshProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Enhanced Profile Header Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.shade50,
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              // Enhanced Profile Avatar
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: _driverProfile?.driverProfileImg != null &&
                                              _driverProfile!.driverProfileImg!.isNotEmpty
                                          ? NetworkImage(_driverProfile!.driverProfileImg!)
                                          : null,
                                      child: _driverProfile?.driverProfileImg == null ||
                                              _driverProfile!.driverProfileImg!.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade400,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Enhanced Name and Info
                              Text(
                                _driverProfile?.driverName ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _driverProfile?.vehicle.vehicleType ?? 'Professional Driver',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Member since 2021',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Enhanced Edit Button
                              Container(
                                width: 140,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.blue.shade700,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          driverProfile: _driverProfile,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _refreshProfile();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Enhanced Information Sections
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Personal Information Section
                              _buildSectionHeader('Personal Information', Icons.person),
                              const SizedBox(height: 16),
                              _buildInfoCard([
                                _buildInfoRow(Icons.person_outline, 'Full Name',
                                    _driverProfile?.driverName ?? 'N/A'),
                                _buildInfoRow(Icons.phone_outlined, 'Phone Number',
                                    _driverProfile?.mobile ?? 'N/A'),
                                _buildInfoRow(Icons.location_city_outlined, 'City',
                                    _driverProfile?.city ?? 'N/A'),
                                _buildInfoRow(Icons.flag_outlined, 'Nationality',
                                    _driverProfile?.nationality ?? 'N/A'),
                                _buildInfoRow(Icons.cake_outlined, 'Date of Birth',
                                    _driverProfile?.dob ?? 'N/A'),
                                _buildInfoRow(Icons.credit_card_outlined, 'Iqama ID',
                                    _driverProfile?.iqama ?? 'N/A'),
                              ]),
                              const SizedBox(height: 24),
                              // Vehicle Information Section
                              _buildSectionHeader('Vehicle Information', Icons.directions_car),
                              const SizedBox(height: 16),
                              _buildInfoCard([
                                _buildInfoRow(Icons.directions_car_outlined, 'Vehicle Name',
                                    _driverProfile?.vehicle.vehicleName ?? 'N/A'),
                                _buildInfoRow(Icons.format_list_numbered, 'Vehicle Number',
                                    _driverProfile?.vehicle.vehicleNumber ?? 'N/A'),
                                _buildInfoRow(Icons.category_outlined, 'Vehicle Type',
                                    _driverProfile?.vehicle.vehicleType ?? 'N/A'),
                              ]),
                              const SizedBox(height: 24),
                              // Documents Section
                              _buildSectionHeader('Documents', Icons.description),
                              const SizedBox(height: 16),
                              _buildDocumentsGrid(),
                              // Action Buttons Section
                              _buildActionButtons(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const EnhancedBottomNavigation(currentIndex: 3),
    );
  }
}