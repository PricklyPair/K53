import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get primaryTextColor => Theme.of(this).colorScheme.onTertiary;

  /// TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;

  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;
}
