import 'package:flutter/material.dart';

/// A singleton controller responsible for managing the application's theme mode.
/// Uses a [ValueNotifier] so that listeners (e.g., the root [MaterialApp])
/// can rebuild when the theme changes without requiring a full state-management package.
class ThemeController {
  ThemeController._();

  /// The single shared instance across the app.
  static final ThemeController instance = ThemeController._();

  /// Notifies listeners whenever the theme mode changes.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  /// Exposes the notifier so the root [MaterialApp] can consume it:
  /// ```dart
  /// ValueListenableBuilder(
  ///   valueListenable: ThemeController.instance.themeNotifier,
  ///   builder: (_, mode, __) => MaterialApp(themeMode: mode, ...),
  /// );
  /// ```
  ValueNotifier<ThemeMode> get themeNotifier => _themeMode;

  /// Returns `true` if the resolved brightness in [context] is dark.
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark].
  /// If the current mode is [ThemeMode.system], it toggles based on the [context]'s current brightness.
  void toggleTheme([BuildContext? context]) {
    if (context != null && _themeMode.value == ThemeMode.system) {
      _themeMode.value = isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode.value = _themeMode.value == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }
  }

  /// Explicitly set a [ThemeMode].
  void setTheme(ThemeMode mode) => _themeMode.value = mode;
}
