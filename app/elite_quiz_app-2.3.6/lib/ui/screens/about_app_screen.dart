import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/screens/app_settings_screen.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const AboutAppScreen());
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      (title: contactUs, icon: Assets.contactUsIcon),
      (title: aboutUs, icon: Assets.aboutUsIcon),
      (title: termsAndConditions, icon: Assets.termsAndCondIcon),
      (title: privacyPolicy, icon: Assets.privacyPolicyIcon),
    ];

    Future<void> onTapOption(String title) async {
      await context.pushNamed(
        Routes.appSettings,
        arguments: AppSettingsScreenArgs(title),
      );
    }

    return Scaffold(
      appBar: QAppBar(title: Text(context.tr(aboutQuizAppKey)!)),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.height * UiUtils.vtMarginPct,
          horizontal: context.width * UiUtils.hzMarginPct,
        ),
        child: Column(
          spacing: UiUtils.listTileGap,
          children: options
              .map(
                (option) {
                  return ListTile(
                    onTap: () => onTapOption(option.title),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: QImage(
                      imageUrl: option.icon,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      color: context.primaryColor,
                    ),
                    title: Text(
                      context.tr(option.title)!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.medium,
                        color: context.primaryTextColor,
                      ),
                    ),
                    tileColor: context.surfaceColor,
                  );
                },
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
