import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/widgets/custom_alert_dialog.dart';
import 'package:flutterquiz/core/core.dart';

Future<void> showLoginRequiredDialog(BuildContext context) {
  return context.showDialog(
    title: context.tr('loginRequired'),
    message: context.tr('loginRequiredDesc'),
    image: Assets.loginAccount,
    cancelButtonText: context.tr('maybeLater'),
    confirmButtonText: context.tr('loginLbl'),
    onConfirm: () => globalCtx.pushNamed(Routes.login),
  );
}
