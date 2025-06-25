import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _darkModeEnabled = false; // Assuming light mode by default

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
          'Settings',
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
            // General Settings Section
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            SettingCard(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
                    );
                  },
                  activeColor: Colors.redAccent, // Consistent with login button
                ),
                ListTile(
                  leading: Icon(Icons.language, color: Colors.grey[700]),
                  title: const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language set to $newValue')),
                      );
                    },
                    items: <String>['English', 'Spanish', 'French', 'Hindi']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SwitchListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: _darkModeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dark Mode ${value ? 'enabled' : 'disabled'}')),
                    );
                    // In a real app, you'd update your MaterialApp's theme here
                  },
                  activeColor: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Account & Support Section
            Text(
              'Account & Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            SettingCard(
              children: [
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: Colors.grey[700]),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy tapped!')),
                    );
                    // Navigate to Privacy Policy screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support tapped!')),
                    );
                    // Navigate to Help & Support screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[700]),
                  title: const Text(
                    'About App',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('About App tapped!')),
                    );
                    // Show app version, build info etc.
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout tapped!')),
                    );
                    // Implement logout logic and navigate to LoginScreen
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),

            // App Version
            Align(
              alignment: Alignment.center,
              child: Text(
                'App Version: 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Reusable card container for settings items
class SettingCard extends StatelessWidget {
  final List<Widget> children;

  const SettingCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE8), // Matches card background from other screens
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
