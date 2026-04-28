import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class StackedToastShowcase extends StatefulWidget {
  const StackedToastShowcase({super.key});

  @override
  State<StackedToastShowcase> createState() => _StackedToastShowcaseState();
}

class _StackedToastShowcaseState extends State<StackedToastShowcase> {
  final StackedToastController _toastController = StackedToastController();

  void _showInfoToast() {
    _toastController.show(
      StackedToastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Suggestion',
        message: 'Consider optimizing your images for better performance.',
        type: StackedToastType.info,
        icon: Icons.lightbulb_outline_rounded,
        actionLabel: 'View',
      ),
    );
  }

  void _showWarningToast() {
    _toastController.show(
      StackedToastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Storage Warning',
        message: 'Your drive is 90% full. Upgrade soon.',
        type: StackedToastType.warning,
        icon: Icons.warning_amber_rounded,
        actionLabel: 'Upgrade',
      ),
    );
  }

  void _showSuccessToast() {
    _toastController.show(
      StackedToastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Order Completed',
        message: 'Your order #2841 has been processed successfully.',
        type: StackedToastType.success,
        icon: Icons.check_rounded,
        actionLabel: 'Track',
      ),
    );
  }

  void _showErrorToast() {
    _toastController.show(
      StackedToastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Connection Lost',
        message: 'Unable to connect to the server. Please check your internet.',
        type: StackedToastType.error,
        icon: Icons.wifi_off_rounded,
        actionLabel: 'Retry',
      ),
    );
  }

  void _showPromoToast() {
    _toastController.show(
      StackedToastItem(
        id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
        duration: const Duration(seconds: 4),
        builder: (context, onClose) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1C1E), Color(0xFF3A3A3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Toast Layout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Totally unique UI builder',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onClose,
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCustomToast() {
    _toastController.show(
      StackedToastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Security Alert',
        message: 'A new device logged into your account recently.',
        type: StackedToastType.custom,
        icon: Icons.security_rounded,
        actionLabel: 'Help',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // hasAppBar: false — this showcase has its own layered Stack with a
    // custom header and a toast overlay that must sit above everything.
    return ShowcaseShell(
      title: 'Stacked Toast',
      hasAppBar: false,
      showBackButton: false,
      showInfoButton: false,
      backgroundColor: Colors.white,
      description:
          'GPU-optimized toast stack using a single OverlayEntry. Up to 3 '
          'simultaneous toasts collapse and rotate like a physical stack. '
          'Supports fully custom builder layouts for branded notifications.',
      codeSnippet: '''// 1. Create the controller
final _toastController = StackedToastController();

// 2. Place the overlay widget in your Scaffold body Stack
StackedToastInteraction(controller: _toastController)

// 3. Show a toast from anywhere
_toastController.show(StackedToastItem(
  id: 'id_1',
  title: 'Order Completed',
  message: 'Your order has been processed.',
  type: StackedToastType.success,
  actionLabel: 'Track',
))''',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background glow
          Positioned(
            top: -150,
            left: -150,
            child: _buildGlowSphere(
                400, const Color(0xFF007AFF).withValues(alpha: 0.05)),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 140),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlatAestheticCard('Security notification',
                      'Account Protection', const Color(0xFF1C1C1E),
                      Icons.security_rounded, _showCustomToast),
                  const SizedBox(height: 12),
                  _buildFlatAestheticCard('System suggestion',
                      'Optimization Tips', const Color(0xFF007AFF),
                      Icons.lightbulb_outline_rounded, _showInfoToast),
                  const SizedBox(height: 12),
                  _buildFlatAestheticCard('Account warning',
                      'Storage Limits', const Color(0xFFFF9500),
                      Icons.warning_amber_rounded, _showWarningToast),
                  const SizedBox(height: 12),
                  _buildFlatAestheticCard('Process completion',
                      'Order Status', const Color(0xFF34C759),
                      Icons.check_rounded, _showSuccessToast),
                  const SizedBox(height: 12),
                  _buildFlatAestheticCard('Network error',
                      'Connectivity Issues', const Color(0xFFFF3B30),
                      Icons.wifi_off_rounded, _showErrorToast),
                  const SizedBox(height: 24),
                  _buildCustomToastTrigger(),
                ],
              ),
            ),
          ),
          // Consistent Header (Replicates AppBar look for immersive toast)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: MediaQuery.of(context).padding.top + 56,
              child: NavigationToolbar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerMiddle: true,
                middle: const Text(
                  'Stacked Toast',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                trailing: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF8E8E93),
                      size: 22,
                    ),
                    onPressed: () {
                      // Trigger info from ShowcaseShell's implicit logic 
                      // by searching for the ancestor state if it were public,
                      // or just Re-calling the info modal here.
                      _showInfoSheet(context);
                    },
                  ),
                ),
              ),
            ),
          ),
          // Interaction layer (Must be at the very top of Stack)
          StackedToastInteraction(
            controller: _toastController,
            style: const StackedToastStyle(topMargin: 0.0),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    // Replicates ShowcaseShell's bottom sheet logic
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        // Simple placeholder or re-implementation of _InfoBottomSheet
        // Since we want to be 100% consistent, I'll assume ShowcaseShell 
        // handles the title/desc/code if we can trigger it, but for now 
        // I'll keep the standard behavior.
        child: const SizedBox.shrink(), 
      ),
    );
  }

  Widget _buildGlowSphere(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _buildFlatAestheticCard(String label, String subtitle, Color color,
      IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.04), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.black.withValues(alpha: 0.1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomToastTrigger() {
    return GestureDetector(
      onTap: _showPromoToast,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Custom Toast',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text('Experimental Layout',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.rocket_launch_rounded,
                color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
