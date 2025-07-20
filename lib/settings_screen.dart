import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'services/mobile_features_service.dart';
import 'services/translation_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'widgets/connectivity_status_widget.dart';
import 'alarm_management_screen.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final MobileFeaturesService _mobileService = MobileFeaturesService();
  final TranslationService _translationService = TranslationService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _offlineModeEnabled = false;
  bool _isBiometricAvailable = false;
  Map<String, dynamic> _deviceInfo = {};
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    await _translationService.initialize();
    await _notificationService.initialize();

    final biometricAvailable = await _mobileService.isBiometricAvailable();
    final biometricEnabled = await _mobileService.isBiometricEnabled();
    final offlineEnabled = await _mobileService.isOfflineModeEnabled();
    final notificationsEnabled = await _mobileService.isNotificationsEnabled();
    final deviceInfo = await _mobileService.getDeviceInfo();
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _selectedLanguage = _translationService.currentLanguage;
      _notificationsEnabled = notificationsEnabled;
      _isBiometricAvailable = biometricAvailable;
      _biometricEnabled = biometricEnabled;
      _offlineModeEnabled = offlineEnabled;
      _deviceInfo = deviceInfo;
      _packageInfo = packageInfo;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final success = await _translationService.setLanguage(languageCode);
    if (success && mounted) {
      setState(() {
        _selectedLanguage = languageCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'language'.tr} ${'changed_to'.tr} ${TranslationService.supportedLanguages[languageCode]!}'),
        ),
      );

      // Restart app to apply language changes
      _showRestartDialog();
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('restart_required'.tr),
        content: Text('restart_app_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('later'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you'd restart the app here
              Navigator.of(context).pop();
              _restartApp();
            },
            child: Text('restart_now'.tr),
          ),
        ],
      ),
    );
  }

  void _restartApp() {
    // Navigate to login screen to simulate restart
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Future<bool?> _showLogoutConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_logout'.tr),
        content: Text('logout_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityStatusWidget(
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: Text(
          'settings'.tr,
          style: const TextStyle(
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
              'general_settings'.tr,
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
                  title: Text(
                    'push_notifications'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('notification_subtitle'.tr),
                  value: _notificationsEnabled,
                  onChanged: (bool value) async {
                    _mobileService.selectionHaptic();
                    final messenger = ScaffoldMessenger.of(context);

                    // Update notification service
                    await _notificationService.setNotificationsEnabled(value);
                    await _mobileService.setNotificationsEnabled(value);

                    if (mounted) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    }

                    // Show test notification if enabled
                    if (value) {
                      await _notificationService.showNotification(
                        id: 999,
                        title: 'Notifications Enabled',
                        body: 'You will now receive notifications from the app',
                      );
                    }

                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '${'push_notifications'.tr} ${value ? 'enabled'.tr : 'disabled'.tr}',
                          ),
                          backgroundColor: value ? Colors.green : Colors.orange,
                        ),
                      );
                    }
                  },
                  activeColor: Colors.redAccent, // Consistent with login button
                  secondary: const Icon(Icons.notifications),
                ),
                ListTile(
                  leading: Icon(Icons.language, color: Colors.grey[700]),
                  title: Text(
                    'language'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeLanguage(newValue);
                      }
                    },
                    items: TranslationService.supportedLanguages.entries
                        .map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'dark_mode'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: _darkModeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${'dark_mode'.tr} ${value ? 'enabled'.tr : 'disabled'.tr}',
                        ),
                      ),
                    );
                    // In a real app, you'd update your MaterialApp's theme here
                  },
                  activeColor: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Mobile Features Section
            Text(
              'mobile_features'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            Card(
              child: Column(
                children: [
                  if (_isBiometricAvailable)
                    SwitchListTile(
                      title: Text(
                        'biometric_auth'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('biometric_subtitle'.tr),
                      value: _biometricEnabled,
                      onChanged: (bool value) async {
                        _mobileService.selectionHaptic();
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await _mobileService.setBiometricEnabled(value);
                        if (success && mounted) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${'biometric_auth'.tr} ${value ? 'enabled'.tr : 'disabled'.tr}',
                              ),
                            ),
                          );
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      secondary: const Icon(Icons.fingerprint),
                    ),
                  SwitchListTile(
                    title: Text(
                      'offline_mode'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('offline_subtitle'.tr),
                    value: _offlineModeEnabled,
                    onChanged: (bool value) async {
                      _mobileService.selectionHaptic();
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await _mobileService.setOfflineModeEnabled(value);
                      if (success && mounted) {
                        setState(() {
                          _offlineModeEnabled = value;
                        });
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '${'offline_mode'.tr} ${value ? 'enabled'.tr : 'disabled'.tr}',
                            ),
                          ),
                        );
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: const Icon(Icons.offline_bolt),
                  ),

                  const Divider(),

                  // Intelligent Alarms
                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.red),
                    title: Text(
                      'intelligent_alarms'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Location monitoring and shift reminders'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _mobileService.selectionHaptic();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlarmManagementScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      'device_info'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${_deviceInfo['manufacturer'] ?? 'Unknown'} ${_deviceInfo['model'] ?? 'Device'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _mobileService.selectionHaptic();
                      _showDeviceInfoDialog();
                    },
                  ),
                  const ConnectivityIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Account & Support Section
            Text(
              'account_support'.tr,
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
                  title: Text(
                    'privacy_policy'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    _showPrivacyPolicy();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                  title: Text(
                    'help_support'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    _showHelpSupport();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[700]),
                  title: Text(
                    'about_app'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    _showAboutApp();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'logout'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  onTap: _handleLogout,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // App Version
            Align(
              alignment: Alignment.center,
              child: Text(
                '${'app_version'.tr}: ${_packageInfo?.version ?? '1.0.0'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  void _showDeviceInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('device_info'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Platform', _deviceInfo['platform'] ?? 'Unknown'),
              _buildInfoRow('Manufacturer', _deviceInfo['manufacturer'] ?? 'Unknown'),
              _buildInfoRow('Model', _deviceInfo['model'] ?? 'Unknown'),
              _buildInfoRow('Brand', _deviceInfo['brand'] ?? 'Unknown'),
              _buildInfoRow('Android Version', _deviceInfo['androidVersion'] ?? 'Unknown'),
              _buildInfoRow('App Version', _packageInfo?.version ?? 'Unknown'),
              _buildInfoRow('Build Number', _packageInfo?.buildNumber ?? 'Unknown'),
              _buildInfoRow('Physical Device', _deviceInfo['isPhysicalDevice']?.toString() ?? 'Unknown'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy_policy'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'privacy_policy_content'.tr,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'data_collection_title'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('data_collection_content'.tr),
              const SizedBox(height: 16),
              Text(
                'data_usage_title'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('data_usage_content'.tr),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('help_support'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text('contact_phone'.tr),
                subtitle: const Text('+966 123 456 789'),
                onTap: () {
                  // Launch phone dialer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('calling_support'.tr)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text('contact_email'.tr),
                subtitle: const Text('support@driverapp.com'),
                onTap: () {
                  // Launch email client
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('opening_email'.tr)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text('live_chat'.tr),
                subtitle: Text('chat_available'.tr),
                onTap: () {
                  // Open live chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('opening_chat'.tr)),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('about_app'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'app_title'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${'app_version'.tr}: ${_packageInfo?.version ?? '1.0.0'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build: ${_packageInfo?.buildNumber ?? '1'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'app_description'.tr,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'developed_by'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2024 Driver Self-Service App',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
