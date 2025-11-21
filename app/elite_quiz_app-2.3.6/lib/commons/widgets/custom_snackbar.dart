import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/core/core.dart';

extension ShowSnackBarExt on BuildContext {
  void showSnack(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    IconData? icon,
    Color? backgroundColor,
  }) {
    HapticFeedback.lightImpact();

    // Remove any existing snackbar
    ScaffoldMessenger.of(this).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: QSnackBar(
        message: message,
        onAction: onAction,
        actionLabel: actionLabel,
        backgroundColor: backgroundColor ?? primaryColor,
        icon: icon,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.up,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

class QSnackBar extends StatefulWidget {
  const QSnackBar({
    required this.message,
    required this.backgroundColor,
    super.key,
    this.onAction,
    this.actionLabel,
    this.icon,
  });

  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color backgroundColor;
  final IconData? icon;

  @override
  State<QSnackBar> createState() => _QSnackBarState();
}

class _QSnackBarState extends State<QSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(curve);

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(curve);

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: context.surfaceColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: context.surfaceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                if (widget.onAction != null && widget.actionLabel != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onAction!();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: context.surfaceColor,
                      backgroundColor: context.surfaceColor.withValues(
                        alpha: .2,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(widget.actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
