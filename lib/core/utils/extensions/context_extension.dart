import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  // ── Theme ──────────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── MediaQuery ────────────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  // ── Navigation ────────────────────────────────────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool get canPop => Navigator.of(this).canPop();

  // ── SnackBar ──────────────────────────────────────────────────────────────
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Theme.of(this).colorScheme.error
              : Theme.of(this).colorScheme.inverseSurface,
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void showErrorSnackBar(String message) =>
      showSnackBar(message, isError: true);

  // ── Keyboard ──────────────────────────────────────────────────────────────
  void hideKeyboard() => FocusScope.of(this).unfocus();
}
