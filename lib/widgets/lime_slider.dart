import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 4px-tall slider with a lime active track and a white circular thumb
/// outlined in lime. Inherits RTL flipping from the ambient [Directionality]
/// (Flutter's [Slider] already mirrors active/inactive sides for RTL).
class LimeSlider extends StatelessWidget {
  final double value;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  const LimeSlider({
    super.key,
    required this.value,
    required this.max,
    this.step = 100,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final hasRange = max > 0;
    final clamped = value.clamp(0.0, hasRange ? max : 1.0);
    final divisions =
        hasRange ? (max / step).round().clamp(1, 10000) : null;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: AppBrand.lime,
          inactiveTrackColor: pal.bg3,
          trackShape: const RoundedRectSliderTrackShape(),
          thumbShape: const _LimeThumbShape(),
          overlayShape: SliderComponentShape.noOverlay,
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Slider(
          value: clamped,
          min: 0,
          max: hasRange ? max : 1,
          divisions: divisions,
          onChanged: hasRange ? onChanged : null,
        ),
      ),
    );
  }
}

class _LimeThumbShape extends SliderComponentShape {
  static const double _radius = 9; // 18px diameter

  const _LimeThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Drop shadow under the thumb (matches box-shadow: 0 2px 6px rgba(0,0,0,.3))
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: _radius));
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 2, true);

    // White fill
    canvas.drawCircle(center, _radius, Paint()..color = Colors.white);

    // 2px lime border (drawn at radius - 1 so the stroke sits inside the disc)
    canvas.drawCircle(
      center,
      _radius - 1,
      Paint()
        ..color = AppBrand.lime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}