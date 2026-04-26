import 'package:flutter/material.dart';

import '../data/wallet.dart';
import '../theme/app_theme.dart';

/// 18px-tall stacked allocation bar. Each wallet contributes a stripe
/// proportional to (alloc / target), in its brand color. Unallocated
/// space falls through to the bg-3 track underneath.
class SplitBar extends StatelessWidget {
  final Map<WalletId, double> allocs;
  final double target;

  const SplitBar({
    super.key,
    required this.allocs,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          double cumulative = 0;
          final stripes = <Widget>[];

          for (final w in kWallets) {
            final alloc = allocs[w.id] ?? 0;
            if (target <= 0 || alloc <= 0) continue;
            final pct = (alloc / target).clamp(0.0, 1.0);
            // Clamp so cumulative width never exceeds the bar.
            final stripeWidth =
                (width * pct).clamp(0.0, width - cumulative);
            if (stripeWidth < 0.5) continue;
            stripes.add(
              SizedBox(
                width: stripeWidth,
                height: 18,
                child: ColoredBox(color: w.brandColor),
              ),
            );
            cumulative += stripeWidth;
            if (cumulative >= width) break;
          }

          return Container(
            width: width,
            height: 18,
            color: pal.bg3,
            child: Row(children: stripes),
          );
        },
      ),
    );
  }
}