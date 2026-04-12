import 'package:flutter/material.dart';

/// Palet warna aplikasi Durian Classifier.
///
/// Identitas visual: warna durian (kuning-emas) + hijau tropis + putih bersih.
abstract class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  /// Warna utama — kuning-emas durian.
  static const primary      = Color(0xFFE5A020);
  static const primaryLight = Color(0xFFF5C842);
  static const primaryDark  = Color(0xFFB87D10);

  /// Warna sekunder — hijau daun tropis.
  static const secondary      = Color(0xFF2D7A3C);
  static const secondaryLight = Color(0xFF4CAF61);
  static const secondaryDark  = Color(0xFF1B5728);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const white      = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8F5EE);  // krem hangat
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2EDE3);

  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5A5A5A);
  static const textHint      = Color(0xFF9E9E9E);
  static const divider       = Color(0xFFE0D9CE);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const success      = Color(0xFF2E7D32);
  static const successLight = Color(0xFFE8F5E9);

  static const error        = Color(0xFFB71C1C);
  static const errorLight   = Color(0xFFFFEBEE);

  static const warning      = Color(0xFFF57F17);
  static const warningLight = Color(0xFFFFF8E1);

  static const info         = Color(0xFF1565C0);
  static const infoLight    = Color(0xFFE3F2FD);

  // ── Prediction Status ─────────────────────────────────────────────────────
  static const statusPending = Color(0xFFF57F17);  // amber
  static const statusSuccess = Color(0xFF2E7D32);  // green
  static const statusFailed  = Color(0xFFB71C1C);  // red

  // ── AI Status ─────────────────────────────────────────────────────────────
  static const aiOnline  = Color(0xFF2E7D32);
  static const aiOffline = Color(0xFFB71C1C);

  // ── Confidence Score Gradient ─────────────────────────────────────────────
  /// Gradient warna gauge confidence: merah (rendah) → kuning → hijau (tinggi)
  static const confidenceLow    = Color(0xFFE53935);  // < 0.5
  static const confidenceMedium = Color(0xFFFFB300);  // 0.5 – 0.8
  static const confidenceHigh   = Color(0xFF43A047);  // > 0.8

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF121212);
  static const darkSurface    = Color(0xFF1E1E1E);
  static const darkSurfaceAlt = Color(0xFF2A2A2A);
}
