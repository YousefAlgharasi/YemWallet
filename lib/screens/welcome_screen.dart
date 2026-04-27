import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/yp_button.dart';
import '../widgets/yp_logo.dart';
import '../widgets/yp_status_bar.dart';

/// First-run welcome screen — brand mark, angled card stack illustration,
/// localized headline, and the "Get started" / "I have an account" CTAs.
class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onStart;

  const WelcomeScreen({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand
                  Row(
                    children: [
                      const YpLogo(size: 32),
                      const SizedBox(width: 10),
                      Text(
                        'YemenPay',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: pal.text1,
                          letterSpacing: -0.36, // -0.02em × 18
                        ),
                      ),
                    ],
                  ),

                  // Hero illustration
                  const Expanded(
                    child: Center(child: _WalletStack()),
                  ),

                  // Headline + subtitle
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.t('welcome', lang),
                          style: sansStyle(
                            lang,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: pal.text1,
                            height: 1.05,
                            letterSpacing: -0.035 * 38,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          S.t('welcome_sub', lang),
                          style: sansStyle(
                            lang,
                            fontSize: 16,
                            color: pal.text2,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Primary CTA — arrow flips for RTL
                  YpButton(
                    label: S.t('get_started', lang),
                    height: 56,
                    fullWidth: true,
                    trailing: Transform.rotate(
                      angle: isAr ? math.pi : 0,
                      child: const Icon(Icons.arrow_outward_rounded, size: 18),
                    ),
                    onPressed: onStart,
                  ),

                  const SizedBox(height: 8),

                  // Secondary text-button
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: pal.text2,
                        textStyle: sansStyle(
                          lang,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(S.t('has_account', lang)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three angled wallet "credit cards" stacked behind a lime glow.
/// Used only by the welcome screen, so kept private to this file.
class _WalletStack extends StatelessWidget {
  const _WalletStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lime glow blob (sits behind everything)
          Positioned(
            top: -20,
            left: -10,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x59D4FF3A), Color(0x00D4FF3A)],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),

          // Back card — One Cash USD (purple)
          const _WalletCard(
            top: 80 + 60,
            rotationDeg: -10,
            label: 'ONE CASH',
            ccy: 'USD',
            amount: '\$100.00',
            gradient: LinearGradient(
              colors: [Color(0xFFB39DFF), Color(0xFF8A6FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          // Middle card — Alkuraimi SAR (blue)
          const _WalletCard(
            top: 80,
            rotationDeg: -2,
            label: 'ALKURAIMI',
            ccy: 'SAR',
            amount: '500 ر.س',
            gradient: LinearGradient(
              colors: [Color(0xFF4D8AFF), Color(0xFF2D5FDF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          // Front card — Jaib YER (orange)
          const _WalletCard(
            top: 80 - 50,
            rotationDeg: 8,
            label: 'JAIB',
            ccy: 'YER',
            amount: '80,000 ر.ي',
            gradient: LinearGradient(
              colors: [Color(0xFFFF7A45), Color(0xFFD4501A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double top;
  final double rotationDeg;
  final String label;
  final String ccy;
  final String amount;
  final Gradient gradient;

  const _WalletCard({
    required this.top,
    required this.rotationDeg,
    required this.label,
    required this.ccy,
    required this.amount,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Transform.rotate(
        angle: rotationDeg * math.pi / 180,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(0, 20),
                blurRadius: 50,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card header — wallet name + currency chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.65, // 0.05em × 13
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ccy,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Card balance — mono with tabular numerals
              Text(
                amount,
                style: monoStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}