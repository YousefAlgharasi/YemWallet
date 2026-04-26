import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Backspace glyph used as a key. The original prototype uses this same
/// unicode character rendered in mono font.
const String kBackspaceKey = '⌫';

enum NumpadStyle {
  /// Used in the Send screen — flat buttons, no border, tight gaps.
  transparent,

  /// Used in the Checkout PIN screen — bg-card tiles with hairline borders.
  card,
}

/// 3-column numeric keypad. The parent owns the value/PIN string and
/// reacts to each tap via [onKey] (which receives '0'-'9', '.' or [kBackspaceKey]).
class Numpad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final NumpadStyle style;

  /// When false, the dot key is omitted (used by PIN entry).
  final bool showDecimal;

  const Numpad({
    super.key,
    required this.onKey,
    this.style = NumpadStyle.transparent,
    this.showDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    final keys = showDecimal
        ? const ['1','2','3','4','5','6','7','8','9','.','0', kBackspaceKey]
        : const ['1','2','3','4','5','6','7','8','9','', '0', kBackspaceKey];

    final isCard = style == NumpadStyle.card;
    final gap = isCard ? 6.0 : 4.0;

    // Split the flat key list into rows of 3.
    final rows = <List<String>>[];
    for (int i = 0; i < keys.length; i += 3) {
      rows.add(keys.sublist(i, i + 3));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: gap),
          Row(
            children: [
              for (int c = 0; c < 3; c++) ...[
                if (c > 0) SizedBox(width: gap),
                Expanded(
                  child: rows[r][c].isEmpty
                      ? const SizedBox.shrink()
                      : _NumpadKey(
                          label: rows[r][c],
                          isCard: isCard,
                          onTap: () => onKey(rows[r][c]),
                        ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final bool isCard;
  final VoidCallback onTap;

  const _NumpadKey({
    required this.label,
    required this.isCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final padY = isCard ? 18.0 : 14.0;
    final radius = BorderRadius.circular(isCard ? 14 : 10);

    final inner = Padding(
      padding: EdgeInsets.symmetric(vertical: padY),
      child: Center(
        child: Text(
          label,
          style: monoStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: pal.text1,
          ),
        ),
      ),
    );

    if (isCard) {
      return Material(
        color: pal.bgCard,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: inner,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: inner,
      ),
    );
  }
}