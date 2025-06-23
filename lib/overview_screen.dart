import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Import the profile screen
import 'sales_cash_report_screen.dart';
import 'drive_status_screen.dart';

// Overview Screen Widget (Moved from main.dart)
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu), // Burger menu icon
          onPressed: () {
            // Handle menu button press
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu button tapped!')),
            );
          },
        ),
        title: const Text('Overview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200], // Placeholder background
                  backgroundImage: const NetworkImage(
                    'https://placehold.co/100x100/e0e0e0/000000?text=Avatar', // Placeholder avatar image
                    // Replace with a real avatar image URL if available
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lucas Bennett',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Driver ID : 123456',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Earnings Section
            const Text(
              'Earnings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OverviewCard(
                    title: 'Total Earnings',
                    value: '\$ 1,250',
                    valueColor: Colors.black, // Specific color from image
                    titleStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    valueStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OverviewCard(
                    title: 'Trips',
                    subTitle: 'Completed',
                    value: '75',
                    valueColor: Colors.black, // Specific color from image
                    titleStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    valueStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Attendance Report Section
            const Text(
              'Attendance Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OverviewCard(
                    title: 'Days Worked',
                    value: '20',
                    valueColor: Colors.black, // Specific color from image
                    titleStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    valueStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OverviewCard(
                    title: 'Active Days',
                    value: '15',
                    valueColor: Colors.black, // Specific color from image
                    titleStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    valueStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing for the single card
            OverviewCard(
              title: 'Inactive Days',
              value: '5',
              valueColor: Colors.black, // Specific color from image
              titleStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
              valueStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
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
        currentIndex: 0, // Assuming 'Account' is the current selected tab
        selectedItemColor: Colors.redAccent, // Color for selected icon/label
        unselectedItemColor: Colors.grey, // Color for unselected icons/labels
        onTap: (index) {
          // Handle navigation here
          switch (index) {
            case 0:
              // Navigate to Home or stay on OverviewScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapped on Home!')),
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
              // Navigate to Add screen (not implemented
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
}

// Overview Card Widget (Moved from main.dart)
class OverviewCard extends StatelessWidget {
  final String title;
  final String? subTitle; // Optional for "Trips Completed"
  final String value;
  final Color valueColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  const OverviewCard({
    super.key,
    required this.title,
    this.subTitle,
    required this.value,
    required this.valueColor,
    this.titleStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE8), // Card background color from image
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle ?? TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          if (subTitle != null) ...[
            Text(
              subTitle!,
              style: titleStyle ?? TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 5),
          Text(
            value,
            style: valueStyle ?? TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}

