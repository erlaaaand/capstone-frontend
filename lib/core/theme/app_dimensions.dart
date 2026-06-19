import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppDimensions {
  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static double get md => 16.w;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusXs  = 4.0;
  static const double radiusSm  = 8.0;
  static double get radiusMd => 12.r;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 24.0;
  static const double radiusFull = 999.0; // pill

  // ── Icon Size ─────────────────────────────────────────────────────────────
  static const double iconSm  = 16.0;
  static const double iconMd  = 24.0;
  static const double iconLg  = 32.0;
  static const double iconXl  = 48.0;
  static const double iconXxl = 64.0;

  // ── Button ────────────────────────────────────────────────────────────────
  static double get buttonHeight => 52.h;
  static const double buttonHeightSm     = 40.0;
  static const double buttonMinWidth     = 120.0;

  // ── Input Field ───────────────────────────────────────────────────────────
  static const double inputHeight        = 56.0;

  // ── AppBar ────────────────────────────────────────────────────────────────
  static const double appBarHeight       = 56.0;

  // ── Card ──────────────────────────────────────────────────────────────────
  static const double cardElevation      = 2.0;

  // ── Page Padding ──────────────────────────────────────────────────────────
  static const double pagePaddingH       = 20.0;
  static const double pagePaddingV       = 24.0;

  // ── Image Preview ─────────────────────────────────────────────────────────
  static const double imagePreviewHeight = 280.0;

  // ── Confidence Gauge ──────────────────────────────────────────────────────
  static const double gaugeSize          = 160.0;
  static const double gaugeStrokeWidth   = 14.0;

}
