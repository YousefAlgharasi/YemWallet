import 'package:flutter/material.dart';

import '../state/app_settings.dart';
import '../theme/app_theme.dart';

enum WalletId { jaib, alkuraimi, onecash }

enum WalletPermission { withdraw, viewOnly }

class Wallet {
  final WalletId id;
  final String name;
  final String nameAr;
  final double balance;
  final DisplayCurrency currency;
  final WalletPermission permission;
  final bool defaultSend;
  final bool defaultReceive;
  final String number;

  const Wallet({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.balance,
    required this.currency,
    required this.permission,
    required this.defaultSend,
    required this.defaultReceive,
    required this.number,
  });

  String localizedName(AppLang lang) => lang == AppLang.ar ? nameAr : name;

  /// Letter shown inside the brand-colored tile (J / K / 1).
  String get logoGlyph => switch (id) {
        WalletId.jaib => 'J',
        WalletId.alkuraimi => 'K',
        WalletId.onecash => '1',
      };

  /// Brand color of the wallet tile.
  Color get brandColor => switch (id) {
        WalletId.jaib => AppBrand.jaib,
        WalletId.alkuraimi => AppBrand.alkuraimi,
        WalletId.onecash => AppBrand.onecash,
      };
}

/// Seed wallets — same numbers as the prototype.
const kWallets = <Wallet>[
  Wallet(
    id: WalletId.jaib,
    name: 'Jaib',
    nameAr: 'جيب',
    balance: 80000,
    currency: DisplayCurrency.yer,
    permission: WalletPermission.withdraw,
    defaultSend: false,
    defaultReceive: true,
    number: '••• 4419',
  ),
  Wallet(
    id: WalletId.alkuraimi,
    name: 'Alkuraimi',
    nameAr: 'الكريمي',
    balance: 500,
    currency: DisplayCurrency.sar,
    permission: WalletPermission.withdraw,
    defaultSend: true,
    defaultReceive: false,
    number: '••• 8821',
  ),
  Wallet(
    id: WalletId.onecash,
    name: 'One Cash',
    nameAr: 'ون كاش',
    balance: 100,
    currency: DisplayCurrency.usd,
    permission: WalletPermission.viewOnly,
    defaultSend: false,
    defaultReceive: false,
    number: '••• 1037',
  ),
];

Wallet walletById(WalletId id) => kWallets.firstWhere((w) => w.id == id);