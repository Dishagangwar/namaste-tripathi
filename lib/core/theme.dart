import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens: pale yellow surfaces over white cards, with a deep gold
/// for anything interactive.
///
/// Pale yellow can only ever be a surface. As a button fill it leaves white
/// label text at roughly 1.2:1, which is illegible, so the brand colours are
/// darkened until white sits on them safely -- `primary` lands at 5.9:1 on
/// white and `primaryLight` at 4.9:1, both clearing WCAG AA for body text.
/// The yellow the eye actually reads as the theme comes from `scaffold` and
/// `tintSurface`.
class AppColors {
  static const primary = Color(0xFF8A5A00);
  static const primaryDark = Color(0xFF5E3D00);
  static const primaryLight = Color(0xFFA16207);
  static const tintSurface = Color(0xFFFDF3D1);

  static const scaffold = Color(0xFFFFFBEF);
  static const surface = Colors.white;
  static const border = Color(0xFFEDE3C6);

  static const text = Color(0xFF1F1A0E);
  static const muted = Color(0xFF6F6652);
  static const faint = Color(0xFFA2987E);

  static const star = Color(0xFFF5A524);
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFD9F7E3);
  static const danger = Color(0xFFDC2626);
  static const veg = Color(0xFF16A34A);
  static const nonVeg = Color(0xFFDC2626);
}

class AppRadius {
  static const card = 18.0;
  static const chip = 30.0;
  static const button = 14.0;
  static const sheet = 26.0;
}

final List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: const Color(0xFF3A2A05).withValues(alpha: 0.07),
    blurRadius: 18,
    offset: const Offset(0, 6),
  ),
];

final List<BoxShadow> kLiftShadow = [
  BoxShadow(
    color: const Color(0xFF3A2A05).withValues(alpha: 0.14),
    blurRadius: 26,
    offset: const Offset(0, 10),
  ),
];

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.scaffold,
  );

  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.scaffold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.text),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: AppColors.primary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.faint),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
  );
}

/// Indian rupee formatting used all over the reference app.
String rupees(num value, {bool decimals = false}) {
  final s = decimals ? value.toStringAsFixed(2) : value.round().toString();
  final parts = s.split('.');
  var intPart = parts[0];
  final neg = intPart.startsWith('-');
  if (neg) intPart = intPart.substring(1);

  String grouped;
  if (intPart.length <= 3) {
    grouped = intPart;
  } else {
    final last3 = intPart.substring(intPart.length - 3);
    var rest = intPart.substring(0, intPart.length - 3);
    final buf = <String>[];
    while (rest.length > 2) {
      buf.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.insert(0, rest);
    grouped = '${buf.join(',')},$last3';
  }
  final tail = parts.length > 1 ? '.${parts[1]}' : '';
  return '${neg ? '-' : ''}₹$grouped$tail';
}
