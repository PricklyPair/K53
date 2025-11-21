import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppContainer extends StatelessWidget {
  const UpdateAppContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: UiUtils.dialogBlurSigma,
        sigmaY: UiUtils.dialogBlurSigma,
      ),
      child: Container(
        color: Colors.black45,
        width: context.width,
        height: context.height,
        alignment: Alignment.center,
        child: CupertinoAlertDialog(
          title: Text(
            context.tr(warningKey)!,
            style: const TextStyle(fontSize: 18),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              context.tr(updateApplicationKey)!,
              style: const TextStyle(fontSize: 14.5),
            ),
          ),
          actions: [
            CupertinoButton(
              onPressed: () async {
                try {
                  final url = context.read<SystemConfigCubit>().appUrl;
                  if (url.isEmpty) {
                    context.showSnack(
                      context.tr(failedToGetAppUrlKey)!,
                    );

                    return;
                  }
                  final canLaunch = await canLaunchUrl(Uri.parse(url));
                  if (canLaunch) {
                    await launchUrl(Uri.parse(url));
                  }
                } on Exception catch (_) {
                  context.showSnack(
                    context.tr(failedToGetAppUrlKey)!,
                  );
                }
              },
              child: Text(
                context.tr(updateKey)!,
                style: TextStyle(color: context.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
