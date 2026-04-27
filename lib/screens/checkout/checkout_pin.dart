import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/currency.dart';
import '../../state/app_settings.dart';
import '../../theme/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/numpad.dart';
import 'checkout_landing.dart' show CheckoutOrder;

/// Step 3 — 4-digit wallet PIN entry. Auto-advances 600ms after the
/// 4th digit is entered. The "Use Touch ID" fallback fills "1234"
/// and triggers the same auto-advance.
class CheckoutPin extends StatefulWidget {
  final CheckoutOrder order;
  final VoidCallback onComplete;

  const CheckoutPin({
    super.key,
    required this.order,
    required this.onComplete,
  });

  @override
  State<CheckoutPin> createState() => _CheckoutPinState();
}

class _CheckoutPinState extends State<CheckoutPin> {
  String _pin = '';
  Timer? _completeTimer;

  @override
  void dispose() {
    _completeTimer?.cancel();
    super.dispose();
  }

  void _scheduleComplete() {
    _completeTimer?.cancel();
    _completeTimer = Timer(
      const Duration(milliseconds: 600),
      widget.onComplete,
    );
  }

  void _onKey(String k) {
    setState(() {
      if (k == kBackspaceKey) {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
        return;
      }
      if (_pin.length >= 4) return;
      _pin = _pin + k;
    });
    if (_pin.length == 4) _scheduleComplete();
  }

  void _useTouchId() {
    setState(() => _pin = '1234');
    _scheduleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;
    final isAr = lang == AppLang.ar;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lock icon decoration
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(top: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pal.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 28,
              color: AppBrand.lime,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            S.t('enter_pin', lang),
            style: sansStyle(
              lang,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: pal.text1,
              letterSpacing: -0.02 * 22,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle: "To confirm <amount> YER to\n<merchant>"
          Text.rich(
            TextSpan(
              style: sansStyle(
                lang,
                fontSize: 13,
                color: pal.text2,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: isAr
                      ? '${S.t('to_confirm', lang)} ${fmtMoney(widget.order.total, DisplayCurrency.yer, lang)} YER إلى\n'
                      : '${S.t('to_confirm', lang)} ${fmtMoney(widget.order.total, DisplayCurrency.yer, lang)} YER to\n',
                ),
                TextSpan(
                  text: widget.order.localizedMerchant(lang),
                  style: sansStyle(
                    lang,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: pal.text1,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i < _pin.length ? AppBrand.lime : Colors.transparent,
                    border: i < _pin.length
                        ? null
                        : Border.all(color: pal.borderStrong, width: 1.5),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),

          // Card-style numpad, no decimal point
          Numpad(
            onKey: _onKey,
            style: NumpadStyle.card,
            showDecimal: false,
          ),

          const SizedBox(height: 18),

          // Touch ID fallback (auto-fills 1234)
          TextButton(
            onPressed: _useTouchId,
            style: TextButton.styleFrom(
              foregroundColor: pal.text3,
              textStyle: sansStyle(lang, fontSize: 12),
            ),
            child: Text(S.t('use_touch_id', lang)),
          ),
        ],
      ),
    );
  }
}