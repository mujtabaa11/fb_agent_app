// Agent Mate — Official Color Palette
// DO NOT use hex values directly in widgets. Always reference AppColors.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── PRIMARY ──────────────────────────────────────
  static const Color primary        = Color(0xFF1565C0);
  static const Color primaryDark    = Color(0xFF0D47A1);
  static const Color primaryLight   = Color(0xFF1976D2);
  static const Color primarySurface = Color(0xFFE3F0FF);
  static const Color onPrimary      = Color(0xFFFFFFFF);

  // ── SURFACES — LIGHT MODE ─────────────────────────
  static const Color background     = Color(0xFFF8FAFC);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceAlt     = Color(0xFFF1F5F9);

  // ── SURFACES — DARK MODE ──────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark    = Color(0xFF1E293B);
  static const Color surfaceAltDark = Color(0xFF293548);

  // ── TEXT ─────────────────────────────────────────
  static const Color textPrimary       = Color(0xFF1E293B);
  static const Color textSecondary     = Color(0xFF64748B);
  static const Color textHint          = Color(0xFF94A3B8);
  static const Color textPrimaryDark   = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ── SEMANTIC ─────────────────────────────────────
  static const Color success            = Color(0xFF10B981);
  static const Color successSurface     = Color(0xFFD1FAE5);
  static const Color successDark        = Color(0xFF34D399);
  static const Color successSurfaceDark = Color(0xFF064E3B);

  static const Color warning            = Color(0xFFF59E0B);
  static const Color warningSurface     = Color(0xFFFEF3C7);
  static const Color warningDark        = Color(0xFFFBBF24);
  static const Color warningSurfaceDark = Color(0xFF451A03);

  static const Color error              = Color(0xFFEF4444);
  static const Color errorSurface       = Color(0xFFFEE2E2);
  static const Color errorDark          = Color(0xFFF87171);
  static const Color errorSurfaceDark   = Color(0xFF450A0A);

  // ── BORDERS ──────────────────────────────────────
  static const Color border          = Color(0xFFE2E8F0);
  static const Color borderStrong    = Color(0xFFCBD5E1);
  static const Color borderDark      = Color(0xFF334155);
  static const Color borderStrongDark = Color(0xFF475569);
}
