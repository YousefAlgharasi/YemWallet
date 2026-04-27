import 'package:flutter/material.dart';

import '../../state/app_settings.dart';
import '../../theme/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/icon_btn_box.dart';
import '../../widgets/yp_logo.dart';
import '../../widgets/yp_status_bar.dart';

/// The four steps in the merchant-hosted checkout flow.
/// Other files in `lib/screens/checkout/` import this enum from here.
enum CheckoutStep {
  landing,
  split,
  pin,
  success;

  /// Position in the 3-segment progress bar. Success doesn't show one.
  int get progressIndex => switch (this) {
        CheckoutStep.landing => 0,
        CheckoutStep.split => 1,
        CheckoutStep.pin => 2,
        CheckoutStep.success => 2,
      };
}

/// Shared header for the checkout flow (landing, split, pin steps).
/// Renders status bar, back button, "Secure payment by YemenPay" badge,
/// lock icon, and a 3-segment progress indicator.
class CheckoutHeader extends StatelessWidget {
  final CheckoutStep step;
  final AppLang lang;
  final VoidCallback? onBack;

  const CheckoutHeader({
    super.key,
    required this.step,
    required this.lang,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final isAr = lang == AppLang.ar;
    final activeIdx = step.progressIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const YpStatusBar(),

        // Back · "Secure payment by YemenPay" · lock
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBtnBox(
                size: 36,
                onTap: onBack,
                child: Icon(
                  isAr
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 16,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const YpLogo(size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: sansStyle(
                            lang,
                            fontSize: 12,
                            color: pal.text2,
                          ),
                          children: [
                            TextSpan(text: '${S.t('secure_by', lang)} '),
                            TextSpan(
                              text: 'YemenPay',
                              style: sansStyle(
                                lang,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pal.text1,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: pal.text3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3-segment progress bar — lime for completed, bg-3 for upcoming
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= activeIdx ? AppBrand.lime : pal.bg3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}