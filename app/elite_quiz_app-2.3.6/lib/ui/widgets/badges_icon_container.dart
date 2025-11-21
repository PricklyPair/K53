import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/constants/assets_constants.dart';
import 'package:flutterquiz/features/badges/badge.dart';

class BadgesIconContainer extends StatelessWidget {
  const BadgesIconContainer({
    required this.badge,
    required this.constraints,
    required this.addTopPadding,
    this.showShadow = false,
    super.key,
  });

  final Badges badge;
  final BoxConstraints constraints;
  final bool addTopPadding;
  final bool showShadow;

  static const _greyscale = ColorFilter.matrix([
    .3, .59, .11, .0, .0, //
    .3, .59, .11, .0, .0, //
    .3, .59, .11, .0, .0, //
    .0, .0, .0, 1.0, .0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final hexagon = SvgPicture.asset(Assets.hexagon);
    final isUnlocked = badge.status != BadgesStatus.locked;

    // A blurred, offset copy of the hexagon to act as a soft drop shadow.
    final dropShadow = ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Transform.translate(
        offset: const Offset(4, 4),
        child: SvgPicture.asset(
          Assets.hexagon,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Layer 1: The Drop Shadow
        if (isUnlocked && showShadow)
          Align(
            alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: constraints.maxHeight * (addTopPadding ? 0.095 : 0),
              ),
              child: SizedBox(
                width: constraints.maxWidth * 0.775,
                height: constraints.maxHeight * 0.5,
                child: dropShadow,
              ),
            ),
          ),

        // Layer 2: The Main Hexagon
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.095 : 0),
            ),
            child: SizedBox(
              width: constraints.maxWidth * 0.775,
              height: constraints.maxHeight * 0.5,
              child: isUnlocked
                  ? hexagon
                  : ColorFiltered(colorFilter: _greyscale, child: hexagon),
            ),
          ),
        ),

        // Layer 3: The Badge Icon Image
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.1 : 0),
            ),
            child: SizedBox(
              width: constraints.maxWidth * 0.725,
              height: constraints.maxHeight * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(12.5),
                child: QImage(imageUrl: badge.badgeIcon, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
