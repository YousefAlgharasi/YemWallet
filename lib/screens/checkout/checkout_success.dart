import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/currency.dart';
import '../../data/wallet.dart';
import '../../state/app_settings.dart';
import '../../theme/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wallet_logo.dart';
import '../../widgets/yp_button.dart';
import '../../widgets/yp_status_bar.dart';
import 'checkout_landing.dart' show CheckoutOrder, PaymentMode;

/// Step 4 — payment complete. Lime check ring with glow, headline,
/// per-wallet receipt breakdown, and Share + Done CTAs.
class CheckoutSuccess extends StatelessWidget {
  final CheckoutOrder order;
  final PaymentMode mode;
  final WalletId singleWallet;
  final Map<WalletId, double> allocs;
  final VoidCallback onDone;

  const CheckoutSuccess({
    super.key,
    required this.order,
    required this.mode,
    required this.singleWallet,
    required this.allocs,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        children: [
          const YpStatusBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Centered success indicator
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _SuccessRing(textOnLime: pal.textOnLime),
                        const SizedBox(height: 24),
                        Text(
                          S.t('payment_complete', lang),
                          style: sansStyle(
                            lang,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: pal.text1,
                            letterSpacing: -0.03 * 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAr
                              ? '${S.t('paid_to', lang)} ${fmtMoney(order.total, DisplayCurrency.yer, lang)} YER إلى ${order.merchantAr}'
                              : '${fmtMoney(order.total, DisplayCurrency.yer, lang)} YER ${S.t('paid_to', lang)} ${order.merchant}',
                          style: sansStyle(
                            lang,
                            fontSize: 14,
                            color: pal.text2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Receipt card
                  _ReceiptCard(
                    order: order,
                    mode: mode,
                    singleWallet: singleWallet,
                    allocs: allocs,
                    lang: lang,
                  ),

                  const SizedBox(height: 14),

                  // Share + Done
                  Row(
                    children: [
                      Expanded(
                        child: YpButton(
                          label: S.t('share', lang),
                          variant: YpButtonVariant.ghost,
                          height: 48,
                          fullWidth: true,
                          leading: const Icon(
                            Icons.ios_share_rounded,
                            size: 16,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: YpButton(
                          label: S.t('done', lang),
                          height: 48,
                          fullWidth: true,
                          onPressed: onDone,
                        ),
                      ),
                    ],
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

// ─── Glowing success ring ────────────────────────────────────

class _SuccessRing extends StatelessWidget {
  final Color textOnLime;
  const _SuccessRing({required this.textOnLime});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          // Glow halo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x66D4FF3A), Color(0x00D4FF3A)],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // Solid lime disc
          Positioned(
            top: 20,
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppBrand.lime,
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.lime.withOpacity(0.4),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: textOnLime,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Receipt card ────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  final CheckoutOrder order;
  final PaymentMode mode;
  final WalletId singleWallet;
  final Map<WalletId, double> allocs;
  final AppLang lang;

  const _ReceiptCard({
    required this.order,
    required this.mode,
    required this.singleWallet,
    required this.allocs,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: pal.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.t('receipt', lang).toUpperCase(),
                style: sansStyle(
                  lang,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: pal.text3,
                  letterSpacing: 0.66,
                ),
              ),
              Text(
                order.orderId,
                style: monoStyle(fontSize: 11, color: pal.text3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: pal.border),
          const SizedBox(height: 12),

          // Body — single wallet OR per-wallet split breakdown
          if (mode == PaymentMode.single)
            _SingleWalletRow(
              walletId: singleWallet,
              order: order,
              lang: lang,
            )
          else
            _SplitWalletRows(allocs: allocs, lang: lang),

          const SizedBox(height: 12),
          Container(height: 0.5, color: pal.border),
          const SizedBox(height: 12),

          // Total
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.t('total_paid', lang),
                style: sansStyle(
                  lang,
                  fontSize: 12,
                  color: pal.text3,
                ),
              ),
              Text(
                '${fmtMoney(order.total, DisplayCurrency.yer, lang)} YER',
                style: monoStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: pal.text1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SingleWalletRow extends StatelessWidget {
  final WalletId walletId;
  final CheckoutOrder order;
  final AppLang lang;

  const _SingleWalletRow({
    required this.walletId,
    required this.order,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final wallet = walletById(walletId);
    return Row(
      children: [
        WalletLogo(wallet: walletId, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            wallet.localizedName(lang),
            style: sansStyle(lang, fontSize: 13, color: pal.text1),
          ),
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
    );
  }
}

class _SplitWalletRows extends StatelessWidget {
  final Map<WalletId, double> allocs;
  final AppLang lang;

  const _SplitWalletRows({required this.allocs, required this.lang});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final used =
        kWallets.where((w) => (allocs[w.id] ?? 0) > 0.5).toList();

    return Column(
      children: [
        for (int i = 0; i < used.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _SplitWalletRow(wallet: used[i], allocs: allocs, lang: lang, pal: pal),
        ],
      ],
    );
  }
}

class _SplitWalletRow extends StatelessWidget {
  final Wallet wallet;
  final Map<WalletId, double> allocs;
  final AppLang lang;
  final AppPalette pal;

  const _SplitWalletRow({
    required this.wallet,
    required this.allocs,
    required this.lang,
    required this.pal,
  });

  @override
  Widget build(BuildContext context) {
    final yerA = allocs[wallet.id] ?? 0;
    final native = convertCcy(yerA, DisplayCurrency.yer, wallet.currency);
    return Row(
      children: [
        WalletLogo(wallet: wallet.id, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            wallet.localizedName(lang),
            style: sansStyle(lang, fontSize: 13, color: pal.text1),
          ),
        ),
        Text(
          '${fmtMoney(native, wallet.currency, lang)} ${wallet.currency.code}',
          style: monoStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: pal.text1,
          ),
        ),
      ],
    );
  }
}