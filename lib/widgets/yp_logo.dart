import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Small lime-square brand mark with the "Y" letterform.
/// Used in the Welcome screen header (size 32) and the Checkout
/// header (size 20). Letter is always Geist — it's a brand glyph.
class YpLogo extends StatelessWidget {
  final double size;

  const YpLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final letterSize = size * 0.55;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppBrand.lime,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        'Y',
        style: GoogleFonts.inter(
          fontSize: letterSize,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0A0A0A),
          letterSpacing: -0.05 * letterSize,
          height: 1,
        ),
      ),
    );
  }
}