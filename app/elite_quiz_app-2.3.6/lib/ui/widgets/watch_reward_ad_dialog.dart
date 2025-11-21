import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';

Future<bool?> showWatchAdDialog(
  BuildContext context, {
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return context.showDialog<bool>(
    image: Assets.coinsDialogIcon,
    title: context.tr('watchAdDialogTitle'),
    message: context.tr('showAdsLbl'),
    confirmButtonText: context.tr('watchAndEarn'),
    cancelButtonText: context.tr('notNow'),
    onConfirm: onConfirm,
    onCancel: onCancel,
  );
}
