import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/currency.dart';
import '../../data/wallet.dart';
import '../../state/app_settings.dart';
import '../../theme/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/lime_slider.dart';
import '../../widgets/section_label.dart';
import '../../widgets/split_bar.dart';
import '../../widgets/wallet_logo.dart';
import '../../widgets/yp_button.dart';
import 'checkout_landing.dart' show CheckoutOrder;

/// Step 2 — customize the split allocation across wallets.
/// State (allocs) is owned by [CheckoutFlow] and passed in / mutated
/// via [onAllocChange] so it survives navigation between steps.
class CheckoutSplit extends StatelessWidget {
  final CheckoutOrder order;
  final Map<WalletId, double> allocs;
  final void Function(WalletId, double) onAllocChange;
  final SplitVariant variant;
  final VoidCallback onContinue;

  const CheckoutSplit({
    super.key,
    required this.order,
    required this.allocs,
    required this.onAllocChange,
    required this.variant,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;

    final totalAlloc = allocs.values.fold<double>(0, (a, b) => a + b);
    final remaining = order.total - totalAlloc;
    final isCovered = remaining <= 0.5;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact merchant header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: pal.bg1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: order.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.logo,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${S.t('to', lang)} ${order.localizedMerchant(lang)}',
                        style: sansStyle(
                          lang,
                          fontSize: 11,
                          color: pal.text3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${fmtMoney(order.total, DisplayCurrency.yer, lang)} YER',
                        style: monoStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: pal.text1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // "How to split" + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: SectionLabel(S.t('how_to_split', lang))),
              Text(
                isCovered
                    ? S.t('covered', lang)
                    : '${fmtMoney(remaining, DisplayCurrency.yer, lang)} ${S.t('short_remaining', lang)}',
                style: monoStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCovered ? AppBrand.success : AppBrand.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stacked allocation bar + scale labels
          SplitBar(allocs: allocs, target: order.total),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 10.5,
                  color: pal.text3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${fmtMoney(order.total, DisplayCurrency.yer, lang)} YER',
                style: TextStyle(
                  fontSize: 10.5,
                  color: pal.text3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Per-wallet allocation rows
          for (int i = 0; i < kWallets.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _AllocRow(
              wallet: kWallets[i],
              yerAlloc: allocs[kWallets[i].id] ?? 0,
              lang: lang,
              variant: variant,
              onChange: (v) => onAllocChange(kWallets[i].id, v),
            ),
          ],

          const SizedBox(height: 20),

          // Confirm CTA
          YpButton(
            label: S.t('confirm_split', lang),
            height: 56,
            fullWidth: true,
            disabled: !isCovered,
            trailing: Transform.rotate(
              angle: isAr ? math.pi : 0,
              child: const Icon(Icons.arrow_outward_rounded, size: 18),
            ),
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _AllocRow extends StatelessWidget {
  final Wallet wallet;
  final double yerAlloc;
  final AppLang lang;
  final SplitVariant variant;
  final ValueChanged<double> onChange;

  const _AllocRow({
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
                    Text(
                      '${fmtMoney(wallet.balance, wallet.currency, lang)} ${wallet.currency.code}',
                      style: monoStyle(fontSize: 11, color: pal.text3),
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
                        fontSize: 10,
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
              child: _SegmentChip(
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

class _SegmentChip extends StatelessWidget {
  final double stop;
  final bool isActive;
  final VoidCallback onTap;
  final Color bg;
  final Color activeFg;
  final Color inactiveFg;

  const _SegmentChip({
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