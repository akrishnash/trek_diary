import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TIDE-inspired type scale.
///
/// Pattern: ultra-thin display text on dark photography, medium-weight body
/// text on the light content sheet. Stark weight contrast is the signature.
class AppTextStyles {
  AppTextStyles._();

  // ── Display — on dark photo backgrounds ──────────────────────────────────

  /// App name: "TREK DIARY" — thin tracked uppercase, centred on hero photo.
  /// Mirrors TIDE's own wordmark treatment.
  static TextStyle get appName => GoogleFonts.poppins(
    fontSize: 38,
    fontWeight: FontWeight.w200,
    color: AppColors.onPhoto,
    letterSpacing: 10,
    height: 1.0,
  );

  /// Section / screen display heading on photo (e.g. "New Trek", trek name).
  static TextStyle get heroHeading => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: AppColors.onPhoto,
    letterSpacing: 1.5,
    height: 1.1,
  );

  /// Large decorative stat number — TIDE date "07" style, ultra-thin.
  static TextStyle get displayNumber => GoogleFonts.poppins(
    fontSize: 64,
    fontWeight: FontWeight.w100,
    color: AppColors.onPhoto,
    letterSpacing: -2,
    height: 1.0,
  );

  /// Eyebrow label above the hero heading — e.g. "TREK DIARY", "DAY 3".
  static TextStyle get eyebrow => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.onPhotoDim,
    letterSpacing: 4,
    height: 1.0,
  );

  /// Supporting subtitle on photo (dimmer, smaller).
  static TextStyle get heroSubtitle => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: AppColors.onPhotoDim,
    letterSpacing: 0.3,
    height: 1.5,
  );

  // ── Sheet / light surface text ────────────────────────────────────────────

  /// Screen title on the white/warm sheet (e.g. "Settings", "Add Stop").
  static TextStyle get screenTitle => GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Card / list item primary label.
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Trek card title on dark photo overlay.
  static TextStyle get cardTitleOnPhoto => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.onPhoto,
    letterSpacing: 0.1,
    height: 1.2,
  );

  /// Section label — all-caps, tight tracking, muted.
  static TextStyle get sectionLabel => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.textHint,
    letterSpacing: 1.0,
    height: 1.0,
  );

  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.1,
  );

  /// Stat value inside the StatCard — bold, large.
  static TextStyle get statValue => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Tab bar label.
  static TextStyle get tabLabel => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────

  /// Label inside the solid white pill CTA (TIDE "Start" / "Continue with…").
  static TextStyle get pillPrimary => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.pillWhiteText,
    letterSpacing: 0.1,
  );

  /// Label inside dark frosted-glass secondary button.
  static TextStyle get pillSecondary => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onPhoto,
    letterSpacing: 0.1,
  );

  /// Small glass action button on photo header (e.g. "Path", "Stats").
  static TextStyle get glassAction => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.onPhoto,
  );
}
