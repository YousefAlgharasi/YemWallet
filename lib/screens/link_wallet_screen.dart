import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/yp_button.dart';
import '../widgets/yp_status_bar.dart';

/// Onboarding step 2/3 — pick which wallets to link.
/// Defaults match the prototype: Jaib + Alkuraimi pre-selected,
/// One Cash unselected.
class LinkWalletScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const LinkWalletScreen({super.key, this.onBack, this.onContinue});

  @override
  State<LinkWalletScreen> createState() => _LinkWalletScreenState();
}

class _LinkWalletScreenState extends State<LinkWalletScreen> {
  final Map<WalletId, bool> _linked = {
    WalletId.jaib: true,
    WalletId.alkuraimi: true,
    WalletId.onecash: false,
  };

  static const Map<WalletId, String> _descKeys = {
    WalletId.jaib: 'desc_jaib',
    WalletId.alkuraimi: 'desc_alkuraimi',
    WalletId.onecash: 'desc_onecash',
  };

  void _toggle(WalletId id) {
    setState(() => _linked[id] = !(_linked[id] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;
    final linkedCount = _linked.values.where((v) => v).length;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          // Header bar — back · "2 / 3" · skip
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
                  '2 / 3',
                  style: monoStyle(fontSize: 12, color: pal.text3),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: pal.text2,
                    textStyle: sansStyle(lang, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(S.t('skip', lang)),
                ),
              ],
            ),
          ),

          // Title, description, wallet list, permission banner
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.t('link_title', lang),
                    style: sansStyle(
                      lang,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: pal.text1,
                      letterSpacing: -0.03 * 28,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.t('link_sub', lang),
                    style: sansStyle(
                      lang,
                      fontSize: 15,
                      color: pal.text2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Wallet options
                  for (int i = 0; i < kWallets.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _WalletOption(
                      wallet: kWallets[i],
                      lang: lang,
                      desc: S.t(_descKeys[kWallets[i].id]!, lang),
                      isLinked: _linked[kWallets[i].id] ?? false,
                      onTap: () => _toggle(kWallets[i].id),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Permission info banner — lime-tinted
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppBrand.lime.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppBrand.lime.withOpacity(0.18),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppBrand.lime,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.t('link_perm', lang),
                            style: sansStyle(
                              lang,
                              fontSize: 12,
                              color: pal.text2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA — disabled when zero wallets selected
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: YpButton(
              label: _continueLabel(lang, linkedCount),
              height: 56,
              fullWidth: true,
              disabled: linkedCount == 0,
              onPressed: widget.onContinue,
            ),
          ),
        ],
      ),
    );
  }

  String _continueLabel(AppLang lang, int n) {
    if (lang == AppLang.ar) {
      return S.t('continue_with_n', lang, vars: {'n': '$n'});
    }
    final plural = n == 1 ? '' : 's';
    return S.t('continue_with_n', lang, vars: {'n': '$n', 's': plural});
  }
}

class _WalletOption extends StatelessWidget {
  final Wallet wallet;
  final AppLang lang;
  final String desc;
  final bool isLinked;
  final VoidCallback onTap;

  const _WalletOption({
    required this.wallet,
    required this.lang,
    required this.desc,
    required this.isLinked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: isLinked ? pal.bgCard : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLinked ? AppBrand.lime : pal.border,
              width: isLinked ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              WalletLogo(wallet: wallet.id, size: 42),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: pal.text1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: sansStyle(
                        lang,
                        fontSize: 12,
                        color: pal.text3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Check indicator
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLinked ? AppBrand.lime : Colors.transparent,
                  border: isLinked
                      ? null
                      : Border.all(color: pal.borderStrong, width: 1.5),
                ),
                child: isLinked
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: pal.textOnLime,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}