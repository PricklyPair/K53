import 'package:flutter/material.dart';
import 'package:flutterquiz/core/constants/fonts.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class QAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QAppBar({
    required this.title,
    super.key,
    this.roundedAppBar = true,
    this.removeSnackBars = true,
    this.bottom,
    this.bottomHeight = 52,
    this.usePrimaryColor = false,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onTapBackButton,
    this.elevation,
    this.noBottomRadius = false,
  });

  final Widget title;
  final double? elevation;
  final TabBar? bottom;
  final bool automaticallyImplyLeading;
  final VoidCallback? onTapBackButton;
  final List<Widget>? actions;
  final bool roundedAppBar;
  final double bottomHeight;
  final bool removeSnackBars;
  final bool usePrimaryColor;
  final bool noBottomRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      scrolledUnderElevation: roundedAppBar ? elevation : 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation ?? (roundedAppBar ? 2 : 0),
      centerTitle: true,
      shadowColor: colorScheme.surface.withValues(alpha: 0.4),
      foregroundColor: usePrimaryColor
          ? Theme.of(context).primaryColor
          : colorScheme.onTertiary,
      backgroundColor: roundedAppBar
          ? colorScheme.surface
          : Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: roundedAppBar
          ? colorScheme.surface
          : Theme.of(context).scaffoldBackgroundColor,
      shape: noBottomRadius
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
      leading: automaticallyImplyLeading
          ? QBackButton(
              onTap: onTapBackButton,
              removeSnackBars: removeSnackBars,
              color: usePrimaryColor ? Theme.of(context).primaryColor : null,
            )
          : const SizedBox(),
      titleTextStyle: GoogleFonts.nunito(
        textStyle: TextStyle(
          color: usePrimaryColor
              ? Theme.of(context).primaryColor
              : colorScheme.onTertiary,
          fontWeight: FontWeights.bold,
          fontSize: 18,
        ),
      ),
      title: title,
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: context.width * UiUtils.hzMarginPct,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: colorScheme.onTertiary.withValues(alpha: 0.08),
                ),
                child: bottom,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + bottomHeight);
}
