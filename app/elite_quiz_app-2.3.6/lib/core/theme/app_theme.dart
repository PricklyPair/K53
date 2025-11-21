import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

final appThemeData = <Brightness, ThemeData>{
  Brightness.light: ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    canvasColor: klCanvasColor,
    fontFamily: kFonts.fontFamily,
    primaryColor: klPrimaryColor,
    primaryTextTheme: kTextTheme,
    cupertinoOverrideTheme: _cupertinoOverrideTheme,
    scaffoldBackgroundColor: klPageBackgroundColor,
    dialogTheme: _dialogThemeData,
    shadowColor: klPrimaryColor.withValues(alpha: 0.25),
    dividerTheme: _dividerThemeData,
    textTheme: kTextTheme,
    textButtonTheme: _textButtonTheme,
    tabBarTheme: _tabBarTheme,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll<Color>(klPrimaryTextColor),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: klPrimaryColor).copyWith(
      surface: klBackgroundColor,
      onTertiary: klPrimaryTextColor,
      surfaceTint: Colors.transparent,
    ),
  ),
  Brightness.dark: ThemeData(
    useMaterial3: true,
    primaryTextTheme: kTextTheme,
    textTheme: kTextTheme,
    fontFamily: kFonts.fontFamily,
    shadowColor: kdPrimaryColor.withValues(alpha: 0.25),
    brightness: Brightness.dark,
    primaryColor: kdPrimaryColor,
    scaffoldBackgroundColor: kdPageBackgroundColor,
    dialogTheme: _dialogThemeData.copyWith(
      backgroundColor: kdPageBackgroundColor,
      surfaceTintColor: kdPageBackgroundColor,
      titleTextStyle: _dialogThemeData.titleTextStyle?.copyWith(
        color: kdPrimaryTextColor,
      ),
      contentTextStyle: _dialogThemeData.contentTextStyle?.copyWith(
        color: kdPrimaryTextColor,
      ),
    ),
    canvasColor: kdCanvasColor,
    tabBarTheme: _tabBarTheme.copyWith(
      unselectedLabelColor: Colors.grey[400],
      labelColor: kdCanvasColor,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: klPrimaryColor,
      ),
    ),
    textButtonTheme: _textButtonTheme,
    dividerTheme: _dividerThemeData,
    cupertinoOverrideTheme: _cupertinoOverrideTheme,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll<Color>(kdPrimaryTextColor),
    ),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: kdPrimaryColor,
          brightness: Brightness.dark,
        ).copyWith(
          surface: kdBackgroundColor,
          onTertiary: kdPrimaryTextColor,
          surfaceTint: Colors.transparent,
        ),
  ),
};

final _textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
);

const _dividerThemeData = DividerThemeData(
  color: Colors.black12,
  thickness: .5,
);

final _dialogThemeData = DialogThemeData(
  alignment: Alignment.center,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
  titleTextStyle: kFonts.copyWith(
    fontSize: 18,
    fontWeight: FontWeights.regular,
    color: klPrimaryTextColor,
  ),
  contentTextStyle: kFonts.copyWith(
    fontSize: 16,
    fontWeight: FontWeights.regular,
    color: klPrimaryTextColor,
  ),
  shadowColor: Colors.transparent,
  surfaceTintColor: klPageBackgroundColor,
  backgroundColor: klPageBackgroundColor,
);

final _cupertinoOverrideTheme = NoDefaultCupertinoThemeData(
  textTheme: CupertinoTextThemeData(textStyle: kFonts),
);

final _tabBarTheme = TabBarThemeData(
  tabAlignment: TabAlignment.center,
  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  dividerHeight: 0,
  labelColor: klBackgroundColor,
  labelStyle: kFonts.copyWith(fontWeight: FontWeights.regular, fontSize: 14),
  unselectedLabelColor: Colors.black45,
  indicatorSize: TabBarIndicatorSize.tab,
  indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(25),
    color: klPrimaryColor,
  ),
);
