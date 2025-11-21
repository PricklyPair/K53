import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/utils/extensions.dart';

class AppUnderMaintenanceDialog extends StatelessWidget {
  const AppUnderMaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: context.height * 0.275,
              width: context.width * 0.8,
              child: SvgPicture.asset(Assets.underMaintenance),
            ),
            Text(
              context.tr(appUnderMaintenanceKey)!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
