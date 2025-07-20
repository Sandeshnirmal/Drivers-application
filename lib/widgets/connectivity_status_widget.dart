import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/mobile_features_service.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  final Widget child;
  final bool showOfflineMessage;

  const ConnectivityStatusWidget({
    super.key,
    required this.child,
    this.showOfflineMessage = true,
  });

  @override
  State<ConnectivityStatusWidget> createState() => _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget>
    with TickerProviderStateMixin {
  final MobileFeaturesService _mobileService = MobileFeaturesService();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isOnline = false;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initConnectivity();
    _mobileService.connectivityStream.listen(_updateConnectionStatus);
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initConnectivity() async {
    final result = await _mobileService.getConnectivityStatus();
    _updateConnectionStatus([result]);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final isOnline = _mobileService.isOnline(result);

    if (mounted) {
      setState(() {
        _connectionStatus = result;
        _isOnline = isOnline;
      });
    }

    if (widget.showOfflineMessage) {
      if (!isOnline && !_showBanner) {
        _showBanner = true;
        _slideController.forward();
        _mobileService.mediumHaptic();
      } else if (isOnline && _showBanner) {
        _showBanner = false;
        _slideController.reverse();
        _mobileService.lightHaptic();
      }
    }
  }

  String _getConnectionText() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.other:
        return 'Connected';
      case ConnectivityResult.none:
        return 'No Internet Connection';
    }
  }

  IconData _getConnectionIcon() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityResult.ethernet:
        return Icons.cable;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.vpn:
        return Icons.vpn_lock;
      case ConnectivityResult.other:
        return Icons.network_check;
      case ConnectivityResult.none:
        return Icons.wifi_off;
    }
  }

  Color _getConnectionColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _isOnline ? Colors.green : colorScheme.error;
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          
          // Offline Banner
          if (widget.showOfflineMessage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getConnectionColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Icon(
                          _getConnectionIcon(),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getConnectionText(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!_isOnline)
                          TextButton(
                            onPressed: () async {
                              _mobileService.selectionHaptic();
                              await _initConnectivity();
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Connectivity Status Indicator Widget
class ConnectivityIndicator extends StatefulWidget {
  final bool showText;
  final double iconSize;

  const ConnectivityIndicator({
    super.key,
    this.showText = true,
    this.iconSize = 16,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  final MobileFeaturesService _mobileService = MobileFeaturesService();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _mobileService.connectivityStream.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    final result = await _mobileService.getConnectivityStatus();
    _updateConnectionStatus([result]);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = _mobileService.isOnline(_connectionStatus);
    
    final icon = Icon(
      _getConnectionIcon(),
      size: widget.iconSize,
      color: isOnline ? Colors.green : theme.colorScheme.error,
    );

    if (!widget.showText) {
      return icon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          _getConnectionText(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isOnline ? Colors.green : theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getConnectionIcon() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityResult.none:
      default:
        return Icons.wifi_off;
    }
  }

  String _getConnectionText() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.none:
      default:
        return 'Offline';
    }
  }
}
