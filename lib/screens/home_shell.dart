import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../tweaks_panel.dart';
import '../widgets/device_frame.dart';
import '../widgets/yp_logo.dart';
import 'canvas_overview.dart';
import 'checkout/checkout_flow.dart';

enum _ShellTab { overview, prototype }

/// Top-level app shell — fixed header (brand · tabs · version pill),
/// either the canvas overview or the deep clickable prototype, plus a
/// floating tweaks panel in the bottom-right.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  _ShellTab _tab = _ShellTab.overview;
  Key _flowKey = UniqueKey();

  void _restartFlow() {
    setState(() => _flowKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      backgroundColor: pal.bg0,
      body: Stack(
        children: [
          Column(
            children: [
              _PageHeader(
                tab: _tab,
                onTabChange: (t) => setState(() => _tab = t),
              ),
              Expanded(
                child: switch (_tab) {
                  _ShellTab.overview => const CanvasOverview(),
                  _ShellTab.prototype => _PrototypeStage(
                      flowKey: _flowKey,
                      onRestart: _restartFlow,
                    ),
                },
              ),
            ],
          ),

          // Floating tweaks panel
          const Positioned(
            right: 16,
            bottom: 16,
            child: TweaksPanel(),
          ),
        ],
      ),
    );
  }
}

// ─── Page header ─────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final _ShellTab tab;
  final ValueChanged<_ShellTab> onTabChange;

  const _PageHeader({required this.tab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

    return Container(
      padding: const EdgeInsets.fromLTRB(36, 28, 36, 20),
      decoration: BoxDecoration(
        color: pal.bg0.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(color: pal.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Brand mark
          const YpLogo(size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YemenPay',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: pal.text1,
                  letterSpacing: -0.24,
                ),
              ),
              Text(
                'SalamHack 2025 · Send & Receive Money',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11.5,
                  color: pal.text3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: pal.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Tab(
                  label: 'Canvas overview',
                  active: tab == _ShellTab.overview,
                  onTap: () => onTabChange(_ShellTab.overview),
                ),
                _Tab(
                  label: 'Deep prototype',
                  active: tab == _ShellTab.prototype,
                  onTap: () => onTabChange(_ShellTab.prototype),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Version pill
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: AppBrand.lime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppBrand.lime.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 6,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppBrand.lime,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'v1.0 · Apr 2026',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppBrand.lime,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: active ? pal.bg3 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? pal.text1 : pal.text2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Deep prototype stage ────────────────────────────────────

class _PrototypeStage extends StatelessWidget {
  final Key flowKey;
  final VoidCallback onRestart;

  const _PrototypeStage({
    required this.flowKey,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 80,
        ),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [pal.bg2, pal.bg0],
            stops: const [0.0, 0.6],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
        child: Column(
          children: [
            // Stage info
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Text(
                    'Hosted checkout — full clickable flow',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: pal.text1,
                      letterSpacing: -0.96,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step through the merchant payment experience: '
                    'order → split → PIN → receipt. All buttons are interactive.',
                    style: TextStyle(
                      fontSize: 14,
                      color: pal.text2,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Stage controls — Live indicator + Restart
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pal.bg1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: pal.border, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    decoration: BoxDecoration(
                      color: AppBrand.lime,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 6,
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      onTap: onRestart,
                      borderRadius: BorderRadius.circular(9),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: pal.text2,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Restart flow',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: pal.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Clickable device frame
            DeviceFrame(
              child: CheckoutFlow(
                key: flowKey,
                onExit: onRestart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}