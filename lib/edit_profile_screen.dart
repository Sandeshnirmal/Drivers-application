import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  // You might want to pass initial data to this screen from the ProfileScreen
  // For simplicity, we'll use static initial values for now.
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController(text: 'Lucas Bennett');
  final TextEditingController _emailController = TextEditingController(text: 'lucas.bennett@email.com');
  final TextEditingController _phoneController = TextEditingController(text: '(555) 987-6543');
  final TextEditingController _vehicleMakeController = TextEditingController(text: 'Honda');
  final TextEditingController _vehicleModelController = TextEditingController(text: 'Civic');
  final TextEditingController _vehicleYearController = TextEditingController(text: '2018');
  final TextEditingController _licensePlateController = TextEditingController(text: 'XYZ-5678');

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // In a real application, you would send this data to a backend or save it locally.
    print('Saving Changes:');
    print('Name: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Vehicle Make: ${_vehicleMakeController.text}');
    print('Vehicle Model: ${_vehicleModelController.text}');
    print('Vehicle Year: ${_vehicleYearController.text}');
    print('License Plate: ${_licensePlateController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    // Optionally, navigate back to the profile screen
    Navigator.pop(context);
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
            _buildTextField(controller: _nameController, label: 'Name', icon: Icons.person_outline),
            _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 30),

            // Vehicle Information Fields
            Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(controller: _vehicleMakeController, label: 'Vehicle Make', icon: Icons.directions_car_outlined),
            _buildTextField(controller: _vehicleModelController, label: 'Vehicle Model', icon: Icons.car_rental_outlined),
            _buildTextField(controller: _vehicleYearController, label: 'Vehicle Year', icon: Icons.calendar_today_outlined, keyboardType: TextInputType.number),
            _buildTextField(controller: _licensePlateController, label: 'License Plate', icon: Icons.numbers_outlined),
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
