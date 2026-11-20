import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Base colors ──────────────────────────────────────────────────────────
  static const Color primary         = Color(0xFF00695C);
  static const Color primaryLight    = Color(0xFF4DB6AC);
  static const Color primaryLighter  = Color(0xFFE0F2F1);
  static const Color accent          = Color(0xFFFFD54F);

  static const Color background   = Color(0xFFF5F5F5);
  static const Color surface      = Colors.white;
  static const Color textPrimary  = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color divider      = Color(0xFFE0E0E0);
  static const Color error        = Color(0xFFD32F2F);

  // ─── Header gradient dark colors ──────────────────────────────────────────
  static const Color headerDark   = Color(0xFF004D40);
  static const Color headerMid    = Color(0xFF00695C);
  static const Color headerLight  = Color(0xFF00897B);

  // ─── Pre-computed alpha variants (avoid withValues/withOpacity in build) ──

  // primary alphas
  static const Color primary10  = Color(0x1A00695C); // 10%
  static const Color primary20  = Color(0x3300695C); // 20%
  static const Color primary30  = Color(0x4D00695C); // 30%

  // white alphas
  static const Color white10  = Color(0x1AFFFFFF);
  static const Color white15  = Color(0x26FFFFFF);
  static const Color white20  = Color(0x33FFFFFF);
  static const Color white30  = Color(0x4DFFFFFF);
  static const Color white70  = Color(0xB3FFFFFF);
  static const Color white75  = Color(0xBFFFFFFF);
  static const Color white80  = Color(0xCCFFFFFF);
  static const Color white85  = Color(0xD9FFFFFF);
  static const Color white90  = Color(0xE6FFFFFF);

  // black alphas
  static const Color black04  = Color(0x0A000000);
  static const Color black05  = Color(0x0D000000);
  static const Color black08  = Color(0x14000000);
  static const Color black20  = Color(0x33000000);
  static const Color black30  = Color(0x4D000000);

  // primaryLight alpha
  static const Color primaryLight40 = Color(0x664DB6AC); // 40%

  // ─── Decoration reuse ─────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerDark, headerMid, headerLight],
  );

  static const LinearGradient detailGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerDark, headerLight],
  );
}
