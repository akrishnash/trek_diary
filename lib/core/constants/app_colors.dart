import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const accent      = Color(0xFF5B8A6E); // sage green — used sparingly
  static const accentLight = Color(0xFF7EC8A0);

  // ── Dark surfaces (match auth screen palette exactly) ─────────────────────
  static const sheet       = Color(0xFF1A1F1C); // main content sheet — dark charcoal
  static const surface     = Color(0xFF252B28); // cards, inputs — slightly lighter
  static const surfaceDim  = Color(0xFF1E2420); // dimmer variant — stepper disabled etc.
  static const border      = Color(0xFF3A4240); // field/card borders
  static const borderLight = Color(0xFF2E3530); // dividers, subtle separators

  // ── Text on dark surfaces ─────────────────────────────────────────────────
  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFF8A9590); // muted sage — subtitles, descriptions
  static const textMuted     = Color(0xFF6A7570); // more muted — body small, labels
  static const textHint      = Color(0xFF5A6560); // most subtle — placeholder, section eyebrows

  // ── Text on dark photo (always white at varying opacity) ──────────────────
  static const onPhoto          = Colors.white;
  static const onPhotoMid       = Color(0xB3FFFFFF); // 70%
  static const onPhotoDim       = Color(0x73FFFFFF); // 45%
  static const onPhotoSubtle    = Color(0x4DFFFFFF); // 30%

  // ── Frosted glass surfaces (TIDE-style) ───────────────────────────────────
  static const glassDarkBg     = Color(0x55000000);
  static const glassDarkBorder = Color(0x33FFFFFF);
  static const glassLightBg     = Color(0x26FFFFFF);
  static const glassLightBorder = Color(0x33FFFFFF);
  static const pillWhite        = Colors.white;
  static const pillWhiteText    = Color(0xFF1A1917);

  // ── Dark hero background ──────────────────────────────────────────────────
  static const heroDark = Color(0xFF0D1A0D);

  // ── Difficulty ────────────────────────────────────────────────────────────
  static const diffEasy        = Color(0xFF4A9B6E);
  static const diffModerate    = Color(0xFFC17F3E);
  static const diffChallenging = Color(0xFFC4524A);
  static const diffExpert      = Color(0xFF8B4FB8);

  // ── Trek path nodes ───────────────────────────────────────────────────────
  static const nodeLogged  = Color(0xFF5B8A6E);
  static const nodeCurrent = Color(0xFFC8A040);
  static const nodeLocked  = Color(0xFF3A4240);
}
