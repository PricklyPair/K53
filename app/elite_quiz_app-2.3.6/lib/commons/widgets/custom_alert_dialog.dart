import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';

extension ShowDialogExt on BuildContext {
  Future<void> showErrorDialog(String message) {
    return showDialog(
      message: message,
      cancelButtonText: tr('close'),
    );
  }

  Future<T?> showDialog<T>({
    String? title,
    String? message,
    String? image,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogCtx, _, _) => QDialog(
        key: ValueKey('dialog_${{title ?? message}}'),
        title: title,
        message: message,
        image: image,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        onConfirm: () {
          dialogCtx.shouldPop();
          onConfirm?.call();
        },
        onCancel: onCancel ?? dialogCtx.shouldPop,
      ),
      transitionBuilder: (_, animation, _, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(curve);

        final scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(curve);

        final opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.5, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

final class QDialog extends StatelessWidget {
  const QDialog({
    super.key,
    this.image,
    this.title,
    this.message,
    this.confirmButtonText,
    this.onConfirm,
    this.cancelButtonText,
    this.onCancel,
    this.isLoading = false,
    this.loadingText,
    this.loadingWidget,
  });

  final String? image;
  final String? title;
  final String? message;

  final String? confirmButtonText;
  final VoidCallback? onConfirm;

  final String? cancelButtonText;
  final VoidCallback? onCancel;

  // Loading state
  final bool isLoading;
  final String? loadingText;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutBack,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.surfaceColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: isLoading
            ? _buildLoadingContent(context)
            : _buildNormalContent(context),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingWidget ?? const CircularProgressContainer(),
        if (loadingText != null) ...[
          const SizedBox(height: 16),
          Text(
            loadingText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNormalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //
        if (image != null) ...[
          QImage(imageUrl: image!, fit: BoxFit.contain),
          const SizedBox(height: 24),
        ],

        // Title
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Message
        if (message != null) ...[
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.primaryTextColor.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Buttons
        if (cancelButtonText != null || confirmButtonText != null)
          Row(
            spacing: 12,
            children: [
              if (cancelButtonText != null)
                Expanded(child: _buildCancelButton(context)),
              if (confirmButtonText != null)
                Expanded(child: _buildConfirmButton(context)),
            ],
          ),
      ],
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: context.primaryColor.withValues(alpha: 0.3)),
        ),
        foregroundColor: context.primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: Text(cancelButtonText!, maxLines: 2),
    );
  }

  TextButton _buildConfirmButton(BuildContext context) {
    return TextButton(
      onPressed: onConfirm,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        backgroundColor: context.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: context.surfaceColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: Text(confirmButtonText!, maxLines: 2),
    );
  }
}
