import 'package:flutter/material.dart';

/// Centralized text styles used across the application.
///
/// These are base styles — always compose with `copyWith` when you need
/// a one-off colour or size override, rather than defining a new constant.
abstract final class AppTextStyles {
  // ─── Headings ──────────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ─── Body ──────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(fontSize: 14);

  static const TextStyle bodySmall = TextStyle(fontSize: 13);

  // ─── Labels / captions ─────────────────────────────────────────────
  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // ─── HOD-specific dark-theme styles ────────────────────────────────
  /// White heading used inside HOD dark screens.
  static const TextStyle hodScreenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Subdued label colour for HOD nav items.
  static const TextStyle hodNavLabel = TextStyle(
    fontSize: 10,
    letterSpacing: 0.5,
  );
}
