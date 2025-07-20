import 'package:flutter/material.dart';
import '../overview_screen.dart';
import '../sales_cash_report_screen.dart';
import '../profile_screen.dart';
import '../enhanced_attendance_screen.dart';
import '../services/translation_service.dart';

class EnhancedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  
  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'dashboard'.tr,
                  index: 0,
                  isActive: currentIndex == 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.access_time_outlined,
                  activeIcon: Icons.access_time,
                  label: 'attendance'.tr,
                  index: 1,
                  isActive: currentIndex == 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.monetization_on_outlined,
                  activeIcon: Icons.monetization_on,
                  label: 'earnings'.tr,
                  index: 2,
                  isActive: currentIndex == 2,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'profile'.tr,
                  index: 3,
                  isActive: currentIndex == 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive 
                    ? colorScheme.primary 
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: textTheme.labelSmall!.copyWith(
                color: isActive 
                    ? colorScheme.primary 
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return; // Don't navigate if already on the same screen
    
    Widget destination;
    switch (index) {
      case 0:
        destination = const OverviewScreen();
        break;
      case 1:
        destination = const EnhancedAttendanceScreen();
        break;
      case 2:
        destination = const SalesCashReportScreen();
        break;
      case 3:
        destination = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
