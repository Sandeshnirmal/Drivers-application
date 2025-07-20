import 'package:flutter/material.dart';
import 'models/driver_profile_model.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/translation_service.dart';

class EditProfileScreen extends StatefulWidget {
  final DriverProfile? driverProfile;

  const EditProfileScreen({super.key, this.driverProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TranslationService _translationService = TranslationService();

  // Controllers for text fields
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _iqamaController;
  late final TextEditingController _cityController;
  late final TextEditingController _nationalityController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile data
    _nameController = TextEditingController(
      text: widget.driverProfile?.driverName ?? ''
    );
    _phoneController = TextEditingController(
      text: widget.driverProfile?.mobile ?? ''
    );
    _iqamaController = TextEditingController(
      text: widget.driverProfile?.iqama ?? ''
    );
    _cityController = TextEditingController(
      text: widget.driverProfile?.city ?? ''
    );
    _nationalityController = TextEditingController(
      text: widget.driverProfile?.nationality ?? ''
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _iqamaController.dispose();
    _cityController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to update profile')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final driverId = _authService.currentDriver!.id;
      final updateData = {
        'driver_name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'iqama': _iqamaController.text.trim(),
        'city': _cityController.text.trim(),
        'nationality': _nationalityController.text.trim(),
      };

      final response = await _apiService.updateDriverProfile(driverId, updateData);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back without saving
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Image (Not editable here, but displayed for context)
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: const NetworkImage(
                  'https://placehold.co/100x100/e0e0e0/000000?text=Profile', // Placeholder avatar
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Personal Information Fields
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _nameController,
              label: _translationService.translate('name'),
              icon: Icons.person_outline
            ),
            _buildTextField(
              controller: _phoneController,
              label: _translationService.translate('phone_number'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone
            ),
            _buildTextField(
              controller: _iqamaController,
              label: _translationService.translate('iqama'),
              icon: Icons.badge_outlined
            ),
            _buildTextField(
              controller: _cityController,
              label: _translationService.translate('city'),
              icon: Icons.location_city_outlined
            ),
            _buildTextField(
              controller: _nationalityController,
              label: _translationService.translate('nationality'),
              icon: Icons.flag_outlined
            ),
            const SizedBox(height: 40),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Red color from image
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0EAE8), // Matches card background for consistency
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
        ),
      ),
    );
  }
}
