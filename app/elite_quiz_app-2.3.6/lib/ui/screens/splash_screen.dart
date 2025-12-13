import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/app_tracking_transparency_helper.dart';
import 'package:flutterquiz/utils/gdpr_helper.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const SplashScreen());
  }
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleUpAnimation;
  late Animation<double> _logoScaleDownAnimation;

  bool _systemConfigLoaded = false;

  final String _appLogoPath = Assets.splashLogo;
  final String _orgLogoPath = Assets.orgLogo;
  final bool showCompanyLogo = kShowOrgLogo;

  String languageError = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _initLanguage()
          .then((_) async {
            await _fetchSystemConfig();
          })
          .catchError((Object? e, StackTrace? stackTrace) {
            log(
              'Error during language initialization',
              name: 'SplashScreen',
              error: e,
              stackTrace: stackTrace,
            );
            setState(() {
              languageError = 'Language Init Error: $e';
            });
          });
    });
    _initAnimations();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initLanguage() async {
    try {
      log('Initializing app localization...', name: 'SplashScreen');
      await context.read<AppLocalizationCubit>().init();
      log('App localization initialized', name: 'SplashScreen');
    } catch (e, stackTrace) {
      log(
        'Error in _initLanguage',
        name: 'SplashScreen',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _initAnimations() {
    _logoAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 700),
        )..addListener(() {
          if (_logoAnimationController.isCompleted) {
            _navigateToNextScreen();
          }
        });
    _logoScaleUpAnimation = Tween<double>(begin: 0, end: 1.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0, 0.4, curve: Curves.ease),
      ),
    );
    _logoScaleDownAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.4, 1, curve: Curves.easeInOut),
      ),
    );

    _logoAnimationController.forward();
  }

  Future<void> _initUnityAds() async {
    await UnityAds.init(
      gameId: context.read<SystemConfigCubit>().unityGameId,
      testMode: true,
      onComplete: () => log('Initialized', name: 'Unity Ads'),
      onFailed: (err, msg) =>
          log('Initialization Failed: $err $msg', name: 'Unity Ads'),
    );
  }

  Future<void> _fetchSystemConfig() async {
    try {
      log('Fetching system config...', name: 'SplashScreen');
      await context.read<SystemConfigCubit>().getSystemConfig();
      log('System config fetched successfully', name: 'SplashScreen');

      log('Initializing GDPR helper...', name: 'SplashScreen');
      await GdprHelper.initialize();
      log('GDPR helper initialized', name: 'SplashScreen');

      log('Requesting tracking permission...', name: 'SplashScreen');
      await AppTrackingTransparencyHelper.requestTrackingPermission();
      log('Tracking permission handled', name: 'SplashScreen');
    } catch (e, stackTrace) {
      log(
        'Error in _fetchSystemConfig',
        name: 'SplashScreen',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _initIronSource() async {
    final appKey = context.read<SystemConfigCubit>().ironSourceAppKey;

    /// Enables debug mode for LevelPlay adapters.
    /// Validates integration.
    if (kDebugMode) {
      await LevelPlay.setAdaptersDebug(true);
      // this function doesn't have to be awaited
      if (Platform.isAndroid) {
        unawaited(LevelPlay.validateIntegration());
      } else {
        // Connect your real device, it doesn't work on Simulator, so not possible to test.
        // also Allow App Tracking Permission to get the app id, otherwise it won't show.
        log(
          'GAID is: ${await AppTrackingTransparencyHelper.getAdvertisingIdentifier()}',
          name: 'LevelPlay',
        );
      }
    }

    try {
      await LevelPlay.init(
        initRequest: LevelPlayInitRequest(
          appKey: appKey,
          legacyAdFormats: [
            AdFormat.REWARDED,
            AdFormat.BANNER,
            AdFormat.INTERSTITIAL,
          ],
        ),
        initListener: _QLevelPlayInitListener(),
      );
    } on Exception catch (e, st) {
      log('LevelPlayInit', name: 'LevelPlay', error: e, stackTrace: st);
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!_systemConfigLoaded) return;

    final adsType = context.read<SystemConfigCubit>().adsType;

    if (adsType == AdType.ironSource) {
      await _initIronSource();
    } else if (adsType == AdType.unity) {
      await _initUnityAds();
    }

    final showIntroSlider = context
        .read<SettingsCubit>()
        .state
        .settingsModel!
        .showIntroSlider;

    if (showIntroSlider) {
      /// Set Default Quiz Language
      if (context.read<SystemConfigCubit>().isLanguageModeEnabled) {
        final defaultQuizLanguage = context
            .read<SystemConfigCubit>()
            .supportedQuizLanguages
            .firstWhere((e) => e.isDefault);

        context.read<QuizLanguageCubit>().languageId = defaultQuizLanguage.id;
      }

      /// Navigate to language select screen if more than one language is available
      if (context.read<AppLocalizationCubit>().state.systemLanguages.length >
          1) {
        await context.pushReplacementNamed(Routes.languageSelect);
      } else {
        await context.pushReplacementNamed(Routes.introSlider);
      }
      return;
    } else {
      // If language mode is enabled and no language ID is currently set,
      // set the quiz language to the default.
      // This handles cases where language mode might have been enabled after initial setup.
      if (context.read<SystemConfigCubit>().isLanguageModeEnabled &&
          context.read<QuizLanguageCubit>().languageId.trim().isEmpty) {
        final defaultQuizLanguage = context
            .read<SystemConfigCubit>()
            .supportedQuizLanguages
            .firstWhere((e) => e.isDefault);

        context.read<QuizLanguageCubit>().languageId = defaultQuizLanguage.id;
      }
    }

    await context.pushReplacementNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SystemConfigCubit, SystemConfigState>(
      bloc: context.read<SystemConfigCubit>(),
      listener: (context, state) {
        if (state is SystemConfigFetchSuccess) {
          if (!_systemConfigLoaded) {
            _systemConfigLoaded = true;
          }

          if (_logoAnimationController.isCompleted) {
            _navigateToNextScreen();
          }
        }
      },
      builder: (context, state) {
        final systemUiOverlayStyle =
            (context.read<ThemeCubit>().state == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light);

        if (languageError.isNotEmpty) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiOverlayStyle.copyWith(
              systemNavigationBarColor: context.scaffoldBackgroundColor,
            ),
            child: Scaffold(
              backgroundColor: context.scaffoldBackgroundColor,
              body: Center(
                key: const Key('errorContainer'),
                child: ErrorContainer(
                  showBackButton: true,
                  errorMessageColor: Theme.of(context).colorScheme.onTertiary,
                  // Show the full error message instead of converting to language key
                  errorMessage: languageError,
                  onTapRetry: () {
                    _initLanguage()
                        .then((_) {
                          languageError = '';
                          _fetchSystemConfig();
                        })
                        .catchError((Object? e, StackTrace? stackTrace) {
                          log(
                            'Error during language initialization retry',
                            name: 'SplashScreen',
                            error: e,
                            stackTrace: stackTrace,
                          );
                          setState(() {
                            languageError = 'Language Init Error: $e';
                          });
                        });
                    setState(_initAnimations);
                  },
                  showErrorImage: true,
                ),
              ),
            ),
          );
        }

        if (state is SystemConfigFetchFailure) {
          // Log the error for debugging
          log(
            'System config fetch failed',
            name: 'SplashScreen',
            error: 'Error Code: ${state.errorCode}',
          );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiOverlayStyle.copyWith(
              systemNavigationBarColor: context.scaffoldBackgroundColor,
            ),
            child: Scaffold(
              backgroundColor: context.scaffoldBackgroundColor,
              body: Center(
                key: const Key('errorContainer'),
                child: ErrorContainer(
                  showBackButton: true,
                  errorMessageColor: context.colorScheme.onTertiary,
                  // Show detailed error with code
                  errorMessage: 'System Config Error\nCode: ${state.errorCode}\nMessage: ${convertErrorCodeToLanguageKey(state.errorCode)}',
                  onTapRetry: () {
                    setState(_initAnimations);
                    _fetchSystemConfig();
                  },
                  showErrorImage: true,
                ),
              ),
            ),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle.copyWith(
            systemNavigationBarColor: context.primaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.primaryColor,
            body: SizedBox.expand(
              child: Stack(
                children: [
                  /// App Logo
                  Align(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (_, _) => Transform.scale(
                          scale:
                              _logoScaleUpAnimation.value -
                              _logoScaleDownAnimation.value,
                          child: QImage(
                            imageUrl: _appLogoPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Organization Logo
                  if (showCompanyLogo) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: QImage(imageUrl: _orgLogoPath),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QLevelPlayInitListener implements LevelPlayInitListener {
  @override
  void onInitFailed(LevelPlayInitError error) {
    log('LevelPlay init failed: ${error.errorMessage}', name: 'LevelPlay');
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    log('LevelPlay init success', name: 'LevelPlay');
  }
}
