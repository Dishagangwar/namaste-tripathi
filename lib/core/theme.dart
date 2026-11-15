import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens taken from the reference recording.
class AppColors {
  static const primary = Color(0xFF0B4EA2);
  static const primaryDark = Color(0xFF08386F);
  static const primaryLight = Color(0xFF2F80ED);
  static const tintSurface = Color(0xFFE8F0FC);

  static const scaffold = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const border = Color(0xFFE6EAF0);

  static const text = Color(0xFF14181F);
  static const muted = Color(0xFF6B7280);
  static const faint = Color(0xFF9CA3AF);

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
    color: const Color(0xFF0B1F3A).withValues(alpha: 0.06),
    blurRadius: 18,
    offset: const Offset(0, 6),
  ),
];

final List<BoxShadow> kLiftShadow = [
  BoxShadow(
    color: const Color(0xFF0B1F3A).withValues(alpha: 0.12),
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
