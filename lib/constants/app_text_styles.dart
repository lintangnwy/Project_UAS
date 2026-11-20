import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Static styles (const) ────────────────────────────────────────────────
  static const TextStyle headline1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const TextStyle headline2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const TextStyle headline3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static const TextStyle body1 = TextStyle(
    fontSize: 15, fontWeight: FontWeight.normal,
    color: AppColors.textPrimary, height: 1.6);

  static const TextStyle body2 = TextStyle(
    fontSize: 13, color: AppColors.textSecondary);

  static const TextStyle surahTitle = TextStyle(
    fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const TextStyle surahSubtitle = TextStyle(
    fontSize: 13, color: AppColors.textSecondary);

  static const TextStyle caption = TextStyle(
    fontSize: 12, color: AppColors.textSecondary);

  static const TextStyle button = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary);

  // ─── Amiri (Arabic) — cached as static final, created once ───────────────

  /// Arabic text, primary color — for surah names in lists
  static final TextStyle arabicText = GoogleFonts.amiri(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary);

  /// Arabic text, large — for ayat content
  static final TextStyle arabicLarge = GoogleFonts.amiri(
    fontSize: 26, height: 2.2, fontWeight: FontWeight.w500,
    color: const Color(0xFF1A1A1A));

  /// Arabic text white, header size — for surah name in detail header
  static final TextStyle arabicHeaderWhite = GoogleFonts.amiri(
    fontSize: 38, color: Colors.white,
    fontWeight: FontWeight.bold, height: 1.3);

  /// Arabic text white, bismillah size
  static final TextStyle arabicBismillah = GoogleFonts.amiri(
    fontSize: 15, color: AppColors.white90);

  /// Arabic text white, home hero size
  static final TextStyle arabicHomeHero = GoogleFonts.amiri(
    fontSize: 20, color: AppColors.white85, height: 1.5);

  /// Arabic text white, last-read card size
  static final TextStyle arabicLastRead = GoogleFonts.amiri(
    fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold);

  /// Arabic text white, riwayat card size
  static final TextStyle arabicRiwayat = GoogleFonts.amiri(
    fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold);

  /// Arabic text white, bookmark list size
  static final TextStyle arabicBookmark = GoogleFonts.amiri(
    fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary);

  // ─── Keep backward-compat getter for old call sites ──────────────────────
  /// @deprecated — use arabicBismillah or specific cached style instead
  static TextStyle arabicWhite({double fontSize = 18}) => GoogleFonts.amiri(
    fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.w500);
}
