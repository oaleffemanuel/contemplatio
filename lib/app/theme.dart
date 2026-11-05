import 'package:flutter/material.dart';

/// Lumen design tokens: a night palette, aged gold and ivory, with one
/// accent per set of mysteries. Art is the hero; chrome stays quiet.
/// Colors of one theme, as in Biblia Traditio (dark and light).
final class LumenPalette {
  const LumenPalette({
    required this.brightness,
    required this.ink,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.ivory,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.gold,
  });

  final Brightness brightness;
  final Color ink, surface, surfaceHigh, line, ivory, muted, faint;
  final Color accent, accentSoft, gold;

  static const dark = LumenPalette(
    brightness: Brightness.dark,
    ink: Color(0xFF0B0B0C),
    surface: Color(0xFF161617),
    surfaceHigh: Color(0xFF222224),
    line: Color(0xFF26262A),
    ivory: Color(0xFFEDE9E3),
    muted: Color(0xFF9A9A9E),
    faint: Color(0xFF65656A),
    accent: Color(0xFFC2492E),
    accentSoft: Color(0x33C2492E),
    gold: Color(0xFFD4A72C),
  );

  static const light = LumenPalette(
    brightness: Brightness.light,
    ink: Color(0xFFF6F2EA), // warm ivory canvas
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFEDE7DB),
    line: Color(0xFFE2DACD),
    ivory: Color(0xFF1C1A17), // primary text
    muted: Color(0xFF5C574E),
    faint: Color(0xFF8A8377),
    accent: Color(0xFFB23E22),
    accentSoft: Color(0x22B23E22),
    gold: Color(0xFFA8821A),
  );

  /// The palette in use; set by [LumenApp] before each rebuild.
  static LumenPalette current = dark;
}

/// Same visual language as Biblia Traditio: canvas, graphite (or white)
/// surfaces, sacral terracotta accent, illuminated-manuscript gold, EB
/// Garamond for prayer and titles, Inter for chrome. Names keep their dark
/// meaning (`ink` = canvas, `ivory` = primary text) in both themes.
abstract final class LumenColors {
  static LumenPalette get _p => LumenPalette.current;
  static Color get ink => _p.ink;
  static Color get surface => _p.surface;
  static Color get surfaceHigh => _p.surfaceHigh;
  static Color get line => _p.line;
  static Color get ivory => _p.ivory;
  static Color get muted => _p.muted;
  static Color get faint => _p.faint;
  static Color get accent => _p.accent;
  static Color get accentSoft => _p.accentSoft;
  static Color get gold => _p.gold;

  // Over paintings the scene is always dark, in both themes.
  static const imageInk = Color(0xFF0B0B0C);
  static const onImage = Color(0xFFF3EBDD);
  static const heroStart = Color(0xFF5B2419);
  static const heroEnd = Color(0xFF2B1511);
  static const onHeroMuted = Color(0xFFC9B8A6);

  /// Liturgical tone of each set, used over paintings (always dark).
  static Color accentFor(String setId) => switch (setId) {
    'joyful' => const Color(0xFFEDE9E3),
    'luminous' => const Color(0xFFD4A72C),
    'sorrowful' || 'passion' => const Color(0xFFD0563B),
    'glorious' => const Color(0xFFF1E2B8),
    _ => const Color(0xFFC2492E),
  };
}

abstract final class LumenType {
  static const serif = 'EB Garamond';
  static const ui = 'Inter';

  /// Small caps label above titles ("HOJE · QUINTA-FEIRA").
  static TextStyle eyebrow(Color color) => TextStyle(
    fontFamily: ui,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: color,
  );

  static TextStyle title(double size, {Color? color}) => TextStyle(
    fontFamily: serif,
    fontWeight: FontWeight.w600,
    fontSize: size,
    height: 1.1,
    letterSpacing: 0.2,
    color: color ?? LumenColors.ivory,
  );

  static TextStyle body(double scale, {Color? color}) => TextStyle(
    fontFamily: serif,
    fontSize: 19 * scale,
    height: 1.55,
    color: color ?? LumenColors.ivory,
  );

  /// Jaculatória over a painting (always light text).
  static TextStyle meditation(double scale, {Color? color}) => TextStyle(
    fontFamily: serif,
    fontStyle: FontStyle.italic,
    fontSize: 22 * scale,
    height: 1.35,
    color: color ?? LumenColors.onImage,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: ui,
    fontSize: 13,
    height: 1.35,
    color: LumenColors.muted,
  );

  /// Caption over a painting.
  static const imageCaption = TextStyle(
    fontFamily: ui,
    fontSize: 12,
    height: 1.35,
    color: LumenColors.onHeroMuted,
  );

  static TextStyle get cardTitle => TextStyle(
    fontFamily: ui,
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    color: LumenColors.ivory,
  );

  /// Section label, as in Biblia Traditio ("VIA SACRA").
  static TextStyle get section => TextStyle(
    fontFamily: ui,
    fontSize: 12,
    letterSpacing: 1,
    fontWeight: FontWeight.w600,
    color: LumenColors.faint,
  );
}

ThemeData buildLumenTheme() {
  final p = LumenPalette.current;
  final dark = p.brightness == Brightness.dark;
  return ThemeData(
    brightness: p.brightness,
    useMaterial3: true,
    fontFamily: LumenType.ui,
    scaffoldBackgroundColor: p.ink,
    canvasColor: p.ink,
    colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
          primary: p.accent,
          onPrimary: Colors.white,
          secondary: p.accent,
          surface: p.surface,
          onSurface: p.ivory,
        ),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: p.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: p.ivory,
      titleTextStyle: TextStyle(
        fontFamily: LumenType.ui,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: p.ivory,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      thumbColor: p.accent,
      inactiveTrackColor: p.surfaceHigh,
      overlayColor: p.accentSoft,
    ),
    dividerTheme: DividerThemeData(color: p.line, space: 1),
  );
}
