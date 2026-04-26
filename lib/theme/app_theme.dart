import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_settings.dart';

/// Brand & semantic color tokens. Same in light and dark.
class AppBrand {
  static const lime = Color(0xFFD4FF3A);
  static const limeDim = Color(0xFFB8E028);
  static const limeSoft = Color(0xFFE8FF7A);

  static const success = Color(0xFF5FDBA0);
  static const warning = Color(0xFFFFB84D);
  static const danger = Color(0xFFFF6B6B);

  // Wallet brand colors
  static const jaib = Color(0xFFFF7A45);
  static const alkuraimi = Color(0xFF4D8AFF);
  static const onecash = Color(0xFFB39DFF);
}

/// Theme-dependent surface + text tokens. Exposed via [ThemeExtension].
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg0;
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color bgCard;
  final Color border;
  final Color borderStrong;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color textOnLime;

  const AppPalette({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bgCard,
    required this.border,
    required this.borderStrong,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.textOnLime,
  });

  static const dark = AppPalette(
    bg0: Color(0xFF0A0A0A),
    bg1: Color(0xFF131313),
    bg2: Color(0xFF1A1A1A),
    bg3: Color(0xFF232323),
    bgCard: Color(0xFF161616),
    border: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
    borderStrong: Color(0x24FFFFFF), // rgba(255,255,255,0.14)
    text1: Color(0xFFF5F5F3),
    text2: Color(0xFFA8A8A3),
    text3: Color(0xFF6E6E69),
    textOnLime: Color(0xFF0A0A0A),
  );

  static const light = AppPalette(
    bg0: Color(0xFFF4F1EA),
    bg1: Color(0xFFEBE7DD),
    bg2: Color(0xFFFFFFFF),
    bg3: Color(0xFFF8F5EE),
    bgCard: Color(0xFFFFFFFF),
    border: Color(0x14141412), // rgba(20,20,18,0.08)
    borderStrong: Color(0x29141412), // rgba(20,20,18,0.16)
    text1: Color(0xFF14140F),
    text2: Color(0xFF595950),
    text3: Color(0xFF8A8A7E),
    textOnLime: Color(0xFF0A0A0A),
  );

  @override
  AppPalette copyWith({
    Color? bg0,
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? bgCard,
    Color? border,
    Color? borderStrong,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? textOnLime,
  }) {
    return AppPalette(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      bgCard: bgCard ?? this.bgCard,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      textOnLime: textOnLime ?? this.textOnLime,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      textOnLime: Color.lerp(textOnLime, other.textOnLime, t)!,
    );
  }
}

/// Density tokens — multiplies vertical sizes (button heights, paddings).
class AppDensity extends ThemeExtension<AppDensity> {
  final double factor;
  const AppDensity({required this.factor});

  @override
  AppDensity copyWith({double? factor}) =>
      AppDensity(factor: factor ?? this.factor);

  @override
  AppDensity lerp(ThemeExtension<AppDensity>? other, double t) {
    if (other is! AppDensity) return this;
    return AppDensity(factor: factor + (other.factor - factor) * t);
  }
}

/// Convenience accessors.
extension AppThemeX on BuildContext {
  AppPalette get pal => Theme.of(this).extension<AppPalette>()!;
  double get densityY =>
      Theme.of(this).extension<AppDensity>()?.factor ?? 1.0;
}

/// Builds the [TextTheme] for sans + Arabic + density.
TextTheme _buildTextTheme(AppPalette palette, AppLang lang) {
  final base = lang == AppLang.ar
      ? GoogleFonts.ibmPlexSansArabicTextTheme()
      : GoogleFonts.geistTextTheme();
  return base.apply(
    bodyColor: palette.text1,
    displayColor: palette.text1,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData dark(AppSettings s) => _build(AppPalette.dark, s);
  static ThemeData light(AppSettings s) => _build(AppPalette.light, s);

  static ThemeData _build(AppPalette palette, AppSettings s) {
    final brightness = palette == AppPalette.dark
        ? Brightness.dark
        : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppBrand.lime,
      brightness: brightness,
      primary: AppBrand.lime,
      onPrimary: palette.textOnLime,
      surface: palette.bg0,
      onSurface: palette.text1,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.bg0,
      canvasColor: palette.bg0,
      textTheme: _buildTextTheme(palette, s.lang),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: palette.border,
      extensions: [
        palette,
        AppDensity(factor: s.density.factor),
      ],
    );
  }
}

/// Mono font helper — used for tabular numbers throughout the app.
TextStyle monoStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
}) {
  return GoogleFonts.geistMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing ?? -0.02 * (fontSize ?? 14),
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Sans font helper — auto-switches to Arabic when needed.
TextStyle sansStyle(
  AppLang lang, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  if (lang == AppLang.ar) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
  return GoogleFonts.geist(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing ?? -0.01 * (fontSize ?? 14),
    height: height,
  );
}