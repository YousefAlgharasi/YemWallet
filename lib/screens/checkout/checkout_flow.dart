import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/currency.dart';
import '../../data/wallet.dart';
import '../../state/app_settings.dart';
import '../../theme/app_theme.dart';
import 'checkout_header.dart';
import 'checkout_landing.dart';
import 'checkout_pin.dart';
import 'checkout_split.dart';
import 'checkout_success.dart';

/// Stateful orchestrator for the merchant-hosted checkout. Owns step,
/// mode, single-wallet selection, and split allocations. Flow:
///   landing → (split if mode=split) → pin → success
/// Back navigates to the previous step; back from landing fires [onExit].
class CheckoutFlow extends StatefulWidget {
  final CheckoutOrder order;
  final VoidCallback onExit;

  const CheckoutFlow({
    super.key,
    this.order = kDefaultOrder,
    required this.onExit,
  });

  @override
  State<CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends State<CheckoutFlow> {
  CheckoutStep _step = CheckoutStep.landing;
  PaymentMode _mode = PaymentMode.single;
  WalletId _singleWallet = WalletId.jaib;
  Map<WalletId, double>? _allocs;

  /// Same auto-split heuristic as the prototype's CheckoutFlow:
  /// drain USD up to 50% of its balance, then SAR, then top up with YER.
  Map<WalletId, double> _suggestedSplit() {
    var remaining = widget.order.total;
    final out = <WalletId, double>{};
    const order = [
      WalletId.onecash,
      WalletId.alkuraimi,
      WalletId.jaib,
    ];
    for (final id in order) {
      final w = walletById(id);
      final maxYer = convertCcy(w.balance, w.currency, DisplayCurrency.yer);
      final use = id == WalletId.onecash
          ? math.min(remaining, maxYer * 0.5)
          : math.min(remaining, maxYer);
      out[id] = use;
      remaining -= use;
    }
    return out;
  }

  void _onModeChange(PaymentMode m) {
    setState(() {
      _mode = m;
      if (m == PaymentMode.split && _allocs == null) {
        _allocs = _suggestedSplit();
      }
    });
  }

  void _setAlloc(WalletId id, double val) {
    final w = walletById(id);
    final max = convertCcy(w.balance, w.currency, DisplayCurrency.yer);
    setState(() {
      final next = Map<WalletId, double>.from(_allocs ?? {});
      next[id] = val.clamp(0.0, max);
      _allocs = next;
    });
  }

  void _onBack() {
    switch (_step) {
      case CheckoutStep.landing:
        widget.onExit();
      case CheckoutStep.split:
        setState(() => _step = CheckoutStep.landing);
      case CheckoutStep.pin:
        setState(() => _step = _mode == PaymentMode.split
            ? CheckoutStep.split
            : CheckoutStep.landing);
      case CheckoutStep.success:
        // No back from success.
        break;
    }
  }

  void _onLandingContinue() {
    setState(() {
      _step = _mode == PaymentMode.split
          ? CheckoutStep.split
          : CheckoutStep.pin;
    });
  }

  void _onSplitContinue() {
    setState(() => _step = CheckoutStep.pin);
  }

  void _onPinComplete() {
    setState(() => _step = CheckoutStep.success);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final variant = settings.splitVariant;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header is shown for all steps except success
          if (_step != CheckoutStep.success)
            CheckoutHeader(
              step: _step,
              lang: lang,
              onBack: _onBack,
            ),

          // Step body
          Expanded(
            child: switch (_step) {
              CheckoutStep.landing => CheckoutLanding(
                  order: widget.order,
                  mode: _mode,
                  onModeChange: _onModeChange,
                  singleWallet: _singleWallet,
                  onSingleWalletChange: (id) =>
                      setState(() => _singleWallet = id),
                  onContinue: _onLandingContinue,
                ),
              CheckoutStep.split => CheckoutSplit(
                  order: widget.order,
                  allocs: _allocs ?? _suggestedSplit(),
                  onAllocChange: _setAlloc,
                  variant: variant,
                  onContinue: _onSplitContinue,
                ),
              CheckoutStep.pin => CheckoutPin(
                  order: widget.order,
                  onComplete: _onPinComplete,
                ),
              CheckoutStep.success => CheckoutSuccess(
                  order: widget.order,
                  mode: _mode,
                  singleWallet: _singleWallet,
                  allocs: _allocs ?? const {},
                  onDone: widget.onExit,
                ),
            },
          ),
        ],
      ),
    );
  }
}