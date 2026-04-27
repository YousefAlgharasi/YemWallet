import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currency.dart';
import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/lime_slider.dart';
import '../widgets/section_label.dart';
import '../widgets/split_bar.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/yp_button.dart';
import '../widgets/yp_status_bar.dart';

/// Split-payment screen — combine balances from multiple wallets in one
/// atomic payment. Auto-suggests an optimal split (drain USD up to 70%,
/// then SAR, then top up YER) and lets users tweak per wallet.
class SplitScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onConfirm;
  final double initialAmountYer;

  const SplitScreen({
    super.key,
    this.onBack,
    this.onConfirm,
    this.initialAmountYer = 50000,
  });

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  late double _target;
  late Map<WalletId, double> _allocs;

  @override
  void initState() {
    super.initState();
    _target = widget.initialAmountYer;
    _allocs = _suggestedSplit(_target);
  }

  /// Suggest an "optimal" split — drains USD first (capped at 70% of its
  /// balance), then SAR, then tops up with YER.
  Map<WalletId, double> _suggestedSplit(double target) {
    var remaining = target;
    final allocs = <WalletId, double>{};
    const order = [
      WalletId.onecash,
      WalletId.alkuraimi,
      WalletId.jaib,
    ];
    for (final id in order) {
      final w = walletById(id);
      final maxYer =
          convertCcy(w.balance, w.currency, DisplayCurrency.yer);
      final candidate = math.min(remaining, maxYer);
      final adjusted =
          id == WalletId.onecash && remaining > maxYer * 0.7
              ? maxYer * 0.7
              : candidate;
      final finalYer = math.min(remaining, adjusted);
      allocs[id] = finalYer;
      remaining -= finalYer;
    }
    return allocs;
  }

  void _setTarget(double v) {
    setState(() {
      _target = v;
      _allocs = _suggestedSplit(_target);
    });
  }

  void _setAlloc(WalletId id, double yerVal) {
    final w = walletById(id);
    final maxYer = convertCcy(w.balance, w.currency, DisplayCurrency.yer);
    setState(() {
      _allocs[id] = yerVal.clamp(0.0, maxYer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final isAr = lang == AppLang.ar;
    final variant = settings.splitVariant;

    final totalAlloc = _allocs.values.fold<double>(0, (a, b) => a + b);
    final remaining = _target - totalAlloc;
    final isCovered = remaining <= 0.5;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          // Header
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBtnBox(
                  size: 36,
                  onTap: widget.onBack,
                  child: Icon(
                    isAr
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                  ),
                ),
                Text(
                  S.t('split_title', lang),
                  style: sansStyle(
                    lang,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text1,
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TargetAmountCard(
                    target: _target,
                    lang: lang,
                    onQuickPick: _setTarget,
                  ),

                  const SizedBox(height: 22),

                  // ── Split-across header + status indicator ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SectionLabel(S.t('split_across', lang)),
                      ),
                      Text(
                        isCovered
                            ? S.t('covered', lang)
                            : '${fmtMoney(remaining, DisplayCurrency.yer, lang)} ${S.t('short_remaining', lang)}',
                        style: monoStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCovered
                              ? AppBrand.success
                              : AppBrand.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SplitBar(allocs: _allocs, target: _target),

                  const SizedBox(height: 18),

                  // ── Per-wallet allocation rows ──────────────
                  for (int i = 0; i < kWallets.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _WalletAllocRow(
                      wallet: kWallets[i],
                      yerAlloc: _allocs[kWallets[i].id] ?? 0,
                      lang: lang,
                      variant: variant,
                      onChange: (v) =>
                          _setAlloc(kWallets[i].id, v),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Confirm CTA ─────────────────────────────
                  YpButton(
                    label:
                        '${S.t('confirm_and_pay', lang)} ${fmtMoney(_target, DisplayCurrency.yer, lang)} YER',
                    height: 56,
                    fullWidth: true,
                    disabled: !isCovered,
                    onPressed: widget.onConfirm,
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

// ─── Target amount card (gradient hero) ──────────────────────

class _TargetAmountCard extends StatelessWidget {
  final double target;
  final AppLang lang;
  final ValueChanged<double> onQuickPick;

  const _TargetAmountCard({
    required this.target,
    required this.lang,
    required this.onQuickPick,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    const amounts = [25000.0, 50000.0, 100000.0, 200000.0];

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pal.borderStrong, width: 0.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lime glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2ED4FF3A), Color(0x00D4FF3A)],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.t('pay_amount', lang).toUpperCase(),
                      style: sansStyle(
                        lang,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA8A8A3),
                        letterSpacing: 0.88,
                      ),
                    ),
                  ),
                  // Smart split pill
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    decoration: BoxDecoration(
                      color: AppBrand.lime.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: AppBrand.lime,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          S.t('smart_split', lang),
                          style: sansStyle(
                            lang,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppBrand.lime,
                            letterSpacing: 0.22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtMoney(target, DisplayCurrency.yer, lang),
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F5F3),
                      letterSpacing: -0.04 * 44,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'YER',
                      style: sansStyle(
                        lang,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA8A8A3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: sansStyle(
                    lang,
                    fontSize: 12,
                    color: const Color(0xFFA8A8A3),
                  ),
                  children: [
                    TextSpan(text: lang == AppLang.ar ? 'إلى: ' : 'To: '),
                    TextSpan(
                      text: 'Mokha Coffee Roasters',
                      style: sansStyle(
                        lang,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF5F5F3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Quick adjust chips
              Row(
                children: [
                  for (int i = 0; i < amounts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    _QuickAmountChip(
                      label: '${(amounts[i] / 1000).toInt()}k',
                      isActive: target == amounts[i],
                      onTap: () => onQuickPick(amounts[i]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppBrand.lime.withOpacity(0.18)
          : Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppBrand.lime.withOpacity(0.4)
                  : Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppBrand.lime
                  : const Color(0xFFF5F5F3),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Per-wallet allocation row ──────────────────────────────

class _WalletAllocRow extends StatelessWidget {
  final Wallet wallet;
  final double yerAlloc;
  final AppLang lang;
  final SplitVariant variant;
  final ValueChanged<double> onChange;

  const _WalletAllocRow({
    required this.wallet,
    required this.yerAlloc,
    required this.lang,
    required this.variant,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final nativeAlloc =
        convertCcy(yerAlloc, DisplayCurrency.yer, wallet.currency);
    final maxYer =
        convertCcy(wallet.balance, wallet.currency, DisplayCurrency.yer);
    final hasAlloc = yerAlloc > 0.5;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: pal.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              WalletLogo(wallet: wallet.id, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      wallet.localizedName(lang),
                      style: sansStyle(
                        lang,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pal.text1,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${fmtMoney(wallet.balance, wallet.currency, lang)} ${wallet.currency.code}',
                            style:
                                monoStyle(fontSize: 11, color: pal.text3),
                          ),
                          TextSpan(
                            text: ' ${S.t('available', lang)}',
                            style: sansStyle(
                              lang,
                              fontSize: 11,
                              color: pal.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${fmtMoney(nativeAlloc, wallet.currency, lang)} ${wallet.currency.code}',
                    style: monoStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasAlloc ? AppBrand.lime : pal.text3,
                    ),
                  ),
                  if (wallet.currency != DisplayCurrency.yer && hasAlloc)
                    Text(
                      '= ${fmtMoney(yerAlloc, DisplayCurrency.yer, lang)} YER',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: pal.text3,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (variant == SplitVariant.sliders)
            LimeSlider(
              value: yerAlloc,
              max: maxYer,
              step: 100,
              onChanged: onChange,
            )
          else
            _SegmentedRow(
              maxYer: maxYer,
              currentYer: yerAlloc,
              onChange: onChange,
            ),
        ],
      ),
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final double maxYer;
  final double currentYer;
  final ValueChanged<double> onChange;

  const _SegmentedRow({
    required this.maxYer,
    required this.currentYer,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    const stops = [0.0, 0.25, 0.5, 0.75, 1.0];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          for (int i = 0; i < stops.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _SegmentedChip(
                stop: stops[i],
                isActive: (currentYer - maxYer * stops[i]).abs() <
                    maxYer * 0.05,
                onTap: () => onChange(maxYer * stops[i]),
                bg: pal.bg3,
                activeFg: pal.textOnLime,
                inactiveFg: pal.text2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentedChip extends StatelessWidget {
  final double stop;
  final bool isActive;
  final VoidCallback onTap;
  final Color bg;
  final Color activeFg;
  final Color inactiveFg;

  const _SegmentedChip({
    required this.stop,
    required this.isActive,
    required this.onTap,
    required this.bg,
    required this.activeFg,
    required this.inactiveFg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppBrand.lime : bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: Text(
              '${(stop * 100).round()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? activeFg : inactiveFg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}