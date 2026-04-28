import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/currency.dart';
import '../data/transaction.dart';
import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/section_label.dart';
import '../widgets/tx_row.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/yp_status_bar.dart';
import '../widgets/yp_tab_bar.dart';

/// Dashboard / home base. Two layout variants:
/// - card: gradient hero + horizontal wallet card carousel
/// - minimal: typographic balance + vertical wallet strip list
///
/// [layoutOverride] lets the canvas-overview render two dashboards
/// side by side with opposite layouts, ignoring the user's tweak setting.
class DashboardScreen extends StatelessWidget {
  final ValueChanged<String>? onAction;
  final DashboardLayout? layoutOverride;
  final bool showTabBar;

  const DashboardScreen({
    super.key,
    this.onAction,
    this.layoutOverride,
    this.showTabBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final displayCcy = settings.displayCcy;
    final layout = layoutOverride ?? settings.dashboardLayout;

    final total = totalIn(displayCcy);
    final fire = (String tag) => () => onAction?.call(tag);

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Top bar ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _TopBar(
                      lang: lang,
                      onQr: fire('qr'),
                      onSettings: fire('settings'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Hero balance ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: layout == DashboardLayout.card
                        ? _BalanceHero(
                            total: total,
                            ccy: displayCcy,
                            lang: lang,
                          )
                        : _BalanceMinimal(
                            total: total,
                            ccy: displayCcy,
                            lang: lang,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Quick actions ────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionLabel(S.t('quick_actions', lang)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.arrow_outward_rounded,
                                label: S.t('send_money', lang),
                                onTap: fire('send'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.south_west_rounded,
                                label: S.t('request', lang),
                                onTap: fire('receive'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.alt_route_rounded,
                                label: S.t('split_pay', lang),
                                accent: true,
                                onTap: fire('split'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.qr_code_2_rounded,
                                label: S.t('scan_pay', lang),
                                onTap: fire('scan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Your wallets ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: SectionLabel(S.t('your_wallets', lang))),
                        TextButton(
                          onPressed: fire('addWallet'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppBrand.lime,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            '+ ${S.t('add_wallet', lang)}',
                            style: sansStyle(
                              lang,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppBrand.lime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Wallet list — varies by layout
                  if (layout == DashboardLayout.card)
                    _WalletCardList(lang: lang)
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: _WalletStripList(
                        lang: lang,
                        displayCcy: displayCcy,
                      ),
                    ),
                  const SizedBox(height: 28),

                  // ─── Recent activity ──────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: SectionLabel(S.t('recent', lang))),
                        TextButton(
                          onPressed: fire('history'),
                          style: TextButton.styleFrom(
                            foregroundColor: pal.text2,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            '${S.t('see_all', lang)} →',
                            style: sansStyle(
                              lang,
                              fontSize: 13,
                              color: pal.text2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: pal.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: pal.border, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < 3; i++)
                            TxRow(
                              tx: kTransactions[i],
                              lang: lang,
                              displayCcy: displayCcy,
                              isLast: i == 2,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showTabBar)
            YpTabBar(
              active: YpTab.home,
              onTap: (t) => onAction?.call(t.name),
              onSplitTap: fire('split'),
            ),
        ],
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppLang lang;
  final VoidCallback? onQr;
  final VoidCallback? onSettings;

  const _TopBar({
    required this.lang,
    required this.onQr,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      children: [
        // Avatar (initials)
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pal.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pal.border, width: 0.5),
          ),
          child: Text(
            'OA',
            style: sansStyle(
              lang,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: pal.text1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.t('hi', lang),
              style: sansStyle(lang, fontSize: 12, color: pal.text2),
            ),
            Text(
              S.t('omar', lang),
              style: sansStyle(
                lang,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pal.text1,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconBtnBox(
          onTap: onQr,
          child: const Icon(Icons.qr_code_2_rounded, size: 20),
        ),
        const SizedBox(width: 8),
        IconBtnBox(
          onTap: onSettings,
          child: const Icon(Icons.settings_outlined, size: 20),
        ),
      ],
    );
  }
}

// ─── Balance — card variant ──────────────────────────────────

class _BalanceHero extends StatelessWidget {
  final double total;
  final DisplayCurrency ccy;
  final AppLang lang;

  const _BalanceHero({
    required this.total,
    required this.ccy,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pal.borderStrong, width: 0.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lime glow blob top-right
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x40D4FF3A), Color(0x00D4FF3A)],
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
                      S.t('total_balance', lang).toUpperCase(),
                      style: sansStyle(
                        lang,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA8A8A3),
                        letterSpacing: 0.48,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppBrand.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        S.t('synced', lang),
                        style: sansStyle(
                          lang,
                          fontSize: 11,
                          color: AppBrand.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtMoney(total, ccy, lang),
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
                      ccy.code,
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
              const SizedBox(height: 8),
              Text(
                '${S.t('across_wallets', lang, vars: {'n': '${kWallets.length}'})}  ·  ${S.t('updated_now', lang)}',
                style: sansStyle(
                  lang,
                  fontSize: 13,
                  color: const Color(0xFFA8A8A3),
                ),
              ),
              const SizedBox(height: 18),
              // Currency chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in DisplayCurrency.values)
                    _CcyChip(currency: c, lang: lang),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CcyChip extends StatelessWidget {
  final DisplayCurrency currency;
  final AppLang lang;
  const _CcyChip({required this.currency, required this.lang});

  @override
  Widget build(BuildContext context) {
    final sub = kWallets
        .where((w) => w.currency == currency)
        .fold<double>(0, (s, w) => s + w.balance);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency.code,
            style: sansStyle(
              lang,
              fontSize: 11,
              color: const Color(0xFFA8A8A3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            fmtMoney(sub, currency, lang),
            style: monoStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF5F5F3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Balance — editorial / minimal variant ──────────────────

class _BalanceMinimal extends StatelessWidget {
  final double total;
  final DisplayCurrency ccy;
  final AppLang lang;

  const _BalanceMinimal({
    required this.total,
    required this.ccy,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.t('total_balance', lang)} · ${ccy.code}'.toUpperCase(),
            style: sansStyle(
              lang,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: pal.text3,
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fmtMoney(total, ccy, lang),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w600,
              color: pal.text1,
              letterSpacing: -0.045 * 56,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: pal.border),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in DisplayCurrency.values) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.code,
                      style: sansStyle(
                        lang,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pal.text3,
                        letterSpacing: 0.66,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtMoney(
                        kWallets
                            .where((w) => w.currency == c)
                            .fold<double>(0, (s, w) => s + w.balance),
                        c,
                        lang,
                      ),
                      style: monoStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: pal.text1,
                      ),
                    ),
                  ],
                ),
                if (c != DisplayCurrency.values.last) const SizedBox(width: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick action button ─────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.accent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.read<AppSettings>().lang;
    final fg = accent ? pal.textOnLime : pal.text1;

    return Material(
      color: accent ? AppBrand.lime : pal.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: accent ? null : Border.all(color: pal.border, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent
                      ? Colors.black.withOpacity(0.1)
                      : pal.bg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: sansStyle(
                  lang,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wallet list — card variant (horizontal scroll) ─────────

class _WalletCardList extends StatelessWidget {
  final AppLang lang;
  const _WalletCardList({required this.lang});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return SizedBox(
      height: 134,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kWallets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final w = kWallets[i];
          final isViewOnly = w.permission == WalletPermission.viewOnly;
          final pillBg = isViewOnly
              ? AppBrand.warning.withOpacity(0.12)
              : AppBrand.success.withOpacity(0.12);
          final pillFg = isViewOnly ? AppBrand.warning : AppBrand.success;
          final pillLabel = S.t(
            isViewOnly ? 'perm_view' : 'perm_full',
            lang,
          );

          return Container(
            width: 180,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: pal.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WalletLogo(wallet: w.id, size: 32),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        pillLabel,
                        style: sansStyle(
                          lang,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: pillFg,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  w.localizedName(lang),
                  style: sansStyle(lang, fontSize: 13, color: pal.text2),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        fmtMoney(w.balance, w.currency, lang),
                        style: monoStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: pal.text1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        w.currency.code,
                        style: sansStyle(
                          lang,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: pal.text3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  w.number,
                  style: monoStyle(fontSize: 11, color: pal.text3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Wallet list — strip variant (vertical) ─────────────────

class _WalletStripList extends StatelessWidget {
  final AppLang lang;
  final DisplayCurrency displayCcy;

  const _WalletStripList({
    required this.lang,
    required this.displayCcy,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: pal.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < kWallets.length; i++) ...[
            if (i > 0) Container(height: 0.5, color: pal.border),
            _WalletStripRow(
              wallet: kWallets[i],
              lang: lang,
              displayCcy: displayCcy,
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletStripRow extends StatelessWidget {
  final Wallet wallet;
  final AppLang lang;
  final DisplayCurrency displayCcy;

  const _WalletStripRow({
    required this.wallet,
    required this.lang,
    required this.displayCcy,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final converted =
        convertCcy(wallet.balance, wallet.currency, displayCcy);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                    fontWeight: FontWeight.w500,
                    color: pal.text1,
                  ),
                ),
                Text(
                  wallet.number,
                  style: monoStyle(fontSize: 11, color: pal.text3),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${fmtMoney(wallet.balance, wallet.currency, lang)} ${wallet.currency.code}',
                style: monoStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: pal.text1,
                ),
              ),
              Text(
                '≈ ${fmtMoney(converted, displayCcy, lang)} ${displayCcy.code}',
                style: TextStyle(
                  fontSize: 11,
                  color: pal.text3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}