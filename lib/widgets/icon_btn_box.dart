import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 38×38 rounded square button used for header chrome (QR, settings,
/// search, back). Uses the bg-2 surface with a hairline border.
///
/// Pass [size] = 36 for back-buttons that sit on screens (the screens use
/// 36px instead of the default 38px in the prototype).
class IconBtnBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;

  const IconBtnBox({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: pal.bg2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pal.border, width: 0.5),
          ),
          child: IconTheme(
            data: IconThemeData(color: pal.text1, size: 20),
            child: child,
          ),
        ),
      ),
    );
  }
}