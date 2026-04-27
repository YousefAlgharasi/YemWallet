import 'package:intl/intl.dart';

import '../state/app_settings.dart';
import 'wallet.dart';

/// Hardcoded FX rates from the spec — values are YER per 1 unit of currency.
const Map<DisplayCurrency, double> kRates = {
  DisplayCurrency.yer: 1,
  DisplayCurrency.sar: 140,
  DisplayCurrency.usd: 530,
};

/// Convert [amount] from currency [from] to currency [to].
double convertCcy(double amount, DisplayCurrency from, DisplayCurrency to) {
  if (from == to) return amount;
  final yer = amount * kRates[from]!;
  return yer / kRates[to]!;
}

/// Localized money formatter — YER has 0 fraction digits, SAR/USD up to 2.
/// Mirrors the prototype's `fmtMoney` (Intl.NumberFormat with ar-EG / en-US).
String fmtMoney(double amount, DisplayCurrency currency, AppLang lang) {
  final locale = lang == AppLang.ar ? 'ar' : 'en_US';
  final maxDigits = currency == DisplayCurrency.yer ? 0 : 2;
  const minDigits = 0;
  final fmt = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = maxDigits
    ..minimumFractionDigits = minDigits;
  // Round to 2dp before formatting, matching the JS impl.
  final rounded = (amount * 100).round() / 100;
  return fmt.format(rounded);
}

/// Combined balance across all wallets, expressed in [displayCcy].
double totalIn(DisplayCurrency displayCcy) {
  return kWallets.fold<double>(
    0,
    (sum, w) => sum + convertCcy(w.balance, w.currency, displayCcy),
  );
}