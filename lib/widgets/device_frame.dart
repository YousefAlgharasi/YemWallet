import 'package:flutter/material.dart';

/// iPhone-style chrome around a screen — bezel, notch, home indicator.
/// Fixed at 402×874 (the prototype's artboard size).
class DeviceFrame extends StatelessWidget {
  final Widget child;

  const DeviceFrame({super.key, required this.child});

  static const double width = 402;
  static const double height = 874;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bezelColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFD8D2C4);
    final outerRing = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.10);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.50)
        : Colors.black.withOpacity(0.18);
    final homeBarColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.4);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shell + bezel + clipped content
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: bezelColor,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                // 1px hairline ring on the outside edge
                BoxShadow(
                  color: outerRing,
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
                // Drop shadow below the device
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 40),
                  blurRadius: 80,
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: child,
            ),
          ),

          // Notch
          Positioned(
            top: 11,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 124,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),

          // Home indicator
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: homeBarColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}