import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/yp_button.dart';
import '../widgets/yp_status_bar.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  WalletId _selected = WalletId.jaib;
  bool _copied = false;

  Wallet get _wallet => walletById(_selected);

  void _copy() {
    Clipboard.setData(ClipboardData(text: _wallet.number));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final isAr = context.watch<AppSettings>().lang == AppLang.ar;

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
              children: [
                IconBtnBox(
                  size: 36,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    isAr
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isAr ? 'استلام الأموال' : 'Receive Money',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text1,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // QR code placeholder
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: pal.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppBrand.lime.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppBrand.lime.withOpacity(0.08),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // QR grid visual hint
                          Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              size: 180,
                              color: pal.text1,
                            ),
                          ),
                          // Wallet logo overlay
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: pal.bg0,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: WalletLogo(wallet: _selected, size: 36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Wallet name + address
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _wallet.localizedName(
                              context.read<AppSettings>().lang),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: pal.text1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _wallet.number,
                          style: TextStyle(
                            fontSize: 14,
                            color: pal.text3,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Wallet picker
                  Text(
                    isAr
                        ? 'اختر المحفظة'.toUpperCase()
                        : 'RECEIVE INTO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: pal.text3,
                      letterSpacing: 0.66,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (int i = 0; i < kWallets.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _WalletChip(
                            wallet: kWallets[i],
                            isSelected: _selected == kWallets[i].id,
                            onTap: () =>
                                setState(() => _selected = kWallets[i].id),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Copy address
                  YpButton(
                    label: _copied
                        ? (isAr ? '✓ تم النسخ' : '✓ Copied')
                        : (isAr ? 'نسخ العنوان' : 'Copy address'),
                    height: 56,
                    fullWidth: true,
                    onPressed: _copy,
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

class _WalletChip extends StatelessWidget {
  final Wallet wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletChip({
    required this.wallet,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              WalletLogo(wallet: wallet.id, size: 28),
              const SizedBox(height: 6),
              Text(
                wallet.currency.code,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppBrand.lime : pal.text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
