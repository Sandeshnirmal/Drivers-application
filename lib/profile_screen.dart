import 'package:flutter/material.dart';
import 'overview_screen.dart'; // Import the OverviewScreen
import 'sales_cash_report_screen.dart'; // Import the SalesCashReportScreen'
import 'drive_status_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Handle profile icon tap
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile icon tapped!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Profile Image and Name Section
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: const NetworkImage(
                'https://placehold.co/100x100/e0e0e0/000000?text=Profile', // Placeholder avatar
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lucas Bennett',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Driver',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Joined 2021',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120, // Specific width for the button from image
              child: ElevatedButton(
                onPressed: () {
                  // Handle Edit button tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit button tapped!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0EAE8), // Matches card background
                  foregroundColor: Colors.black, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0, // No shadow
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Personal Information Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ProfileInfoTile(
              icon: Icons.person_outline,
              label: 'Name',
              value: 'Lucas Bennett',
            ),
            ProfileInfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'lucas.bennett@email.com',
            ),
            ProfileInfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: '(555) 987-6543',
            ),
            const SizedBox(height: 30),

            // Vehicle Information Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ProfileInfoTile(
              icon: Icons.directions_car_outlined,
              label: 'Vehicle Make',
              value: 'Honda',
            ),
            ProfileInfoTile(
              icon: Icons.car_rental_outlined,
              label: 'Vehicle Model',
              value: 'Civic',
            ),
            ProfileInfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Vehicle Year',
              value: '2018',
            ),
            ProfileInfoTile(
              icon: Icons.numbers_outlined,
              label: 'License Plate',
              value: 'XYZ-5678',
            ),
            const SizedBox(height: 30),

            // Documents Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            DocumentUploadTile(
              label: 'Upload Driver\'s License',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload Driver\'s License tapped!')),
                );
              },
            ),
            DocumentUploadTile(
              label: 'Upload Vehicle Registration',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload Vehicle Registration tapped!')),
                );
              },
            ),
            const SizedBox(height: 30),

            // Sales Order Reports Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sales Order Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ProfileInfoTile(
              icon: Icons.insert_link, // Link icon
              label: 'Access Reports',
              value: '', // No value, just an action
              showArrow: true, // Indicate it's clickable
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Access Reports tapped!')),
                );
              },
            ),
            const SizedBox(height: 30),

            // Warning Information Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Warning Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ProfileInfoTile(
              icon: Icons.warning_amber_outlined,
              label: 'Warning Type',
              value: 'Parking',
            ),
            ProfileInfoTile(
              icon: Icons.calendar_month_outlined,
              label: 'Warning Date',
              value: '2023-07-20',
            ),
            const SizedBox(height: 40),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save Changes tapped!')),
                  );
                  // Implement save changes logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Red color from image
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money), // Represents earnings
            label: 'Earnings',
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline), // Represents attendance/check-in
            label: 'Attendance',
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person), // Represents account
            label: 'Account',
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
        ],
        currentIndex: 3, // Assuming 'Account' is the current selected tab
        selectedItemColor: Colors.redAccent, // Color for selected icon/label
        unselectedItemColor: Colors.grey, // Color for unselected icons/labels
        onTap: (index) {
          // Handle navigation here
          switch (index) {
            case 0:
            // Navigate to Home or stay on OverviewScreen
              Navigator
                  .pushReplacement( // Use pushReplacement to prevent going back
                context,
                MaterialPageRoute(builder: (context) => const OverviewScreen()),
              );
              break;
            case 1:
            // Navigate to Earnings screen (not implemented)
              Navigator
                  .pushReplacement( // Use pushReplacement to prevent going back
                    context,
                    MaterialPageRoute(builder: (context) => const SalesCashReportScreen()),
              );
              break;

            case 2:
            // Navigate to Account/Profile screen
              Navigator.pushReplacement( // Use pushReplacement to prevent going back
                context,
                MaterialPageRoute(builder: (context) => const DriveStatusScreen()),
              );
              break;
            case 3:
            // Navigate to Add screen (not implemented)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(
                    'Tapped on Add! (Navigation not implemented)')),
              );
              break;
          }
        })
        );
      }
    }

// Widget for Profile Information Tiles (Name, Email, Phone, Vehicle Info, Warnings)
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showArrow; // For actionable tiles like "Access Reports"
  final VoidCallback? onTap; // For making the tile tappable

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE8), // Card background color from image
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell( // Use InkWell for tap effect if onTap is provided
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Widget for Document Upload Tiles
class DocumentUploadTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE8), // Card background color from image
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.upload_file_outlined, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}