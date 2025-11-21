import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/system_config/cubits/app_settings_cubit.dart';
import 'package:flutterquiz/features/system_config/system_config_repository.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// AppSettingsScreen shows app setting details like about us,
/// privacy policy, terms and conditions, etc.
///
/// It takes a required [title] parameter indicating which setting to load.
/// Uses AppSettingsCubit and SystemConfigRepository to fetch setting data.
/// _settingType determines type string to pass to cubit based on [title].
/// fetchAppSetting calls cubit method to fetch data.
///
/// _onTapUrl handles launching external urls.

final class AppSettingsScreenArgs extends RouteArgs {
  const AppSettingsScreenArgs(this.title);

  final String title;
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({required this.args, super.key});

  final AppSettingsScreenArgs args;

  static Route<AppSettingsScreen> route(RouteSettings routeSettings) {
    final args = routeSettings.args<AppSettingsScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(SystemConfigRepository()),
        child: AppSettingsScreen(args: args),
      ),
    );
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late final String _settingType = switch (widget.args.title) {
    aboutUs => 'about_us',
    privacyPolicy => 'privacy_policy',
    termsAndConditions => 'terms_conditions',
    contactUs => 'contact_us',
    howToPlayLbl => 'instructions',
    _ => '',
  };
  late final String _screenTitle = context.tr(widget.args.title)!;

  @override
  void initState() {
    super.initState();
    fetchAppSetting();
  }

  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(_settingType);
    });
  }

  FutureOr<bool> _onTapUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Error Launching URL : $url', name: 'Launch URL');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(_screenTitle)),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                onTapRetry: fetchAppSetting,
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state is AppSettingsFetchSuccess) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: context.height * UiUtils.vtMarginPct,
                horizontal: context.width * UiUtils.hzMarginPct + 10,
              ),
              child: HtmlWidget(
                state.settingsData,
                onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                onLoadingBuilder: (_, e, l) =>
                    const Center(child: CircularProgressIndicator()),
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                onTapUrl: _onTapUrl,
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
