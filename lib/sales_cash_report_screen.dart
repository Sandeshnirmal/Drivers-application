import 'package:flutter/material.dart';
import 'overview_screen.dart';
import 'settings_screen.dart';
import 'widgets/enhanced_bottom_navigation.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/translation_service.dart';
import 'models/trip_model.dart';

// Enhanced Earnings Screen with API Integration

class SalesCashReportScreen extends StatefulWidget {
  const SalesCashReportScreen({super.key});

  @override
  State<SalesCashReportScreen> createState() => _SalesCashReportScreenState();
}

class _SalesCashReportScreenState extends State<SalesCashReportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Trip data
  List<Trip> _trips = [];
  TripStats? _tripStats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTripsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTripsData() async {
    if (!_authService.isAuthenticated || _authService.currentDriver == null) {
      if (mounted) {
        setState(() {
          _error = 'Not authenticated';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final driverId = _authService.currentDriver!.id;

      // Load recent trips and statistics
      final tripsResponse = await _apiService.getRecentTrips(driverId);
      final statsResponse = await _apiService.getDriverTripStats(driverId);

      if (tripsResponse.isSuccess && statsResponse.isSuccess) {
        if (mounted) {
          setState(() {
            _trips = tripsResponse.data ?? [];
            _tripStats = statsResponse.data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = tripsResponse.error ?? statsResponse.error ?? 'Failed to load data';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading trips: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadTripsData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OverviewScreen()),
            );
          },
        ),
        title: Text(
          'earnings'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            onPressed: _showAddTripDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'Trips', icon: Icon(Icons.route_outlined)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTripsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      bottomNavigationBar: const EnhancedBottomNavigation(currentIndex: 2),
    );
  }

  // Overview Tab - Earnings Summary
  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildEarningsCard(
                    'Total Earnings',
                    '₹${_tripStats?.totalEarnings.toStringAsFixed(2) ?? '0.00'}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEarningsCard(
                    'Total Trips',
                    '${_tripStats?.totalTrips ?? 0}',
                    Icons.route,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildEarningsCard(
                    'Cash Earnings',
                    '₹${_tripStats?.cashEarnings.toStringAsFixed(2) ?? '0.00'}',
                    Icons.money,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEarningsCard(
                    'Digital Earnings',
                    '₹${_tripStats?.digitalEarnings.toStringAsFixed(2) ?? '0.00'}',
                    Icons.credit_card,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildEarningsCard(
                    'Total Tips',
                    '₹${_tripStats?.totalTips.toStringAsFixed(2) ?? '0.00'}',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEarningsCard(
                    'Avg per Trip',
                    '₹${_tripStats?.averageTripEarnings.toStringAsFixed(2) ?? '0.00'}',
                    Icons.trending_up,
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Trips Section
            _buildSectionHeader('Recent Trips', Icons.history),
            const SizedBox(height: 12),

            if (_trips.isEmpty)
              _buildEmptyState()
            else
              ..._trips.take(3).map((trip) => _buildTripCard(trip)),

            if (_trips.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: Text('View All Trips (${_trips.length})'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Trips Tab - Trip List and Management
  Widget _buildTripsTab() {
    return Column(
      children: [
        // Add Trip Button
        Container(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddTripDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),

        // Trip List
        Expanded(
          child: _trips.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(_trips[index]);
                  },
                ),
        ),
      ],
    );
  }

  // Analytics Tab - Charts and Statistics
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Payment Methods', Icons.pie_chart),
          const SizedBox(height: 16),

          // Payment Method Distribution
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Cash Payments',
                  '${_tripStats?.cashTrips ?? 0}',
                  '${_tripStats != null && _tripStats!.totalTrips > 0 ? ((_tripStats!.cashTrips / _tripStats!.totalTrips) * 100).toStringAsFixed(1) : '0'}%',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Digital Payments',
                  '${_tripStats?.digitalTrips ?? 0}',
                  '${_tripStats != null && _tripStats!.totalTrips > 0 ? ((_tripStats!.digitalTrips / _tripStats!.totalTrips) * 100).toStringAsFixed(1) : '0'}%',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Trip Statistics', Icons.bar_chart),
          const SizedBox(height: 16),

          // Trip Statistics
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Distance',
                  '${_tripStats?.totalDistance.toStringAsFixed(1) ?? '0.0'} km',
                  'All trips combined',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Duration',
                  '${_tripStats?.totalDuration ?? 0} min',
                  'All trips combined',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg Distance',
                  '${_tripStats?.averageTripDistance.toStringAsFixed(1) ?? '0.0'} km',
                  'Per trip average',
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg Duration',
                  '${_tripStats != null && _tripStats!.completedTrips > 0 ? (_tripStats!.totalDuration / _tripStats!.completedTrips).toStringAsFixed(0) : '0'} min',
                  'Per trip average',
                  Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildEarningsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.paymentMethod == 'Cash'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.paymentMethod,
                  style: TextStyle(
                    color: trip.paymentMethod == 'Cash' ? Colors.green : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Trip #${trip.tripId}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.person, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '₹${trip.totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${trip.pickupLocation} → ${trip.dropoffLocation}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                '${trip.durationMinutes} min',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.straighten, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                '${trip.distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (trip.tipAmount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '₹${trip.tipAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips recorded yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first trip to start tracking earnings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTripDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Trip'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Add Trip Dialog
  void _showAddTripDialog() {
    final formKey = GlobalKey<FormState>();
    final customerNameController = TextEditingController();
    final pickupController = TextEditingController();
    final dropoffController = TextEditingController();
    final distanceController = TextEditingController();
    final durationController = TextEditingController();
    final fareController = TextEditingController();
    final tipController = TextEditingController();
    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add New Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: pickupController,
                        decoration: const InputDecoration(
                          labelText: 'Pickup Location',
                          prefixIcon: Icon(Icons.my_location),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: dropoffController,
                        decoration: const InputDecoration(
                          labelText: 'Drop-off Location',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter drop-off location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: distanceController,
                              decoration: const InputDecoration(
                                labelText: 'Distance (km)',
                                prefixIcon: Icon(Icons.straighten),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (min)',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fareController,
                              decoration: const InputDecoration(
                                labelText: 'Fare (₹)',
                                prefixIcon: Icon(Icons.money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: tipController,
                              decoration: const InputDecoration(
                                labelText: 'Tip (₹)',
                                prefixIcon: Icon(Icons.star),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Cash', 'Digital'].map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (!_authService.isAuthenticated || _authService.currentDriver == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Not authenticated'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        final response = await _apiService.createTrip(
                          driverId: _authService.currentDriver!.id,
                          customerName: customerNameController.text,
                          pickupLocation: pickupController.text,
                          dropoffLocation: dropoffController.text,
                          distanceKm: double.parse(distanceController.text),
                          durationMinutes: int.parse(durationController.text),
                          baseFare: double.parse(fareController.text),
                          tipAmount: double.tryParse(tipController.text) ?? 0.0,
                          paymentMethod: selectedPaymentMethod.toLowerCase(),
                          notes: null,
                        );

                        // Hide loading
                        if (mounted) navigator.pop();

                        if (response.isSuccess) {
                          if (mounted) navigator.pop(); // Close dialog

                          // Refresh data
                          await _refreshData();

                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Trip added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to add trip: ${response.error}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Hide loading
                        if (mounted) navigator.pop();

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Error adding trip: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Add Trip'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}