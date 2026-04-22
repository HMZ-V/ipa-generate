import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All color tokens mapped 1:1 from the HSL variables in index.css.
/// Conversion formula used: HSL → RGB → Flutter Color(0xFFRRGGBB)
abstract final class AppColors {
  // ── Base ─────────────────────────────────────────────────────────────────
  /// hsl(230 60% 6%)  → Deep navy page background
  static const Color background = Color(0xFF060B1A);

  /// hsl(200 30% 96%) → Near-white text
  static const Color foreground = Color(0xFFEEF3F7);

  // ── Card / Surface ────────────────────────────────────────────────────────
  /// hsl(230 50% 9%)  → Slightly lighter than background, used for cards
  static const Color card = Color(0xFF0B1024);

  static const Color cardForeground = foreground;

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// hsl(230 40% 14%) → Chip backgrounds, secondary surfaces
  static const Color secondary = Color(0xFF16213A);

  static const Color secondaryForeground = foreground;

  /// hsl(230 35% 14%) → Subtle muted fills
  static const Color muted = Color(0xFF161F35);

  /// hsl(220 15% 65%) → Placeholder & label text
  static const Color mutedForeground = Color(0xFF939BAD);

  // ── Brand Neon Palette ────────────────────────────────────────────────────
  /// hsl(188 100% 50%) → Primary / Cyan — $STK, actions, highlights
  static const Color primary = Color(0xFF00F2FF);
  static const Color primaryForeground = Color(0xFF060B1A);

  /// hsl(188 100% 50%) — explicit alias for clarity
  static const Color cyan = Color(0xFF00F2FF);

  /// hsl(280 75% 55%)  → Accent / Violet — secondary highlights
  static const Color violet = Color(0xFF9B3DF5);
  static const Color accentForeground = Colors.white;

  /// hsl(320 95% 60%)  → Magenta — alerts, heat, competition
  static const Color magenta = Color(0xFFFF2CCF);

  /// hsl(45 100% 60%)  → Gold — VIP, Legendary, Real Mode
  static const Color gold = Color(0xFFFFCA33);

  /// hsl(145 80% 50%)  → Success / green — yields, positive delta
  static const Color success = Color(0xFF19FF7F);

  /// hsl(350 90% 60%)  → Destructive / Red — errors
  static const Color destructive = Color(0xFFF23048);

  // ── Borders / Dividers ────────────────────────────────────────────────────
  /// hsl(220 30% 18%)
  static const Color border = Color(0xFF1E2B47);

  // ── Glass border overlay ──────────────────────────────────────────────────
  /// 55% opacity border drawn on top of blur in glass cards
  static const Color glassBorder = Color(0x8C233060);
}

/// Re-usable gradient definitions, matching CSS variables in index.css.
abstract final class AppGradients {
  static const LinearGradient cyan = LinearGradient(
    colors: [Color(0xFF00F2FF), Color(0xFF00CCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violet = LinearGradient(
    colors: [Color(0xFF9B3DF5), Color(0xFFFF2CCF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFCA33), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Used as the glass card background fill
  static const LinearGradient card = LinearGradient(
    colors: [Color(0xE60D1328), Color(0xCC080B1C)],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.5, 1.0),
  );

  /// Hero background — approximated as radial shimmer; apply to Scaffold body
  static const RadialGradient heroCyan = RadialGradient(
    center: Alignment(0.0, -0.9),
    radius: 1.4,
    colors: [Color(0x2E00F2FF), Colors.transparent],
  );
}

/// Neon box-shadow equivalents as BoxShadow lists.
abstract final class AppGlows {
  static const List<BoxShadow> cyan = [
    BoxShadow(color: Color(0x7300F2FF), blurRadius: 24),
    BoxShadow(color: Color(0x2E00F2FF), blurRadius: 60),
  ];

  static const List<BoxShadow> magenta = [
    BoxShadow(color: Color(0x73FF2CCF), blurRadius: 24),
  ];

  static const List<BoxShadow> gold = [
    BoxShadow(color: Color(0x73FFCA33), blurRadius: 24),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0xCC010306),
      blurRadius: 60,
      offset: Offset(0, 20),
    ),
  ];
}

/// Border radius tokens.
abstract final class AppRadius {
  static const double sm = 8;   // calc(--radius - 4px)
  static const double md = 10;  // calc(--radius - 2px)
  static const double lg = 20;  // --radius: 1.25rem
  static const double xl = 24;  // rounded-3xl
  static const double full = 999; // rounded-full / pill
}

/// Typography — mapped to Tailwind fontFamily config.
abstract final class AppTextStyles {
  // ── Orbitron (display font) ───────────────────────────────────────────────
  static TextStyle orbitronBlack(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.orbitron(fontSize: size, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.01 * size);

  static TextStyle orbitronBold(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.orbitron(fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.01 * size);

  static TextStyle orbitronMedium(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.orbitron(fontSize: size, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.01 * size);

  // ── Inter (body / UI font) ────────────────────────────────────────────────
  static TextStyle interRegular(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w400, color: color);

  static TextStyle interMedium(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w500, color: color);

  static TextStyle interSemiBold(double size, {Color color = AppColors.foreground, double? letterSpacing}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w600, color: color, letterSpacing: letterSpacing);

  static TextStyle interBold(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w700, color: color);

  // ── JetBrains Mono (numeric / mono font) ─────────────────────────────────
  /// Use for all monetary values, counters, and percentages (.font-mono-num)
  static TextStyle jetBrainsMedium(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle jetBrainsBold(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

/// Central ThemeData. Pass to MaterialApp(theme: AppTheme.dark).
abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.violet,
        onSecondary: Colors.white,
        error: AppColors.destructive,
        surface: AppColors.card,
        onSurface: AppColors.foreground,
        outline: AppColors.border,
      ),

      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        // Display-level text (Orbitron)
        displayLarge:  AppTextStyles.orbitronBlack(36),
        displayMedium: AppTextStyles.orbitronBold(28),
        displaySmall:  AppTextStyles.orbitronBold(22),
        headlineMedium:AppTextStyles.orbitronMedium(18),

        // Body (Inter — already set by base TextTheme)
        bodyLarge:   AppTextStyles.interRegular(16),
        bodyMedium:  AppTextStyles.interRegular(14),
        bodySmall:   AppTextStyles.interRegular(12),
        labelLarge:  AppTextStyles.interSemiBold(14),
        labelMedium: AppTextStyles.interSemiBold(12),
        labelSmall:  AppTextStyles.interSemiBold(10),
      ),

      dividerColor: AppColors.border,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
