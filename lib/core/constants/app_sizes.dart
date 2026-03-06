/// Centralized sizing constants — spacing, radii, icon sizes, touch targets.
///
/// Use these instead of hardcoding numeric literals in widgets.
/// Prefer [AppSizes] over magic doubles, and use [AppSizes.touchTarget]
/// to ensure all tappable elements meet the 48dp minimum (Material).
abstract final class AppSizes {
  // ─── Border radii ──────────────────────────────────────────────────
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 30;

  // ─── Spacing ───────────────────────────────────────────────────────
  static const double spaceXxs = 4;
  static const double spaceXs = 6;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double space32 = 32;

  // ─── Icon sizes ────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 28;

  // ─── Touch targets (Material: 48dp min) ────────────────────────────
  static const double touchTarget = 48;

  // ─── HOD nav bar ───────────────────────────────────────────────────
  static const double hodNavIconSize = 24;
  static const double hodNavLabelSize = 10;

  // ─── Screen padding ────────────────────────────────────────────────
  static const double screenPaddingH = 16;
  static const double screenPaddingV = 12;

  // ─── Responsive breakpoint ─────────────────────────────────────────
  /// Tablet breakpoint — used in attendance.dart padding logic.
  static const double tabletBreakpoint = 600;
}
