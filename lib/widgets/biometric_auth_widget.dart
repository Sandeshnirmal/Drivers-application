import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/mobile_features_service.dart';

class BiometricAuthWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String authReason;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final VoidCallback? onError;

  const BiometricAuthWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.authReason,
    required this.onSuccess,
    this.onCancel,
    this.onError,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with TickerProviderStateMixin {
  final MobileFeaturesService _mobileService = MobileFeaturesService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isAuthenticating = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkBiometricAvailability();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _mobileService.isBiometricAvailable();
    final availableBiometrics = await _mobileService.getAvailableBiometrics();
    
    setState(() {
      _isBiometricAvailable = isAvailable;
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    if (!_isBiometricAvailable) {
      _showErrorDialog('Biometric authentication is not available on this device.');
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    _mobileService.mediumHaptic();

    try {
      final bool authenticated = await _mobileService.authenticateWithBiometrics(
        reason: widget.authReason,
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        _mobileService.lightHaptic();
        widget.onSuccess();
      } else {
        _mobileService.heavyHaptic();
        widget.onCancel?.call();
      }
    } catch (e) {
      _mobileService.heavyHaptic();
      _showErrorDialog('Authentication failed: ${e.toString()}');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility;
    }
    return Icons.security;
  }

  String _getBiometricText() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch the fingerprint sensor';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Look at the camera';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Look at the camera';
    }
    return 'Use device authentication';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            if (_isBiometricAvailable) ...[
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getBiometricIcon(),
                        size: 60,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                _getBiometricText(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_getBiometricIcon()),
                  label: Text(_isAuthenticating ? 'Authenticating...' : 'Authenticate'),
                ),
              ),
            ] else ...[
              Icon(
                Icons.security_outlined,
                size: 80,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Biometric authentication is not available',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please use your device PIN, pattern, or password',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (widget.onCancel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
