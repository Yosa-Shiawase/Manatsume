import 'package:flutter/material.dart';

class ManatsumeTheme {
  static const _bg = Color(0xFF0B0A0F);
  static const _surface = Color(0xFF1A1722);
  static const _surface2 = Color(0xFF241F33);
  static const _border = Color(0x0DFFFFFF);
  static const _text = Color(0xFFF3F6FC);
  static const _muted = Color(0xFF9AA6C0);
  static const _mutedSoft = Color(0xFF75829C);
  static const _accent = Color(0xFFF5C26B);
  static const _accent2 = Color(0xFFC75B26);
  static const _moon = Color(0xFFE0E6FF);
  static const _foxFur = Color(0xFFF2E2C4);
  static const _foxEar = Color(0xFFC75B26);
  static const _foxEye = Color(0xFF3A2A18);

  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);

  static ThemeData _build(bool dark) {
    final isDark = dark;
    final surface = isDark ? _surface : Colors.white;
    final surface2 = isDark ? _surface2 : Colors.grey.shade50;
    final border = isDark ? _border : Colors.grey.shade200;
    final text = isDark ? _text : Colors.black;
    final muted = isDark ? _muted : Colors.grey.shade600;
    final mutedSoft = isDark ? _mutedSoft : Colors.grey.shade500;
    final accent = _accent;
    final accent2 = _accent2;
    final moon = _moon;
    final foxFur = _foxFur;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? _bg : const Color(0xFFF7F5F2),
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: accent,
        onPrimary: isDark ? _bg : Colors.black,
        primaryContainer: isDark ? _surface2 : const Color(0xFFF3E7D3),
        onPrimaryContainer: isDark ? _text : const Color(0xFF3A2A18),
        secondary: accent2,
        onSecondary: Colors.white,
        secondaryContainer: isDark ? _surface2 : const Color(0xFFFCEBDA),
        onSecondaryContainer: isDark ? _text : const Color(0xFF3A2A18),
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: surface2,
        onSurfaceVariant: isDark ? muted : Colors.grey.shade800,
        outline: border,
        outlineVariant: isDark ? _border : Colors.grey.shade300,
        shadow: Colors.black,
        error: Colors.red.shade700,
        onError: Colors.white,
        errorContainer: Colors.red.shade100,
        onErrorContainer: Colors.red.shade700,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          color: text,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: text,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: text,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.125,
          color: text,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.125,
          color: text,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.125,
          color: text,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.125,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.125,
          color: text,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.125,
          color: text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.125,
          color: text,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: text,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.125,
          color: text,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
          color: muted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: mutedSoft,
        ),
      ),
      iconTheme: IconThemeData(
        color: muted,
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        iconTheme: IconThemeData(color: muted),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: mutedSoft),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x0F000000),
        thickness: 0.5,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: isDark ? _surface2 : Colors.grey.shade300,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: TextStyle(color: text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A1722),
        surfaceTintColor: Color(0xFFF5C26B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: isDark ? _bg : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.125,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.125,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.125,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: isDark ? _bg : Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        labelStyle: TextStyle(color: text),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withOpacity(0.35),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: muted, size: 24);
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withOpacity(0.3),
        selectionHandleColor: accent,
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: muted,
        selectedColor: accent,
        fillColor: surface2,
        borderColor: border,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
