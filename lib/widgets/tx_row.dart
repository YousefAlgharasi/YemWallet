import 'package:flutter/material.dart';

import '../data/currency.dart';
import '../data/transaction.dart';
import '../data/wallet.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

/// Single row in the transaction list. Type-specific icon + tinted background,
/// localized label/sub, signed amount with optional strikethrough for failed.
class TxRow extends StatelessWidget {
  final Transaction tx;
  final AppLang lang;
  final DisplayCurrency displayCcy;
  final bool isLast;

  const TxRow({
    super.key,
    required this.tx,
    required this.lang,
    required this.displayCcy,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final cfg = _configFor(tx, pal);
    final isFailed = tx.status == TxStatus.failed;
    final amountStr = _amountString();
    final amountColor = cfg.sign == '+' ? AppBrand.success : pal.text1;

    return Opacity(
      opacity: isFailed ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: pal.border, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cfg.bgColor,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Icon(cfg.icon, size: 18, color: cfg.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: pal.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sub(),
                    style: TextStyle(fontSize: 11.5, color: pal.text3),
                  ),
                ],
              ),
            ),
            if (amountStr != null) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cfg.sign}$amountStr',
                    style: monoStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                    ).copyWith(
                      decoration:
                          isFailed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    _amountSubtitle(),
                    style: TextStyle(fontSize: 10.5, color: pal.text3),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label() {
    return switch (tx) {
      SplitOutTx t => t.merchant,
      CheckoutTx t => t.merchant,
      TransferInTx t => t.from,
      TransferOutTx t => t.to,
      WalletLinkTx _ => S.t('wallet_linked', lang),
    };
  }

  String _sub() {
    final time = tx.time;
    return switch (tx) {
      SplitOutTx t =>
        '${t.wallets.length} ${S.t('wallets', lang)} · $time',
      WalletLinkTx t => '${_walletName(t.wallet)}  ·  $time',
      CheckoutTx t when t.wallets.isNotEmpty =>
        '${_walletName(t.wallets.first.wallet)}  ·  $time',
      TransferInTx t => '${_walletName(t.wallet)}  ·  $time',
      TransferOutTx t => '${_walletName(t.wallet)}  ·  $time',
      _ => time,
    };
  }

  String _walletName(WalletId id) => walletById(id).localizedName(lang);

  String? _amountString() {
    if (tx is WalletLinkTx) return null;
    if (tx.amountYer == 0) return null;
    final converted =
        convertCcy(tx.amountYer, DisplayCurrency.yer, displayCcy);
    return fmtMoney(converted, displayCcy, lang);
  }

  String _amountSubtitle() {
    final base = displayCcy.code;
    return switch (tx.status) {
      TxStatus.pending => '$base · ${S.t('pending', lang)}',
      TxStatus.failed => '$base · ${S.t('failed', lang)}',
      TxStatus.done => base,
    };
  }

  _TxRowConfig _configFor(Transaction t, AppPalette pal) {
    return switch (t) {
      SplitOutTx _ => _TxRowConfig(
          icon: Icons.alt_route_rounded,
          iconColor: AppBrand.lime,
          bgColor: AppBrand.lime.withOpacity(0.1),
          sign: '−',
        ),
      TransferInTx _ => _TxRowConfig(
          icon: Icons.south_west_rounded,
          iconColor: AppBrand.success,
          bgColor: AppBrand.success.withOpacity(0.1),
          sign: '+',
        ),
      TransferOutTx _ => _TxRowConfig(
          icon: Icons.north_east_rounded,
          iconColor: AppBrand.danger,
          bgColor: AppBrand.danger.withOpacity(0.1),
          sign: '−',
        ),
      CheckoutTx _ => _TxRowConfig(
          icon: Icons.storefront_outlined,
          iconColor: pal.text1,
          bgColor: pal.bg2,
          sign: '−',
        ),
      WalletLinkTx _ => _TxRowConfig(
          icon: Icons.link_rounded,
          iconColor: pal.text1,
          bgColor: pal.bg2,
          sign: '',
        ),
    };
  }
}

class _TxRowConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String sign;
  const _TxRowConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.sign,
  });
}