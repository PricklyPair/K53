import 'package:flutter/cupertino.dart';

extension BuildContextExt on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  bool get isXSmall => shortestSide < 600;

  bool get isSmall => shortestSide < 905;

  bool get isMedium => shortestSide < 1240;

  bool get isLarge => shortestSide < 1440;

  ///
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}
