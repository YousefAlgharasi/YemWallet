import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_settings.dart';
import '../theme/app_theme.dart';

enum YpButtonVariant {
  /// Lime fill, dark text — the default CTA.
  primary,

  /// bg-2 fill with hairline border — secondary actions.
  ghost,

  /// Dark fill with light text — used on light backgrounds for contrast.
  dark,
}

/// Pill-shaped button matching the prototype's `.yp-btn` styles.
/// Default height scales with density (48 × densityY); pass [height]
/// to override (the screens use 56 for full-width CTAs).
class YpButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final YpButtonVariant variant;
  final Widget? trailing;
  final Widget? leading;
  final double? height;
  final bool fullWidth;
  final bool disabled;

  const YpButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = YpButtonVariant.primary,
    this.trailing,
    this.leading,
    this.height,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final density = context.densityY;
    final lang = context.watch<AppSettings>().lang;
    final h = height ?? 48 * density;
    final isEnabled = !disabled && onPressed != null;

    final (bg, fg, border) = switch (variant) {
      YpButtonVariant.primary => (AppBrand.lime, pal.textOnLime, null),
      YpButtonVariant.ghost => (
          pal.bg2,
          pal.text1,
          Border.all(color: pal.border, width: 0.5),
        ),
      YpButtonVariant.dark => (
          const Color(0xFF14140F),
          const Color(0xFFF5F5F3),
          null,
        ),
    };

    final radius = BorderRadius.circular(999);

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: 18),
            child: leading!,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: sansStyle(
              lang,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.15,
              height: 1,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          IconTheme(
            data: IconThemeData(color: fg, size: 18),
            child: trailing!,
          ),
        ],
      ],
    );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: SizedBox(
        height: h,
        width: fullWidth ? double.infinity : null,
        child: Material(
          color: bg,
          borderRadius: radius,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: radius,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}