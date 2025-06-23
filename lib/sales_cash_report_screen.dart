import 'package:flutter/material.dart';
import 'overview_screen.dart'; // Import the OverviewScreen
import 'profile_screen.dart'; // Import the ProfileScreen'
import 'drive_status_screen.dart';

class SalesCashReportScreen extends StatelessWidget {
  const SalesCashReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        title: const Text(
          'Sales Cash Report',
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
            const Text(
              'Sales Cash',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildReportRow('Cash Sales', '₹120.00'),
            _buildReportRow('Cash Tips', '₹10.00'),
            _buildReportRow('Total Cash', '₹130.00', isBold: true),
            const SizedBox(height: 30),
            const Text(
              'Cash Payments',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildReportRow('Cash Payments', '₹120.00'),
            _buildReportRow('Cash Tips', '₹10.00'),
            _buildReportRow('Total Cash', '₹130.00', isBold: true),
            const SizedBox(height: 30),
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildReportRow('Total', '₹260.00', isBold: true),
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
        currentIndex: 1, // Assuming 'Earnings' (index 1) is selected
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapped on Earnings! (Navigation not implemented)')),
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

              Navigator.pushReplacement( // Use pushReplacement to prevent going back
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
          // In a real application, you would navigate to different screens here.
          // Example:
          // if (index == 0) {
          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          // } else if (index == 1) {
          //   // Already on Earnings/Sales Cash Report screen
          // }
          // ... and so on for other tabs
        },
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}