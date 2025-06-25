import 'package:flutter/material.dart';
import 'overview_screen.dart'; // Import the OverviewScreen
import 'sales_cash_report_screen.dart'; // Import the SalesCashReportScreen'
import 'profile_screen.dart'; // Import the profile screen
import 'settings_screen.dart'; // Import SettingsScreen (adjust path if needed)



class DriveStatusScreen extends StatefulWidget {
  const DriveStatusScreen({super.key});

  @override
  State<DriveStatusScreen> createState() => _DriveStatusScreenState();
}

class _DriveStatusScreenState extends State<DriveStatusScreen> {
  bool _isActive = true; // State for the "Active" switch
  // For demonstration, these values would typically come from a state management solution
  final String _onlineTime = '00:00:00'; // Placeholder for online time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator
                .pushReplacement( // Use pushReplacement to prevent going back
              context,
              MaterialPageRoute(builder: (context) => const OverviewScreen()),
            );
          },
        ),
        title: const Text(
          'Drive Status',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Added Settings Icon to AppBar actions
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Navigate to the SettingsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // You can add other action buttons here if needed
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Active Status Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Go online to start receiving orders',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Active status: $value')),
                    );
                  },
                  activeColor: Colors.redAccent, // Color when switch is ON
                  inactiveTrackColor: Colors.grey[300], // Color when switch is OFF
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Online For Section
            _buildInfoRow(
              label: 'Online for',
              value: _onlineTime,
              trailingIcon: Icons.location_on_outlined,
              valueStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              onTrailingIconTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location icon tapped for Online for!')),
                );
              },
            ),
            const SizedBox(height: 15),

            // Live Image Preview
            _buildImagePreviewRow(
              'Live Image Preview',
              'https://placehold.co/100x100/e0e0e0/000000?text=Profile', // Placeholder avatar
              Icons.camera_alt_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera icon tapped for Live Image Preview!')),
                );
              },
            ),
            const SizedBox(height: 15),

            // Live Location Preview
            _buildImagePreviewRow(
              'Live Location Preview',
              'https://placehold.co/100x100/e0e0e0/000000?text=Map', // Placeholder map
              Icons.location_on_outlined,
              isMap: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location icon tapped for Live Location Preview!')),
                );
              },
            ),
            const SizedBox(height: 30),

            // Trip Notifications Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trip Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildNotificationSettingRow('1 Hour Before'),
            _buildNotificationSettingRow('30 Minutes Before'),
            _buildNotificationSettingRow('10 Minutes Before'),
            _buildNotificationSettingRow('Home Location Alert (During Work Hours)'),
            const SizedBox(height: 30),

            // GPS Alerts Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'GPS Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoRow(
              label: 'GPS Location-Based Attendance',
              trailingIcon: Icons.location_on_outlined,
              onTrailingIconTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location icon tapped for GPS Attendance!')),
                );
              },
            ),
            _buildNotificationSettingRow('15 Minutes Before'),
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
        currentIndex: 2, // Assuming Home is selected or adjust as needed
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(
                    'Attendance ')),
              );
              break;
            case 3:
            // Navigate to Add screen (not implemented)

              Navigator.pushReplacement( // Use pushReplacement to prevent going back
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  // Helper widget for standard info rows
  Widget _buildInfoRow({
    required String label,
    String? value,
    IconData? trailingIcon,
    VoidCallback? onTrailingIconTap,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ?? const TextStyle(fontSize: 18),
          ),
          if (value != null || trailingIcon != null)
            Row(
              children: [
                if (value != null)
                  Text(
                    value,
                    style: valueStyle ?? const TextStyle(fontSize: 18),
                  ),
                if (value != null && trailingIcon != null)
                  const SizedBox(width: 10),
                if (trailingIcon != null)
                  GestureDetector(
                    onTap: onTrailingIconTap,
                    child: Icon(trailingIcon, color: Colors.black54),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // Helper widget for notification settings rows
  Widget _buildNotificationSettingRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          const Icon(Icons.notifications_none, color: Colors.black54),
        ],
      ),
    );
  }

  // Helper widget for image/map preview rows
  Widget _buildImagePreviewRow(
      String label, String imageUrl, IconData trailingIcon, {bool isMap = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(imageUrl),
            // Conditionally show a child for map to indicate it's a map
            child: isMap ? Icon(Icons.map, size: 24, color: Colors.grey[600]) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(trailingIcon, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}