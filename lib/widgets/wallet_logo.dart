import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/wallet.dart';

/// Brand-colored square tile with a single letter (J / K / 1).
/// Replicates the prototype's `WalletLogo` — including the 1px top
/// highlight + 1px bottom shadow that give it dimensionality.
class WalletLogo extends StatelessWidget {
  final WalletId wallet;
  final double size;

  const WalletLogo({
    super.key,
    required this.wallet,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final w = walletById(wallet);
    final radius = size * 0.28;
    final letterSize = size * 0.42;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: w.brandColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top 1px highlight (mimics inset 0 1px 0 rgba(255,255,255,0.25))
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
            // Bottom 1px shadow (mimics inset 0 -1px 0 rgba(0,0,0,0.15))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.black.withOpacity(0.15),
              ),
            ),
            // The letter glyph
            Text(
              w.logoGlyph,
              style: GoogleFonts.inter (
                color: Colors.white,
                fontSize: letterSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.03 * letterSize,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}