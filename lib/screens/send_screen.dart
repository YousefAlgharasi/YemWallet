import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/contact.dart';
import '../data/currency.dart';
import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/numpad.dart';
import '../widgets/section_label.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/yp_button.dart';
import '../widgets/yp_status_bar.dart';

/// Wallet-to-wallet transfer screen — recipient, amount entry, source
/// wallet picker, and a numpad. Defaults match the prototype:
/// 25000 from Jaib to contact c1.
class SendScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSent;

  const SendScreen({super.key, this.onBack, this.onSent});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String _amount = '25000';
  WalletId _from = WalletId.jaib;
  String _contactId = 'c1';

  void _onKey(String k) {
    setState(() {
      if (k == kBackspaceKey) {
        _amount = _amount.length > 1
            ? _amount.substring(0, _amount.length - 1)
            : '0';
      } else if (k == '.' && _amount.contains('.')) {
        return;
      } else {
        _amount = _amount == '0' ? k : _amount + k;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final displayCcy = settings.displayCcy;
    final isAr = lang == AppLang.ar;

    final fromWallet = walletById(_from);
    final contact = contactById(_contactId);
    final amt = double.tryParse(_amount) ?? 0;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          // Header — back · title · spacer
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
                  S.t('send_money_title', lang),
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Recipient ─────────────────────────
                  SectionLabel(S.t('to', lang)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: pal.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: pal.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: contact.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contact.initials,
                            style: sansStyle(
                              lang,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                contact.localizedName(lang),
                                style: sansStyle(
                                  lang,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: pal.text1,
                                ),
                              ),
                              Text(
                                contact.handle,
                                style: monoStyle(
                                  fontSize: 12,
                                  color: pal.text3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isAr
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          size: 20,
                          color: pal.text3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Amount display ────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                    child: Column(
                      children: [
                        Text(
                          S.t('amount', lang).toUpperCase(),
                          style: sansStyle(
                            lang,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: pal.text3,
                            letterSpacing: 0.88,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  fmtMoney(amt, fromWallet.currency, lang),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w600,
                                    color: pal.text1,
                                    letterSpacing: -0.04 * 56,
                                    height: 1,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                fromWallet.currency.code,
                                style: sansStyle(
                                  lang,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: pal.text2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '≈ ${fmtMoney(convertCcy(amt, fromWallet.currency, displayCcy), displayCcy, lang)} ${displayCcy.code}',
                          style: TextStyle(
                            fontSize: 12,
                            color: pal.text3,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── From wallet picker ────────────────
                  SectionLabel(S.t('from_wallet', lang)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (int i = 0; i < kWallets.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _WalletPicker(
                            wallet: kWallets[i],
                            lang: lang,
                            isSelected: _from == kWallets[i].id,
                            onTap: () =>
                                setState(() => _from = kWallets[i].id),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Numpad ─────────────────────────────
                  Numpad(onKey: _onKey),

                  const SizedBox(height: 20),

                  // ── Send CTA ───────────────────────────
                  YpButton(
                    label:
                        '${S.t('send', lang)} ${fmtMoney(amt, fromWallet.currency, lang)} ${fromWallet.currency.code}',
                    height: 56,
                    fullWidth: true,
                    trailing: Transform.rotate(
                      angle: isAr ? math.pi : 0,
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                      ),
                    ),
                    onPressed: amt > 0 ? widget.onSent : null,
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

/// One of the three wallet tiles under "From wallet". Lime border when
/// selected, hairline border otherwise.
class _WalletPicker extends StatelessWidget {
  final Wallet wallet;
  final AppLang lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletPicker({
    required this.wallet,
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: isSelected ? pal.bgCard : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppBrand.lime : pal.border,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              WalletLogo(wallet: wallet.id, size: 24),
              const SizedBox(height: 8),
              Text(
                wallet.localizedName(lang),
                style: sansStyle(
                  lang,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: pal.text1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                fmtMoney(wallet.balance, wallet.currency, lang),
                style: monoStyle(fontSize: 11, color: pal.text3),
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