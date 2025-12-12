import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/ads.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/exam/cubits/exam_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_local_data_source.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/home/widgets/all.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

typedef ZoneType = ({String title, String img, String desc});

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  bool get _isGuest => context.read<AuthCubit>().isGuest;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int _notificationId = 0;

  final battleZones = <ZoneType>[
    (title: 'groupPlay', img: Assets.groupBattleIcon, desc: 'desGroupPlay'),
    (title: 'battleQuiz', img: Assets.oneVsOneIcon, desc: 'desBattleQuiz'),
  ];

  final examZones = <ZoneType>[
    (title: 'exam', img: Assets.examQuizIcon, desc: 'desExam'),
    (
      title: 'selfChallenge',
      img: Assets.selfChallengeIcon,
      desc: 'challengeYourselfLbl',
    ),
  ];

  // Screen dimensions
  double get scrWidth => context.width;

  double get scrHeight => context.height;

  // HomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = TextStyle(
    fontWeight: FontWeights.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onTertiary,
  );

  ///
  late String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;

  @override
  void initState() {
    super.initState();

    showAppUnderMaintenanceDialog();

    _sysConfigCubit = context.read<SystemConfigCubit>();

    setQuizMenu();
    _initLocalNotification();
    checkForUpdates();
    setupInteractedMessage();

    /// Create Ads
    Future.delayed(Duration.zero, () async {
      await context.read<RewardedAdCubit>().createDailyRewardAd(context);
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
    });

    WidgetsBinding.instance.addObserver(this);

    ///
    _currLangId = UiUtils.getCurrentQuizLanguageId(context);

    if (!_isGuest) {
      fetchUserDetails();

      context.read<ContestCubit>().getContest(languageId: _currLangId);
    }
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      refreshKey.currentState?.show();
    }
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (_sysConfigCubit.isAppUnderMaintenance) {
        showDialog<void>(
          context: context,
          builder: (_) => const AppUnderMaintenanceDialog(),
        );
      }
    });
  }

  Future<void> _initLocalNotification() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    /// Request Permissions for IOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      if (!_sysConfigCubit.isExamQuizEnabled) {
        examZones.removeWhere((e) => e.title == 'exam');
      }

      if (!_sysConfigCubit.isSelfChallengeQuizEnabled) {
        examZones.removeWhere((e) => e.title == 'selfChallenge');
      }

      if (!_sysConfigCubit.isGroupBattleEnabled) {
        battleZones.removeWhere((e) => e.title == 'groupPlay');
      }

      if (!_sysConfigCubit.isOneVsOneBattleEnabled &&
          !_sysConfigCubit.isRandomBattleEnabled) {
        battleZones.removeWhere((e) => e.title == 'battleQuiz');
      }

      setState(() {});
    });
  }

  late bool showUpdateContainer = false;

  Future<void> checkForUpdates() async {
    await Future<void>.delayed(Duration.zero);
    if (_sysConfigCubit.isForceUpdateEnable) {
      try {
        final forceUpdate = await UiUtils.forceUpdate(
          _sysConfigCubit.appVersion,
        );

        if (forceUpdate) {
          setState(() => showUpdateContainer = true);
        }
      } on Exception catch (e) {
        log('Force Update Error', error: e);
      }
    }
  }

  static StreamSubscription<RemoteMessage>? notificationStream;

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        provisional: true,
      );
    } else {
      final isGranted = (await Permission.notification.status).isGranted;
      if (!isGranted) await Permission.notification.request();
    }

    await notificationStream?.cancel();

    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    notificationStream = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      if (message.data.isNotEmpty) {
        log('Notification arrives : ${message.toMap()}');
        final data = message.data;
        final title = data['title'].toString();
        final body = data['body'].toString();
        final type = data['type'].toString();
        final image = data['image'].toString();

        //payload is some data you want to pass in local notification
        if (image != 'null' && image.isNotEmpty) {
          log('image ${image.runtimeType}');
          await generateImageNotification(title, body, image, type, type);
        } else {
          await generateSimpleNotification(title, body, type);
        }

        //if notification type is badges then update badges in cubit list
        if (type == 'badges') {
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              context.read<BadgesCubit>().unlockBadge(
                data['badge_type'] as String,
              );
            }
          });
        } else if (type == 'payment_request') {
          Future.delayed(Duration.zero, () {
            context.read<UserDetailsCubit>().updateCoins(
              addCoin: true,
              coins: int.parse(data['coins'] as String),
            );
          });
        }
      }
    });
  }

  //quiz_type according to the notification category
  QuizTypes _getQuizTypeFromCategory(String category) {
    return switch (category) {
      'audio-question-category' => QuizTypes.audioQuestions,
      'guess-the-word-category' => QuizTypes.guessTheWord,
      'fun-n-learn-category' => QuizTypes.funAndLearn,
      _ => QuizTypes.quizZone,
    };
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'].toString().contains('category')) {
        await Navigator.of(context).pushNamed(
          Routes.category,
          arguments: CategoryScreenArgs(
            quizType: _getQuizTypeFromCategory(message.data['type'] as String),
          ),
        );
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        await Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == 'payment_request') {
        await Navigator.of(context).pushNamed(Routes.wallet);
      }
    } on Exception catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> _onTapLocalNotification(NotificationResponse? payload) async {
    final type = payload!.payload ?? '';
    if (type == 'badges') {
      await Navigator.of(context).pushNamed(Routes.badges);
    } else if (type.contains('category')) {
      await Navigator.of(context).pushNamed(
        Routes.category,
        arguments: CategoryScreenArgs(quizType: _getQuizTypeFromCategory(type)),
      );
    } else if (type == 'payment_request') {
      await Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(
    String title,
    String msg,
    String image,
    String payloads,
    String type,
  ) async {
    final largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      kPackageName,
      kAppName,
      icon: '@drawable/ic_notification',
      channelDescription: kAppName,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      msg,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
    String title,
    String body,
    String payloads,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      kPackageName, //channel id
      kAppName, //channel name
      channelDescription: kAppName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/ic_notification',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      body,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    ProfileManagementLocalDataSource().updateReversedCoins(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource().updateReversedCoins(0);
    }
  }

  void _onPressedSelfExam(String index) {
    if (_isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    if (index == 'exam') {
      context.read<ExamCubit>().updateState(ExamInitial());
      globalCtx.pushNamed(Routes.exams);
    } else if (index == 'selfChallenge') {
      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
      context.read<SubCategoryCubit>().updateState(SubCategoryInitial());
      globalCtx.pushNamed(Routes.selfChallenge);
    }
  }

  void _onPressedBattle(String index) {
    if (_isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
    if (index == 'groupPlay') {
      context.read<MultiUserBattleRoomCubit>().updateState(
        MultiUserBattleRoomInitial(),
      );

      globalCtx.push(
        CupertinoPageRoute<void>(
          builder: (_) => BlocProvider<UpdateCoinsCubit>(
            create: (context) =>
                UpdateCoinsCubit(ProfileManagementRepository()),
            child: CreateOrJoinRoomScreen(
              quizType: QuizTypes.groupPlay,
              title: context.tr('groupPlay')!,
            ),
          ),
        ),
      );
    } else if (index == 'battleQuiz') {
      context.read<BattleRoomCubit>().updateState(
        BattleRoomInitial(),
        cancelSubscription: true,
      );

      if (_sysConfigCubit.isRandomBattleEnabled) {
        globalCtx.pushNamed(Routes.randomBattle);
      } else {
        globalCtx.push(
          CupertinoPageRoute<CreateOrJoinRoomScreen>(
            builder: (_) => BlocProvider<UpdateCoinsCubit>(
              create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
              child: CreateOrJoinRoomScreen(
                quizType: QuizTypes.oneVsOneBattle,
                title: context.tr('playWithFrdLbl')!,
              ),
            ),
          ),
        );
      }
    }
  }

  late String _userName = context.tr('guest')!;
  String _userProfileImg = '';

  Widget _buildBattle() {
    return battleZones.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(battleOfTheDayKey)!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeights.semiBold,
                    color: context.primaryTextColor,
                  ),
                ),

                /// Categories
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    battleZones.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedBattle(battleZones[i].title),
                      title: context.tr(battleZones[i].title)!,
                      desc: context.tr(battleZones[i].desc)!,
                      img: battleZones[i].img,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildExamSelf() {
    return examZones.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(selfExamZoneKey)!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeights.semiBold,
                    color: context.primaryTextColor,
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    examZones.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedSelfExam(examZones[i].title),
                      title: context.tr(examZones[i].title)!,
                      desc: context.tr(examZones[i].desc)!,
                      img: examZones[i].img,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildDailyAds() {
    var clicked = false;
    return BlocBuilder<RewardedAdCubit, RewardedAdState>(
      builder: (context, state) {
        if (state is RewardedAdLoaded &&
            context.read<UserDetailsCubit>().isDailyAdAvailable) {
          return GestureDetector(
            onTap: () async {
              if (!clicked) {
                await context.read<RewardedAdCubit>().showDailyAd(
                  context: context,
                );
                clicked = true;
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: hzMargin,
                right: hzMargin,
                top: scrHeight * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
              ),
              width: scrWidth,
              height: scrWidth * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      Assets.dailyCoins,
                      width: scrWidth * .23,
                      height: scrWidth * .23,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          context.tr('dailyAdsTitle')!,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeights.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${context.tr("get")!} "
                        '${_sysConfigCubit.coinsPerDailyAdView} '
                        "${context.tr("dailyAdsDesc")!}",
                        style: TextStyle(
                          fontWeight: FontWeights.regular,
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiary.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLiveContestSection() {
    void onTapViewAll() {
      if (_sysConfigCubit.isContestEnabled) {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        context.showSnack(context.tr(currentlyNotAvailableKey)!);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hzMargin, vertical: 10),
      child: Column(
        children: [
          /// Contest Section Title
          Row(
            children: [
              Text(
                context.tr(contest) ?? contest,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeights.semiBold,
                  color: context.primaryTextColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTapViewAll,
                child: Text(
                  context.tr(viewAllKey) ?? viewAllKey,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.semiBold,
                    color: context.primaryTextColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Contest Card
          BlocConsumer<ContestCubit, ContestState>(
            bloc: context.read<ContestCubit>(),
            listener: (context, state) {
              if (state is ContestFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
            builder: (context, state) {
              if (state is ContestFailure) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    context.tr(
                      convertErrorCodeToLanguageKey(state.errorMessage),
                    )!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeights.regular,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 2,
                  ),
                );
              }

              if (state is ContestSuccess) {
                final colorScheme = Theme.of(context).colorScheme;
                final textStyle = GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.regular,
                    color: colorScheme.onTertiary.withValues(alpha: 0.6),
                  ),
                );

                ///
                final live = state.contestList.live;

                /// No Contest
                if (live.errorMessage.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      context.tr(
                        convertErrorCodeToLanguageKey(live.errorMessage),
                      )!,
                      style: _boldTextStyle.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }

                final contest = live.contestDetails.first;
                final entryFee = int.parse(contest.entry!);

                void onTapPlayNow() {
                  final userDetailsCubit = context.read<UserDetailsCubit>();

                  if (int.parse(userDetailsCubit.getCoins()!) >= entryFee) {
                    context.read<UpdateCoinsCubit>().updateCoins(
                      coins: entryFee,
                      addCoin: false,
                      title: playedContestKey,
                    );
                    userDetailsCubit.updateCoins(
                      addCoin: false,
                      coins: entryFee,
                    );

                    Navigator.of(globalCtx).pushNamed(
                      Routes.quiz,
                      arguments: {
                        'quizType': QuizTypes.contest,
                        'contestId': contest.id,
                      },
                    );
                  } else {
                    showNotEnoughCoinsDialog(context);
                  }
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 5,
                        color: Colors.black12,
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(99999),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Contest Image
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: QImage(
                                  imageUrl: contest.image!,
                                  height: 45,
                                  width: 45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            /// Contest Name & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contest.name.toString(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: _boldTextStyle.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    contest.description.toString(),
                                    softWrap: true,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: textStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        ///
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Entry Fees
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: context.tr('entryFeesLbl'),
                                      ),
                                      const TextSpan(text: ' : '),
                                      TextSpan(
                                        text:
                                            "$entryFee ${context.tr("coinsLbl")!}",
                                        style: textStyle.copyWith(
                                          color: colorScheme.onTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: textStyle,
                                ),
                                const SizedBox(height: 5),

                                /// Ends on
                                Text.rich(
                                  style: textStyle,
                                  TextSpan(
                                    children: [
                                      TextSpan(text: context.tr('endsOnLbl')),
                                      const TextSpan(text: ' : '),
                                      TextSpan(
                                        text: '${contest.endDate}  |  ',
                                        style: textStyle.copyWith(
                                          color: colorScheme.onTertiary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: contest.participants.toString(),
                                        style: textStyle.copyWith(
                                          color: colorScheme.onTertiary,
                                        ),
                                      ),
                                      const TextSpan(text: ' : '),
                                      TextSpan(text: context.tr('playersLbl')),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            /// Play Now
                            GestureDetector(
                              onTap: onTapPlayNow,
                              child: Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                ),
                                child: Text(
                                  context.tr('playnowLbl')!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: CircularProgressContainer());
            },
          ),
        ],
      ),
    );
  }

  String _userRank = '0';
  String _userCoins = '0';
  String _userScore = '0';

  Widget _buildHome() {
    return BlocConsumer<AppLocalizationCubit, AppLocalizationState>(
      listener: (context, state) async {
        _userName = context.tr('guest')!;
        if (_isGuest) return;

        final currentLanguage = state.language.name;
        final userProfile = context.read<UserDetailsCubit>().getUserProfile();

        if (currentLanguage != userProfile.appLanguage) {
          await context.read<UserDetailsCubit>().updateLanguage(
            currentLanguage,
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SizedBox(height: context.height * .12),
                  Expanded(
                    child: RefreshIndicator(
                      key: refreshKey,
                      color: context.primaryColor,
                      backgroundColor: context.scaffoldBackgroundColor,
                      onRefresh: () async {
                        _currLangId = UiUtils.getCurrentQuizLanguageId(context);

                        if (!_isGuest) {
                          fetchUserDetails();

                          await context.read<ContestCubit>().getContest(
                            languageId: _currLangId,
                          );
                        }
                        setState(() {});
                      },
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          const SizedBox(height: 24),
                          UserAchievements(
                            userRank: _userRank,
                            userCoins: _userCoins,
                            userScore: _userScore,
                          ),
                          const SizedBox(height: 16),
                          if (!_isGuest &&
                              _sysConfigCubit.isAdsEnable &&
                              _sysConfigCubit.isDailyAdsEnabled) ...[
                            _buildDailyAds(),
                          ],
                          if (!_isGuest &&
                              _sysConfigCubit.isContestEnabled) ...[
                            _buildLiveContestSection(),
                          ],
                          _buildBattle(),
                          _buildExamSelf(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildUserProfileHeader(),
            ),
            if (showUpdateContainer) const UpdateAppContainer(),
          ],
        );
      },
    );
  }

  Widget _buildUserProfileHeader() {
    void onTapNotification() {
      if (_isGuest) {
        globalCtx.pushNamed(Routes.login);
      } else {
        globalCtx.pushNamed(Routes.notification);
      }
    }

    void onTapCoinStore() {
      globalCtx.pushNamed(Routes.coinStore);
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: context.height * .01,
          width: context.width * .8,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.elliptical(context.height * .04, context.height * .04),
            ),
            boxShadow: [
              BoxShadow(
                color: context.primaryTextColor.withValues(alpha: .3),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        Container(
          height: context.height * .16,
          width: context.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight * .55;
              final maxWidth = constraints.maxWidth;

              return SizedBox(
                width: maxWidth,
                height: maxHeight,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.primaryTextColor.withValues(alpha: .3),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      width: maxHeight * .9,
                      height: maxHeight * .9,
                      child: QImage.circular(imageUrl: _userProfileImg),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _userName,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.primaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.tr(letsPlay)!,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.primaryTextColor.withValues(
                                  alpha: .3,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onTapNotification,
                      child: Container(
                        width: maxHeight * .7,
                        height: maxHeight * .7,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        alignment: Alignment.center,
                        child: _isGuest
                            ? Icon(
                                Icons.login_rounded,
                                color: context.surfaceColor,
                              )
                            : QImage(
                                imageUrl: Assets.notificationMenuIcon,
                                color: context.surfaceColor,
                              ),
                      ),
                    ),
                    if (_sysConfigCubit.isCoinStoreEnabled) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onTapCoinStore,
                        child: Container(
                          width: maxHeight * .7,
                          height: maxHeight * .7,
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          alignment: Alignment.center,
                          child: QImage(
                            imageUrl: Assets.coinMenuIcon,
                            color: context.surfaceColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  bool profileComplete = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// need to add this here, cause textStyle doesn't update automatically when changing theme.
    _boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: context.primaryTextColor,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: _isGuest
          ? _buildHome()
          /// Build home with User
          : BlocConsumer<UserDetailsCubit, UserDetailsState>(
              bloc: context.read<UserDetailsCubit>(),
              listener: (context, state) {
                if (state is UserDetailsFetchSuccess) {
                  final currLang = context
                      .read<AppLocalizationCubit>()
                      .state
                      .language
                      .name;

                  if (state.userProfile.appLanguage != currLang) {
                    context.read<UserDetailsCubit>().updateLanguage(currLang);
                  }

                  UiUtils.fetchBookmarkAndBadges(
                    context: context,
                    userId: state.userProfile.userId!,
                  );
                  if (state.userProfile.profileUrl!.isEmpty ||
                      state.userProfile.name!.isEmpty) {
                    if (!profileComplete) {
                      profileComplete = true;

                      globalCtx.pushNamed(
                        Routes.selectProfile,
                        arguments: const CreateOrEditProfileScreenArgs(
                          isNewUser: false,
                        ),
                      );
                    }
                    return;
                  }
                } else if (state is UserDetailsFetchFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is UserDetailsFetchInProgress ||
                    state is UserDetailsInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is UserDetailsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      showBackButton: true,
                      // DEBUG: Show actual error message
                      errorMessage: 'ERROR: ${state.errorMessage}',
                      onTapRetry: fetchUserDetails,
                      showErrorImage: true,
                    ),
                  );
                }

                final user = (state as UserDetailsFetchSuccess).userProfile;

                _userName = user.name!;
                _userProfileImg = user.profileUrl!;
                _userRank = user.allTimeRank!;
                _userCoins = user.coins!;
                _userScore = user.allTimeScore!;

                return _buildHome();
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
