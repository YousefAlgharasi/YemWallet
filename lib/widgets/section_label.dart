import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tiny uppercase section header — `text-3` color, 11px, +0.08em tracking.
/// Used to label sections like "Quick actions", "Your wallets", etc.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: pal.text3,
        letterSpacing: 0.88, // 0.08em × 11px
        height: 1.4,
      ),
    );
  }
}