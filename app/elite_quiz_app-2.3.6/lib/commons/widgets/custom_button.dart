import 'package:flutter/material.dart';

class QButtonOptions {
  const QButtonOptions({
    this.textAlign = TextAlign.center,
    this.textStyle,
    this.elevation,
    this.height = 40,
    this.width = double.maxFinite,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor = Colors.transparent,
    this.borderRadius,
    this.borderSide = BorderSide.none,
    this.maxLines = 1,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.iconAlignment = IconAlignment.end,
  });

  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final int? maxLines;
  final Color? splashColor;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final IconAlignment iconAlignment;
}

class QButton extends StatefulWidget {
  const QButton(
    this.text, {
    required this.options,
    this.onPressed,
    this.showLoadingIndicator = true,
    this.icon,
    this.iconData,
    super.key,
  });

  final String text;
  final Future<void> Function()? onPressed;
  final QButtonOptions options;
  final bool showLoadingIndicator;
  final Widget? icon;
  final IconData? iconData;

  @override
  State<QButton> createState() => _QButtonState();
}

class _QButtonState extends State<QButton> {
  bool loading = false;

  int get maxLines => widget.options.maxLines ?? 1;
  String? get text =>
      widget.options.textStyle?.fontSize == 0 ? null : widget.text;

  @override
  Widget build(BuildContext context) {
    final textWidget = loading
        ? SizedBox(
            width: widget.options.width == null
                ? _getTextWidth(text, widget.options.textStyle, maxLines)
                : null,
            child: Center(
              child: SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.options.textStyle?.color ?? Colors.white,
                  ),
                ),
              ),
            ),
          )
        : Text(
            text ?? '',
            style: text == null ? null : widget.options.textStyle,
            textAlign: widget.options.textAlign,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );

    final onPressed = widget.onPressed != null
        ? (widget.showLoadingIndicator
              ? () async {
                  if (loading) {
                    return;
                  }
                  setState(() => loading = true);
                  try {
                    await widget.onPressed!();
                  } finally {
                    if (mounted) {
                      setState(() => loading = false);
                    }
                  }
                }
              : () => widget.onPressed!())
        : null;

    final style = ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
          side: widget.options.borderSide ?? BorderSide.none,
        ),
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled) &&
            widget.options.disabledTextColor != null) {
          return widget.options.disabledTextColor;
        }
        return widget.options.textStyle?.color ?? Colors.white;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled) &&
            widget.options.disabledColor != null) {
          return widget.options.disabledColor;
        }
        return widget.options.color;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return widget.options.splashColor;
        }
        return null;
      }),
      padding: WidgetStateProperty.all(
        widget.options.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      elevation: WidgetStateProperty.all(widget.options.elevation ?? 2.0),
    );

    if ((widget.icon != null || widget.iconData != null) && !loading) {
      final icon =
          widget.icon ??
          Icon(
            widget.iconData,
            size: widget.options.iconSize,
            color: widget.options.iconColor,
          );

      if (text == null) {
        return Container(
          height: widget.options.height,
          width: widget.options.width,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              widget.options.borderSide ?? BorderSide.none,
            ),
            borderRadius:
                widget.options.borderRadius ?? BorderRadius.circular(8),
          ),
          child: IconButton(
            splashRadius: 1,
            icon: Padding(
              padding: widget.options.iconPadding ?? EdgeInsets.zero,
              child: icon,
            ),
            onPressed: onPressed,
            style: style,
          ),
        );
      }

      return SizedBox(
        height: widget.options.height,
        width: widget.options.width,
        child: ElevatedButton.icon(
          icon: Padding(
            padding: widget.options.iconPadding ?? EdgeInsets.zero,
            child: icon,
          ),
          iconAlignment: widget.options.iconAlignment,
          label: textWidget,
          onPressed: onPressed,
          style: style,
        ),
      );
    }

    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      ),
    );
  }
}

double? _getTextWidth(String? text, TextStyle? style, int maxLines) =>
    text != null
    ? (TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      )..layout()).size.width
    : null;
