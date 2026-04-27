import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/currency.dart';
import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/device_frame.dart';
import 'checkout/checkout_header.dart';
import 'checkout/checkout_landing.dart';
import 'checkout/checkout_pin.dart';
import 'checkout/checkout_split.dart';
import 'checkout/checkout_success.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'link_wallet_screen.dart';
import 'send_screen.dart';
import 'split_screen.dart';
import 'welcome_screen.dart';

/// Marketing canvas — banner + 5 sections each containing one or more
/// device-framed previews of every flow in the app.
class CanvasOverview extends StatelessWidget {
  const CanvasOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Banner(),
                _SectionOnboarding(),
                _SectionDashboard(),
                _SectionSendHistory(),
                _SectionSplit(),
                _SectionCheckout(),
                _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Banner ──────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppBrand.lime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppBrand.lime.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: const Text(
              'TRACK · SEND & RECEIVE MONEY',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppBrand.lime,
                letterSpacing: 0.46,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Headline
          Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: pal.text1,
                height: 1.02,
                letterSpacing: -0.04 * 64,
              ),
              children: [
                const TextSpan(text: 'All your wallets.\n'),
                TextSpan(
                  text: 'One powerful experience.',
                  style: GoogleFonts.inter(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: AppBrand.lime,
                    height: 1.02,
                    letterSpacing: -0.04 * 64,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Lede
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: pal.text2,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'YemenPay is a unified wallet aggregator that lets users send, receive, and split payments across ',
                  ),
                  TextSpan(
                    text: 'Jaib',
                    style: TextStyle(
                      color: pal.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Alkuraimi',
                    style: TextStyle(
                      color: pal.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ', and '),
                  TextSpan(
                    text: 'One Cash',
                    style: TextStyle(
                      color: pal.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' — all from a single seamless interface.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Meta divider + items
          Container(height: 0.5, color: pal.border),
          const SizedBox(height: 28),
          const Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              _MetaItem(label: '3 wallets', sub: 'Jaib · Alkuraimi · One Cash'),
              _MetaItem(label: '3 currencies', sub: 'YER · SAR · USD'),
              _MetaItem(label: '6 core flows', sub: 'Onboarding to checkout'),
              _MetaItem(label: 'Bilingual', sub: 'English & Arabic RTL'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String sub;
  const _MetaItem({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: pal.text1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: TextStyle(color: pal.text2, fontSize: 12.5),
        ),
      ],
    );
  }
}

// ─── Reusable section + canvas card ──────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String? highlightLabel;
  final String sub;
  final List<Widget> cards;

  const _Section({
    required this.title,
    this.highlightLabel,
    required this.sub,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 56, 0, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: pal.text1,
                    letterSpacing: -0.84,
                  ),
                ),
                if (highlightLabel != null)
                  TextSpan(
                    text: ' · $highlightLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppBrand.lime,
                      letterSpacing: 0.78,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              sub,
              style: TextStyle(
                fontSize: 14,
                color: pal.text2,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: cards,
          ),
        ],
      ),
    );
  }
}

class _CanvasCard extends StatelessWidget {
  final String title;
  final String step;
  final String desc;
  final Widget child;

  const _CanvasCard({
    required this.title,
    required this.step,
    required this.desc,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: 440,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: pal.bg1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text1,
                    letterSpacing: -0.225,
                  ),
                ),
              ),
              Text(
                step,
                style: TextStyle(
                  fontSize: 11,
                  color: pal.text3,
                  fontFamily: 'monospace',
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Centered device frame
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: child,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 12.5,
                color: pal.text2,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 1: Onboarding ───────────────────────────────────

class _SectionOnboarding extends StatelessWidget {
  const _SectionOnboarding();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '1 · Onboarding & link wallets',
      sub: 'First-run experience. Welcome users, then walk them '
          'through linking their existing Yemeni wallets in one screen.',
      cards: const [
        _CanvasCard(
          title: 'Welcome',
          step: 'Step 1 · 3',
          desc: 'Stacked wallet metaphor — three currencies, one place. '
              'Lime-glow CTA sets the brand tone.',
          child: DeviceFrame(child: WelcomeScreen()),
        ),
        _CanvasCard(
          title: 'Link wallets',
          step: 'Step 2 · 3',
          desc: 'Multi-select with reassuring permission preview. '
              'Continue button counts wallets dynamically.',
          child: DeviceFrame(child: LinkWalletScreen()),
        ),
      ],
    );
  }
}

// ─── Section 2: Dashboard (with layout variants) ─────────────

class _SectionDashboard extends StatelessWidget {
  const _SectionDashboard();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final layout = settings.dashboardLayout;
    final altLayout = layout == DashboardLayout.card
        ? DashboardLayout.minimal
        : DashboardLayout.card;

    return _Section(
      title: '2 · Unified dashboard',
      sub: 'The home base. Total balance across currencies, per-wallet '
          'breakdown, quick actions, and recent activity. Two layout '
          'variants — toggle in Tweaks.',
      cards: [
        _CanvasCard(
          title: 'Live dashboard',
          step: 'Layout: ${layout.name}',
          desc: 'Hero balance with sync status, currency chips, '
              'horizontal wallet carousel, and 4 quick actions including '
              'Smart Split (lime accent).',
          child: const DeviceFrame(child: DashboardScreen()),
        ),
        _CanvasCard(
          title: 'Alternate layout',
          step: layout == DashboardLayout.card
              ? 'Editorial / minimal'
              : 'Card / hero',
          desc: layout == DashboardLayout.card
              ? 'Editorial layout — typographic hierarchy carries the '
                  'balance, no card chrome.'
              : 'Card layout — gradient hero with synced currency chips '
                  'for at-a-glance scanning.',
          child: DeviceFrame(
            child: DashboardScreen(layoutOverride: altLayout),
          ),
        ),
      ],
    );
  }
}

// ─── Section 3: Send + History ───────────────────────────────

class _SectionSendHistory extends StatelessWidget {
  const _SectionSendHistory();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '3 · Send & history',
      sub: 'Wallet-to-wallet transfers and the unified transaction log '
          '— the daily-driver flows that build trust.',
      cards: const [
        _CanvasCard(
          title: 'Send to contact',
          step: 'Transfer flow',
          desc: 'Recipient, amount, and source wallet on one screen. '
              'Tappable wallet chips, live FX preview, big CTA.',
          child: DeviceFrame(child: SendScreen()),
        ),
        _CanvasCard(
          title: 'Unified history',
          step: 'All wallets · filterable',
          desc: 'Inflow/outflow summary, type filter chips, date-grouped '
              'log. Split, transfer, and checkout entries each have a '
              'distinct icon.',
          child: DeviceFrame(child: HistoryScreen()),
        ),
      ],
    );
  }
}

// ─── Section 4: Split (highlight) ────────────────────────────

class _SectionSplit extends StatelessWidget {
  const _SectionSplit();

  @override
  Widget build(BuildContext context) {
    final variant = context.watch<AppSettings>().splitVariant;
    return _Section(
      title: '4 · Split payment',
      highlightLabel: 'HIGHLIGHT',
      sub: "The platform's crown jewel. Combine balances from multiple "
          'wallets — across YER, SAR, USD — in one atomic payment. '
          'Smart-split suggests the optimal mix; sliders let users tweak.',
      cards: [
        _CanvasCard(
          title: 'Smart split (in-app)',
          step: 'UX: ${variant.name}',
          desc: 'Auto-suggested optimal split with live FX. Stacked '
              'progress bar shows allocation across wallets. Adjust per '
              'wallet via ${variant == SplitVariant.sliders ? 'precision sliders' : 'segmented %'} controls.',
          child: const DeviceFrame(child: SplitScreen()),
        ),
      ],
    );
  }
}

// ─── Section 5: Checkout (4 step previews) ───────────────────

class _SectionCheckout extends StatelessWidget {
  const _SectionCheckout();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '5 · Merchant hosted checkout',
      sub: 'The differentiator. Yemeni online stores share a link; '
          'customers pay with any combination of wallets. Inspired by '
          "classic card checkout — re-imagined for a multi-wallet world.",
      cards: const [
        _CanvasCard(
          title: 'Order summary',
          step: 'Step 1 · 4',
          desc: 'Branded merchant header, line items, locked-down '
              'secure-payment chrome. Toggle single vs split.',
          child: DeviceFrame(
            child: _CheckoutStepPreview(step: CheckoutStep.landing),
          ),
        ),
        _CanvasCard(
          title: 'Customize split',
          step: 'Step 2 · 4',
          desc: 'Stacked allocation bar, per-wallet sliders, live FX '
              'conversion. Confirm only enabled when fully covered.',
          child: DeviceFrame(
            child: _CheckoutStepPreview(step: CheckoutStep.split),
          ),
        ),
        _CanvasCard(
          title: 'PIN confirm',
          step: 'Step 3 · 4',
          desc: '4-digit wallet PIN with biometric fallback. '
              'Auto-advances on completion.',
          child: DeviceFrame(
            child: _CheckoutStepPreview(step: CheckoutStep.pin),
          ),
        ),
        _CanvasCard(
          title: 'Receipt',
          step: 'Step 4 · 4',
          desc: 'Lime-glow checkmark, full receipt with per-wallet '
              'breakdown, share + done CTAs.',
          child: DeviceFrame(
            child: _CheckoutStepPreview(step: CheckoutStep.success),
          ),
        ),
      ],
    );
  }
}

/// Static preview of a single checkout step — same widgets the live
/// flow uses, with no-op callbacks so taps don't navigate.
class _CheckoutStepPreview extends StatelessWidget {
  final CheckoutStep step;
  const _CheckoutStepPreview({required this.step});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final variant = settings.splitVariant;
    const order = kDefaultOrder;
    final allocs = {
      WalletId.jaib: 12000.0,
      WalletId.alkuraimi:
          convertCcy(80, DisplayCurrency.sar, DisplayCurrency.yer),
      WalletId.onecash:
          convertCcy(17, DisplayCurrency.usd, DisplayCurrency.yer),
    };

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (step != CheckoutStep.success)
            CheckoutHeader(step: step, lang: lang, onBack: () {}),
          Expanded(
            child: switch (step) {
              CheckoutStep.landing => CheckoutLanding(
                  order: order,
                  mode: PaymentMode.split,
                  onModeChange: (_) {},
                  singleWallet: WalletId.jaib,
                  onSingleWalletChange: (_) {},
                  onContinue: () {},
                ),
              CheckoutStep.split => CheckoutSplit(
                  order: order,
                  allocs: allocs,
                  onAllocChange: (_, __) {},
                  variant: variant,
                  onContinue: () {},
                ),
              CheckoutStep.pin => CheckoutPin(
                  order: order,
                  onComplete: () {},
                ),
              CheckoutStep.success => CheckoutSuccess(
                  order: order,
                  mode: PaymentMode.split,
                  singleWallet: WalletId.jaib,
                  allocs: allocs,
                  onDone: () {},
                ),
            },
          ),
        ],
      ),
    );
  }
}

// ─── Footer ──────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 32),
      child: Column(
        children: [
          Container(height: 0.5, color: pal.border),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppBrand.lime,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Y',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YemenPay · designed for SalamHack 2025',
                    style: TextStyle(fontSize: 12, color: pal.text2),
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12, color: pal.text3),
                  children: [
                    const TextSpan(text: 'Open the '),
                    TextSpan(
                      text: 'Tweaks',
                      style: TextStyle(
                        color: pal.text2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' panel to switch theme, language, currency, density, and layouts.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}