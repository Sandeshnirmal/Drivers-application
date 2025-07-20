import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'widgets/enhanced_bottom_navigation.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/translation_service.dart';
import 'models/trip_model.dart';


// Overview Screen Widget (Moved from main.dart)
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // Dashboard data
  TripStats? _tripStats;
  List<Trip> _recentTrips = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final driverId = _authService.currentDriver!.id;

      // Load trip statistics and recent trips
      final statsResponse = await _apiService.getDriverTripStats(driverId);
      final tripsResponse = await _apiService.getRecentTrips(driverId);

      if (statsResponse.isSuccess && tripsResponse.isSuccess) {
        setState(() {
          _tripStats = statsResponse.data;
          _recentTrips = tripsResponse.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = statsResponse.error ?? tripsResponse.error ?? 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading dashboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.blue),
            SizedBox(width: 8),
            Text('Notifications'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text('Attendance Reminder'),
                subtitle: const Text('Don\'t forget to check in!'),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _notificationService.showAttendanceReminder();
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Test notification sent!')),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.green),
                title: const Text('Trip Update'),
                subtitle: const Text('New trip assigned'),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _notificationService.showTripUpdate('New trip assigned to you!');
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Trip notification sent!')),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: const Text('Earnings Update'),
                subtitle: const Text('Daily earnings summary'),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _notificationService.showEarningsUpdate('Your daily earnings: ₹1,250');
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Earnings notification sent!')),
                      );
                    }
                  },
                ),
              ),
              const Divider(),
              const Text(
                'Tap the send button to test notifications',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationsDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshDashboard,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              // Welcome Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _authService.currentDriver?.driverName ?? 'Driver Name',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Driver ID: ${_authService.currentDriver?.id ?? 'N/A'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.play_circle_outline,
                      label: 'Start Trip',
                      color: Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Start Trip feature coming soon!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.location_on_outlined,
                      label: 'Check In',
                      color: colorScheme.primary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check In feature coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'View Reports',
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reports feature coming soon!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.help_outline,
                      label: 'Support',
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support feature coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Trip Performance
              Text(
                'Trip Performance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.monetization_on,
                              title: 'Earnings',
                              value: '₹${_tripStats?.totalEarnings.toStringAsFixed(0) ?? '0'}',
                              subtitle: 'Total',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_shipping,
                              title: 'Trips',
                              value: '${_tripStats?.completedTrips ?? 0}',
                              subtitle: 'Completed',
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.access_time,
                              title: 'Distance',
                              value: '${_tripStats?.totalDistance.toStringAsFixed(1) ?? '0.0'} km',
                              subtitle: 'Total',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.star,
                              title: 'Tips',
                              value: '₹${_tripStats?.totalTips.toStringAsFixed(0) ?? '0'}',
                              subtitle: 'Earned',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment Summary
              Text(
                'Payment Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: Icons.calendar_today,
                        label: 'Cash Payments',
                        value: '${_tripStats?.cashTrips ?? 0} trips',
                        progress: _tripStats != null && _tripStats!.totalTrips > 0
                            ? _tripStats!.cashTrips / _tripStats!.totalTrips
                            : 0.0,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        icon: Icons.trending_up,
                        label: 'Cash Earnings',
                        value: '₹${_tripStats?.cashEarnings.toStringAsFixed(0) ?? '0'}',
                        progress: _tripStats != null && _tripStats!.totalEarnings > 0
                            ? _tripStats!.cashEarnings / _tripStats!.totalEarnings
                            : 0.0,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        icon: Icons.route,
                        label: 'Digital Payments',
                        value: '${_tripStats?.digitalTrips ?? 0} trips',
                        progress: _tripStats != null && _tripStats!.totalTrips > 0
                            ? _tripStats!.digitalTrips / _tripStats!.totalTrips
                            : 0.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const EnhancedBottomNavigation(currentIndex: 0),
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

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget for performance metrics
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Summary Row Widget with progress indicator
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
