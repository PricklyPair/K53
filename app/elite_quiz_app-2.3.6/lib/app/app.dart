import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/ads.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/badges/badges_repository.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/battle_room/battle_room_repository.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/bookmark/bookmark_repository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/exam/cubits/exam_cubit.dart';
import 'package:flutterquiz/features/exam/exam_repository.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehension_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlock_premium_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/settings/settings_local_data_source.dart';
import 'package:flutterquiz/features/settings/settings_repository.dart';
import 'package:flutterquiz/features/statistic/cubits/statistics_cubit.dart';
import 'package:flutterquiz/features/statistic/statistic_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/system_config_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<Widget> initializeApp() async {
  try {
    log('Initializing WidgetsFlutterBinding...', name: 'App Init');
    WidgetsFlutterBinding.ensureInitialized();
    log('WidgetsFlutterBinding initialized', name: 'App Init');

    log('Setting preferred orientations...', name: 'App Init');
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    log('Orientation set to portrait', name: 'App Init');

    log('Setting SystemUIOverlayStyle...', name: 'App Init');
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    log('SystemUIOverlayStyle configured', name: 'App Init');

    log('Initializing Firebase...', name: 'App Init');
    await Firebase.initializeApp();
    log('Firebase initialized successfully', name: 'App Init');

    log('Configuring Firestore settings...', name: 'App Init');
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    log('Firestore settings configured', name: 'App Init');

    // Local phone storage
    log('Initializing Hive...', name: 'App Init');
    await Hive.initFlutter();
    log('Hive initialized', name: 'App Init');

    log('Opening authBox...', name: 'App Init');
    await Hive.openBox<dynamic>(authBox);
    log('authBox opened', name: 'App Init');

    log('Opening settingsBox...', name: 'App Init');
    await Hive.openBox<dynamic>(settingsBox);
    log('settingsBox opened', name: 'App Init');

    log('Opening userDetailsBox...', name: 'App Init');
    await Hive.openBox<dynamic>(userDetailsBox);
    log('userDetailsBox opened', name: 'App Init');

    log('Opening examBox...', name: 'App Init');
    await Hive.openBox<dynamic>(examBox);
    log('examBox opened', name: 'App Init');

    log('All Hive boxes opened successfully', name: 'App Init');

    return const MyApp();
  } catch (e, stackTrace) {
    log(
      'Error during app initialization',
      name: 'App Init',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow; // Re-throw to be caught by main()
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(SettingsLocalDataSource()),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(SettingsRepository()),
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<AppLocalizationCubit>(
          create: (_) => AppLocalizationCubit(SettingsRepository()),
        ),
        BlocProvider<QuizLanguageCubit>(
          create: (_) => QuizLanguageCubit(SettingsLocalDataSource()),
        ),
        BlocProvider<UserDetailsCubit>(
          create: (_) => UserDetailsCubit(ProfileManagementRepository()),
        ),
        //bookmark questions of quiz zone
        BlocProvider<BookmarkCubit>(
          create: (_) => BookmarkCubit(BookmarkRepository()),
        ),
        BlocProvider<GuessTheWordBookmarkCubit>(
          create: (_) => GuessTheWordBookmarkCubit(BookmarkRepository()),
        ),
        BlocProvider<AudioQuestionBookmarkCubit>(
          create: (_) => AudioQuestionBookmarkCubit(BookmarkRepository()),
        ),
        BlocProvider<MultiUserBattleRoomCubit>(
          create: (_) => MultiUserBattleRoomCubit(BattleRoomRepository()),
        ),
        BlocProvider<BattleRoomCubit>(
          create: (_) => BattleRoomCubit(BattleRoomRepository()),
        ),
        BlocProvider<SystemConfigCubit>(
          create: (_) => SystemConfigCubit(SystemConfigRepository()),
        ),
        BlocProvider<BadgesCubit>(
          create: (_) => BadgesCubit(BadgesRepository()),
        ),
        BlocProvider<StatisticCubit>(
          create: (_) => StatisticCubit(StatisticRepository()),
        ),
        BlocProvider<InterstitialAdCubit>(create: (_) => InterstitialAdCubit()),
        BlocProvider<RewardedAdCubit>(create: (_) => RewardedAdCubit()),
        BlocProvider<ExamCubit>(create: (_) => ExamCubit(ExamRepository())),
        BlocProvider<ComprehensionCubit>(
          create: (_) => ComprehensionCubit(QuizRepository()),
        ),
        BlocProvider<ContestCubit>(
          create: (_) => ContestCubit(QuizRepository()),
        ),
        //
        BlocProvider<QuizCategoryCubit>(
          create: (_) => QuizCategoryCubit(QuizRepository()),
        ),
        BlocProvider<UnlockedLevelCubit>(
          create: (_) => UnlockedLevelCubit(QuizRepository()),
        ),
        BlocProvider<SubCategoryCubit>(
          create: (_) => SubCategoryCubit(QuizRepository()),
        ),
        BlocProvider<UnlockPremiumCategoryCubit>(
          create: (_) => UnlockPremiumCategoryCubit(QuizRepository()),
        ),
        BlocProvider<BannerAdCubit>(create: (_) => BannerAdCubit()),
      ],
      child: Builder(
        builder: (context) {
          final currentTheme = context.select<ThemeCubit, Brightness>(
            (bloc) => bloc.state,
          );

          return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
            buildWhen: (prev, curr) => prev.language.name != curr.language.name,
            builder: (context, state) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value:
                    (currentTheme == Brightness.light
                            ? SystemUiOverlayStyle.dark
                            : SystemUiOverlayStyle.light)
                        .copyWith(
                          statusBarColor: Colors.transparent,
                          systemNavigationBarColor: appThemeData[currentTheme]
                              ?.scaffoldBackgroundColor,
                          systemNavigationBarIconBrightness:
                              currentTheme == Brightness.light
                              ? Brightness.dark
                              : Brightness.light,
                        ),
                child: MaterialApp(
                  title: kAppName,
                  key: ValueKey(state.language.name),
                  builder: (_, widget) => Directionality(
                    textDirection: state.language.isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: widget!,
                  ),
                  navigatorKey: globalNavigator,
                  theme: appThemeData[currentTheme],
                  debugShowCheckedModeBanner: false,
                  initialRoute: Routes.splash,
                  onGenerateRoute: Routes.onGenerateRouted,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
