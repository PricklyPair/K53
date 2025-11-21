import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

Future<void> showLoginDialog(
  BuildContext context, {
  required VoidCallback onTapYes,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final buttonTextStyle = TextStyle(
        color: context.primaryColor,
        fontWeight: FontWeights.medium,
        fontSize: 16,
      );
      final contentTextStyle = TextStyle(
        color: context.primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeights.regular,
      );

      return AlertDialog(
        content: Text(context.tr('guestMode')!, style: contentTextStyle),
        actions: [
          CupertinoButton(
            onPressed: dialogCtx.shouldPop,
            child: Text(context.tr('cancel')!, style: buttonTextStyle),
          ),
          CupertinoButton(
            onPressed: () {
              dialogCtx.shouldPop();
              onTapYes();
            },
            child: Text(context.tr('loginLbl')!, style: buttonTextStyle),
          ),
        ],
      );
    },
  );
}
