import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The static "9:41 / signal · wifi · battery" header that sits at the
/// top of every phone screen inside the device frame.
class YpStatusBar extends StatelessWidget {
  const YpStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '9:41',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: pal.text1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.signal_cellular_alt, size: 14, color: pal.text1),
                const SizedBox(width: 6),
                Icon(Icons.wifi, size: 14, color: pal.text1),
                const SizedBox(width: 6),
                Icon(Icons.battery_full, size: 16, color: pal.text1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}