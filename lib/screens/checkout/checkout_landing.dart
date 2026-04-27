import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/currency.dart';
import '../../data/wallet.dart';
import '../../state/app_settings.dart';
import '../../theme/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_label.dart';
import '../../widgets/wallet_logo.dart';
import '../../widgets/yp_button.dart';

/// Single wallet vs split across multiple wallets.
enum PaymentMode { single, split }

/// Domain model for the merchant order shown in checkout.
/// Defined here because every checkout step needs the same shape, and
/// this is the first checkout-step file.
class CheckoutOrder {
  final String merchant;
  final String merchantAr;
  final String logo; // emoji glyph
  final Color color;
  final String orderId;
  final List<OrderItem> items;
  final double total; // expressed in [currency]
  final DisplayCurrency currency;

  const CheckoutOrder({
    required this.merchant,
    required this.merchantAr,
    required this.logo,
    required this.color,
    required this.orderId,
    required this.items,
    required this.total,
    required this.currency,
  });

  String localizedMerchant(AppLang lang) =>
      lang == AppLang.ar ? merchantAr : merchant;
}

class OrderItem {
  final String name;
  final String nameAr;
  final int qty;
  final double price;

  const OrderItem({
    required this.name,
    required this.nameAr,
    required this.qty,
    required this.price,
  });

  String localizedName(AppLang lang) =>
      lang == AppLang.ar ? nameAr : name;
}

/// Default order — same as the prototype's checkout flow.
const kDefaultOrder = CheckoutOrder(
  merchant: 'Mokha Coffee Roasters',
  merchantAr: 'محامص قهوة المخا',
  logo: '☕',
  color: Color(0xFF7D4F2B),
  orderId: 'YP-2A39F1',
  items: [
    OrderItem(
      name: 'Arabica beans · 500g',
      nameAr: 'حبوب أرابيكا 500غ',
      qty: 2,
      price: 8500,
    ),
    OrderItem(
      name: 'Hario V60 dripper',
      nameAr: 'فلتر هاريو V60',
      qty: 1,
      price: 12500,
    ),
    OrderItem(
      name: 'Delivery (Sanaa)',
      nameAr: 'شحن داخل صنعاء',
      qty: 1,
      price: 2500,
    ),
  ],
  total: 32000,
  currency: DisplayCurrency.yer,
);

/// Step 1 — order summary, payment-method picker, and (when single)
/// the source-wallet picker, or (when split) the auto-split info banner.
class CheckoutLanding extends StatelessWidget {
  final CheckoutOrder order;
  final PaymentMode mode;
  final ValueChanged<PaymentMode> onModeChange;
  final WalletId singleWallet;
  final ValueChanged<WalletId> onSingleWalletChange;
  final VoidCallback onContinue;

  const CheckoutLanding({
    super.key,
    required this.order,
    required this.mode,
    required this.onModeChange,
    required this.singleWallet,
    required this.onSingleWalletChange,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MerchantCard(order: order, lang: lang),

          const SizedBox(height: 22),

          SectionLabel(S.t('payment_method', lang)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  active: mode == PaymentMode.single,
                  title: S.t('single_wallet', lang),
                  sub: S.t('pay_one_wallet', lang),
                  onTap: () => onModeChange(PaymentMode.single),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeCard(
                  active: mode == PaymentMode.split,
                  title: S.t('split_payment', lang),
                  sub: S.t('combine_multiple', lang),
                  onTap: () => onModeChange(PaymentMode.split),
                  badge: const _SmartBadge(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (mode == PaymentMode.single)
            ...kWallets.map((w) {
              final yerEquiv =
                  convertCcy(w.balance, w.currency, DisplayCurrency.yer);
              final sufficient = yerEquiv >= order.total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SingleWalletRow(
                  wallet: w,
                  lang: lang,
                  isSelected: singleWallet == w.id,
                  isSufficient: sufficient,
                  onTap:
                      sufficient ? () => onSingleWalletChange(w.id) : null,
                ),
              );
            })
          else
            _SplitInfoBanner(lang: lang),

          const SizedBox(height: 22),

          YpButton(
            label: mode == PaymentMode.split
                ? S.t('customize_split', lang)
                : S.t('continue_lbl', lang),
            height: 56,
            fullWidth: true,
            trailing: Transform.rotate(
              angle: isAr ? math.pi : 0,
              child: const Icon(Icons.arrow_outward_rounded, size: 18),
            ),
            onPressed: onContinue,
          ),

          const SizedBox(height: 14),

          // E2E encryption footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 12, color: pal.text3),
              const SizedBox(width: 6),
              Text(
                S.t('e2e_protected', lang),
                style: sansStyle(lang, fontSize: 11, color: pal.text3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Merchant gradient card ──────────────────────────────────

class _MerchantCard extends StatelessWidget {
  final CheckoutOrder order;
  final AppLang lang;
  const _MerchantCard({required this.order, required this.lang});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant identity
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: order.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  order.logo,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.t('paying', lang).toUpperCase(),
                      style: sansStyle(
                        lang,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA8A8A3),
                        letterSpacing: 0.66,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.localizedMerchant(lang),
                      style: sansStyle(
                        lang,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F5F3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 0.5, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),

          // Items
          for (int i = 0; i < order.items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.items[i].qty}× ${order.items[i].localizedName(lang)}',
                    style: sansStyle(
                      lang,
                      fontSize: 13,
                      color: const Color(0xFFA8A8A3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fmtMoney(
                    order.items[i].price * order.items[i].qty,
                    DisplayCurrency.yer,
                    lang,
                  ),
                  style: monoStyle(
                    fontSize: 13,
                    color: const Color(0xFFF5F5F3),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          Container(height: 0.5, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),

          // Total
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  S.t('order_total', lang),
                  style: sansStyle(
                    lang,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA8A8A3),
                  ),
                ),
              ),
              Text(
                fmtMoney(order.total, DisplayCurrency.yer, lang),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5F5F3),
                  letterSpacing: -0.03 * 28,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'YER',
                  style: sansStyle(
                    lang,
                    fontSize: 13,
                    color: const Color(0xFFA8A8A3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${S.t('order', lang)} · ${order.orderId}',
            style: monoStyle(fontSize: 11, color: pal.text3),
          ),
        ],
      ),
    );
  }
}

// ─── Mode card (single vs split) ────────────────────────────

class _ModeCard extends StatelessWidget {
  final bool active;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final Widget? badge;

  const _ModeCard({
    required this.active,
    required this.title,
    required this.sub,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.read<AppSettings>().lang;

    return Material(
      color: active ? pal.bgCard : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppBrand.lime : pal.border,
              width: active ? 1.5 : 0.5,
            ),
          ),
          child: Stack(
            children: [
              if (badge != null)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: badge!,
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: sansStyle(
                      lang,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: pal.text1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: sansStyle(
                      lang,
                      fontSize: 11.5,
                      color: pal.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartBadge extends StatelessWidget {
  const _SmartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      decoration: BoxDecoration(
        color: AppBrand.lime.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 10, color: AppBrand.lime),
          SizedBox(width: 4),
          Text(
            'Smart',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppBrand.lime,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single wallet row ──────────────────────────────────────

class _SingleWalletRow extends StatelessWidget {
  final Wallet wallet;
  final AppLang lang;
  final bool isSelected;
  final bool isSufficient;
  final VoidCallback? onTap;

  const _SingleWalletRow({
    required this.wallet,
    required this.lang,
    required this.isSelected,
    required this.isSufficient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Opacity(
      opacity: isSufficient ? 1.0 : 0.45,
      child: Material(
        color: isSelected ? pal.bgCard : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppBrand.lime : pal.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                WalletLogo(wallet: wallet.id, size: 36),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: pal.text1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${fmtMoney(wallet.balance, wallet.currency, lang)} ${wallet.currency.code}',
                              style: monoStyle(
                                fontSize: 11.5,
                                color: pal.text3,
                              ),
                            ),
                            TextSpan(
                              text: ' ${S.t('available', lang)}',
                              style: sansStyle(
                                lang,
                                fontSize: 11.5,
                                color: pal.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (!isSufficient)
                  Text(
                    S.t('insufficient', lang),
                    style: sansStyle(
                      lang,
                      fontSize: 11,
                      color: AppBrand.warning,
                    ),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppBrand.lime
                          : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: pal.borderStrong,
                              width: 1.5,
                            ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: pal.textOnLime,
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitInfoBanner extends StatelessWidget {
  final AppLang lang;
  const _SplitInfoBanner({required this.lang});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppBrand.lime.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppBrand.lime.withOpacity(0.18),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AppBrand.lime,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              S.t('auto_split_info', lang),
              style: sansStyle(
                lang,
                fontSize: 13,
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