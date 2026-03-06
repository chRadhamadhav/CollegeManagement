import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
///
/// Group colors by feature palette so a design-system update touches
/// only this file. Add new colors here — never inline them in widgets.
abstract final class AppColors {
  // ─── HOD dark palette ──────────────────────────────────────────────
  /// Primary dark background used by all HOD screens.
  static const Color hodBackground = Color(0xFF0B0D14);

  /// Slightly lighter surface / card background in HOD screens.
  static const Color hodSurface = Color(0xFF151B2B);

  /// Bottom nav bar background in HOD.
  static const Color hodNavBackground = Color(0xFF101420);

  /// Bottom nav bar top border in HOD.
  static const Color hodNavBorder = Color(0xFF1E2040);

  /// Active icon/label colour in HOD bottom nav.
  static const Color hodNavActive = Color(0xFF4DB6FF);

  /// Primary accent blue used for CTAs and highlights in HOD.
  static const Color hodAccentBlue = Color(0xFF3A7AFF);

  /// Secondary accent / teal used for stats and tag borders.
  static const Color hodAccentTeal = Color(0xFF4DB6FF);

  /// Card/input border colour in HOD dark theme.
  static const Color hodBorder = Color(0xFF1E2A40);

  /// Darker input background inside dialogs / exam cards.
  static const Color hodInputBackground = Color(0xFF0D121F);

  // ─── Admin palette ─────────────────────────────────────────────────
  /// Admin sidebar / drawer background.
  static const Color adminDrawerBackground = Color(0xFF0B1220);

  /// Accent blue used for active drawer items and buttons.
  static const Color adminAccentBlue = Color(0xFF3E80FF);

  // ─── Student palette ───────────────────────────────────────────────
  /// Gradient start — student info card.
  static const Color studentGradientStart = Color(0xFF0061FF);

  /// Gradient end — student info card.
  static const Color studentGradientEnd = Color(0xFF60EFFF);

  /// Standard blue accent across student screens.
  static const Color studentAccentBlue = Color(0xFF2F80ED);

  // ─── Login palette ─────────────────────────────────────────────────
  static const Color loginDarkBackground = Color(0xFF0E1A2B);
  static const Color loginAccentBlue = Color(0xFF137FEC);

  // ─── Semantic / shared ─────────────────────────────────────────────
  static const Color success = Colors.greenAccent;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orange;
}
