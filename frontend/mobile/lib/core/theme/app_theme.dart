import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Single source of truth for the entire visual system.
/// The industrial "Operational Workspace" aesthetic is enforced here
/// so individual screens never need to define their own style overrides.
final class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      fontFamily: 'IBMPlexSans',
      scaffoldBackgroundColor: AppColors.concreteGray,
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
    );

    return base.copyWith(
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      chipTheme: _chipTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      textTheme: _textTheme,
      inputDecorationTheme: _inputDecorationTheme,
      iconTheme: const IconThemeData(color: AppColors.operationalBlue, size: 22),
    );
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.operationalBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1A3550),
    onPrimaryContainer: Colors.white,
    secondary: AppColors.safetyOrange,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE5C4),
    onSecondaryContainer: Color(0xFF7A3D00),
    tertiary: AppColors.priorityNormal,
    onTertiary: Colors.white,
    error: AppColors.priorityCritical,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.concreteGray,
    outline: AppColors.divider,
    outlineVariant: Color(0xFFD1D5DB),
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.operationalBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: AppColors.divider, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.safetyOrange,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.divider,
      disabledForegroundColor: AppColors.onSurfaceMuted,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.operationalBlue,
      side: const BorderSide(color: AppColors.operationalBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.operationalBlue,
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    labelStyle: const TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.operationalBlue,
    unselectedItemColor: AppColors.onSurfaceMuted,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    headlineMedium: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    headlineSmall: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    titleMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleSmall: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    bodyLarge: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.onSurface),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
    bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceMuted),
    labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        letterSpacing: 0.3),
    labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceMuted,
        letterSpacing: 0.8),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.operationalBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:
          const BorderSide(color: AppColors.priorityCritical, width: 1.5),
    ),
    hintStyle: const TextStyle(
      fontFamily: 'IBMPlexSans',
      color: AppColors.onSurfaceMuted,
      fontSize: 14,
    ),
  );

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get dark {
    const darkSurface = Color(0xFF1E2530);
    const darkBackground = Color(0xFF141A22);
    const darkCard = Color(0xFF252D3A);
    const darkDivider = Color(0xFF2E3847);
    const darkOnSurface = Color(0xFFE2E8F0);
    const darkOnSurfaceMuted = Color(0xFF8A9AB0);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.operationalBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1A3550),
        onPrimaryContainer: Colors.white,
        secondary: AppColors.safetyOrange,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF4A2500),
        onSecondaryContainer: Color(0xFFFFDDB3),
        tertiary: AppColors.priorityNormal,
        onTertiary: Colors.white,
        error: AppColors.priorityCritical,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkBackground,
        outline: darkDivider,
        outlineVariant: Color(0xFF374151),
      ),
      fontFamily: 'IBMPlexSans',
      scaffoldBackgroundColor: darkBackground,
      dividerColor: darkDivider,
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 0,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A2230),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: darkDivider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: darkDivider,
          disabledForegroundColor: darkOnSurfaceMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.operationalBlue,
          side: const BorderSide(color: AppColors.operationalBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.operationalBlue,
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A2230),
        selectedItemColor: AppColors.operationalBlue,
        unselectedItemColor: darkOnSurfaceMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.operationalBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.priorityCritical, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: darkOnSurfaceMuted,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: darkOnSurfaceMuted,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.operationalBlue, size: 22),
    );
  }
}
