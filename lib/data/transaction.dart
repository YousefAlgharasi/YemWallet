import '../state/app_settings.dart';
import 'wallet.dart';

enum TxStatus { done, pending, failed }

/// One leg of a split or checkout payment.
class WalletAmount {
  final WalletId wallet;
  final double amount;
  final DisplayCurrency currency;
  const WalletAmount(this.wallet, this.amount, this.currency);
}

/// Sealed base class — render code can `switch` exhaustively over subtypes.
sealed class Transaction {
  final String id;
  final String date; // ISO yyyy-mm-dd
  final String time; // HH:MM
  final TxStatus status;

  const Transaction({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
  });

  /// Total amount in YER. Wallet-link rows return 0.
  double get amountYer;
}

class SplitOutTx extends Transaction {
  final String merchant;
  final List<WalletAmount> wallets;
  @override
  final double amountYer;

  const SplitOutTx({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required this.merchant,
    required this.amountYer,
    required this.wallets,
  });
}

class CheckoutTx extends Transaction {
  final String merchant;
  final List<WalletAmount> wallets;
  @override
  final double amountYer;

  const CheckoutTx({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required this.merchant,
    required this.amountYer,
    required this.wallets,
  });
}

class TransferInTx extends Transaction {
  final String from;
  @override
  final double amountYer;
  final WalletId wallet;
  final DisplayCurrency ccy;

  const TransferInTx({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required this.from,
    required this.amountYer,
    required this.wallet,
    required this.ccy,
  });
}

class TransferOutTx extends Transaction {
  final String to;
  @override
  final double amountYer;
  final WalletId wallet;
  final DisplayCurrency ccy;

  const TransferOutTx({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required this.to,
    required this.amountYer,
    required this.wallet,
    required this.ccy,
  });
}

class WalletLinkTx extends Transaction {
  final WalletId wallet;

  const WalletLinkTx({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required this.wallet,
  });

  @override
  double get amountYer => 0;
}

/// Mock transaction history — same rows the prototype seeds.
const kTransactions = <Transaction>[
  SplitOutTx(
    id: 't1',
    date: '2026-04-26',
    time: '14:22',
    status: TxStatus.done,
    merchant: 'Mokha Coffee Roasters',
    amountYer: 32000,
    wallets: [
      WalletAmount(WalletId.jaib, 12000, DisplayCurrency.yer),
      WalletAmount(WalletId.alkuraimi, 80, DisplayCurrency.sar),
      WalletAmount(WalletId.onecash, 17, DisplayCurrency.usd),
    ],
  ),
  TransferInTx(
    id: 't2',
    date: '2026-04-26',
    time: '11:08',
    status: TxStatus.done,
    from: 'Ahmed Al-Sabri',
    amountYer: 50000,
    wallet: WalletId.jaib,
    ccy: DisplayCurrency.yer,
  ),
  CheckoutTx(
    id: 't3',
    date: '2026-04-25',
    time: '19:44',
    status: TxStatus.done,
    merchant: 'Sanaa Online Pharmacy',
    amountYer: 18900,
    wallets: [
      WalletAmount(WalletId.alkuraimi, 135, DisplayCurrency.sar),
    ],
  ),
  TransferOutTx(
    id: 't4',
    date: '2026-04-25',
    time: '16:00',
    status: TxStatus.done,
    to: 'Layla Mahmoud',
    amountYer: 15000,
    wallet: WalletId.jaib,
    ccy: DisplayCurrency.yer,
  ),
  WalletLinkTx(
    id: 't5',
    date: '2026-04-25',
    time: '09:12',
    status: TxStatus.done,
    wallet: WalletId.onecash,
  ),
  SplitOutTx(
    id: 't6',
    date: '2026-04-24',
    time: '21:38',
    status: TxStatus.done,
    merchant: 'Aden Threads Boutique',
    amountYer: 95000,
    wallets: [
      WalletAmount(WalletId.jaib, 60000, DisplayCurrency.yer),
      WalletAmount(WalletId.onecash, 66, DisplayCurrency.usd),
    ],
  ),
  TransferInTx(
    id: 't7',
    date: '2026-04-24',
    time: '13:05',
    status: TxStatus.done,
    from: 'Salim Tahir',
    amountYer: 22500,
    wallet: WalletId.alkuraimi,
    ccy: DisplayCurrency.sar,
  ),
  CheckoutTx(
    id: 't8',
    date: '2026-04-23',
    time: '20:11',
    status: TxStatus.done,
    merchant: 'Hadhramaut Honey Co.',
    amountYer: 8400,
    wallets: [
      WalletAmount(WalletId.jaib, 8400, DisplayCurrency.yer),
    ],
  ),
  TransferOutTx(
    id: 't9',
    date: '2026-04-23',
    time: '10:30',
    status: TxStatus.pending,
    to: 'Nadia Al-Hakimi',
    amountYer: 5300,
    wallet: WalletId.jaib,
    ccy: DisplayCurrency.yer,
  ),
  TransferOutTx(
    id: 't10',
    date: '2026-04-22',
    time: '17:55',
    status: TxStatus.failed,
    to: 'Khalid Maktum',
    amountYer: 12000,
    wallet: WalletId.jaib,
    ccy: DisplayCurrency.yer,
  ),
];