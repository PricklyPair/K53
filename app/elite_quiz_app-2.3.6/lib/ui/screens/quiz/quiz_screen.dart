import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/questions_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audio_question_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/questions_container.dart';
import 'package:flutterquiz/ui/widgets/text_circular_timer.dart';
import 'package:flutterquiz/ui/widgets/watch_reward_ad_dialog.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

enum LifelineStatus { unused, using, used }

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    required this.isPlayed,
    required this.subcategoryMaxLevel,
    required this.quizType,
    required this.categoryId,
    required this.level,
    required this.subcategoryId,
    required this.unlockedLevel,
    required this.contestId,
    required this.comprehension,
    required this.isPremiumCategory,
    super.key,
    this.showRetryButton = true,
  });

  final QuizTypes quizType;
  final String level; //will be in use for quizZone quizType
  final String categoryId; //will be in use for quizZone quizType
  final String subcategoryId; //will be in use for quizZone quizType
  final String
  subcategoryMaxLevel; //will be in use for quizZone quizType (to pass in result screen)
  final int unlockedLevel;
  final bool isPlayed; //Only in use when quiz type is audio questions
  final String contestId;
  final Comprehension
  comprehension; // will be in use for fun n learn quizType (to pass in result screen)

  // only used for when there is no questions for that category,
  // and showing retry button doesn't make any sense i guess.
  final bool showRetryButton;
  final bool isPremiumCategory;

  @override
  State<QuizScreen> createState() => _QuizScreenState();

  //to provider route
  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    //if quizType is quizZone then need to pass following keys
    //categoryId, subcategoryId, level, subcategoryMaxLevel and unlockedLevel

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //for questions and points
          BlocProvider<QuestionsCubit>(
            create: (_) => QuestionsCubit(QuizRepository()),
          ),
          //to update user coins after using lifeline
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: QuizScreen(
          isPlayed: arguments['isPlayed'] as bool? ?? true,
          quizType: arguments['quizType'] as QuizTypes,
          categoryId: arguments['categoryId'] as String? ?? '',
          level: arguments['level'] as String? ?? '',
          subcategoryId: arguments['subcategoryId'] as String? ?? '',
          subcategoryMaxLevel:
              arguments['subcategoryMaxLevel'] as String? ?? '',
          unlockedLevel: arguments['unlockedLevel'] as int? ?? 0,
          contestId: arguments['contestId'] as String? ?? '',
          comprehension:
              arguments['comprehension'] as Comprehension? ??
              Comprehension.empty(),
          showRetryButton: arguments['showRetryButton'] as bool? ?? true,
          isPremiumCategory: arguments['isPremiumCategory'] as bool? ?? false,
        ),
      ),
    );
  }
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late final int quizDuration = context.read<SystemConfigCubit>().quizTimer(
    widget.quizType,
  );

  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late final timerAnimationController = PreserveAnimationController(
    reverseDuration: const Duration(seconds: inBetweenQuestionTimeInSeconds),
    duration: Duration(seconds: quizDuration),
  )..addStatusListener(currentUserTimerAnimationStatusListener);

  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController showOptionAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late Animation<double> showOptionAnimation = Tween<double>(begin: 0, end: 1)
      .animate(
        CurvedAnimation(
          parent: showOptionAnimationController,
          curve: Curves.easeInOut,
        ),
      );
  late List<GlobalKey<AudioQuestionContainerState>> audioQuestionContainerKeys =
      [];
  int currentQuestionIndex = 0;
  final double optionWidth = 0.7;
  final double optionHeight = 0.09;

  late double totalSecondsToCompleteQuiz = 0;

  late Map<String, LifelineStatus> lifelines = {
    fiftyFifty: LifelineStatus.unused,
    audiencePoll: LifelineStatus.unused,
    skip: LifelineStatus.unused,
    resetTime: LifelineStatus.unused,
  };

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;
  bool isExitDialogOpen = false;

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<QuestionsCubit>().getQuestions(
        widget.quizType,
        categoryId: widget.categoryId,
        level: widget.level,
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        subcategoryId: widget.subcategoryId,
        contestId: widget.contestId,
        funAndLearnId: widget.comprehension.id,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    //init reward ad
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
    });
    //init animations
    initializeAnimation();
    //
    _getQuestions();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 525),
    );
    questionSlideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    questionScaleUpAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInQuad),
      ),
    );
    questionContentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionContentAnimationController,
        curve: Curves.easeInQuad,
      ),
    );
    questionScaleDownAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.5, 1, curve: Curves.easeOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();

    super.dispose();
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    //move to result page
    //to see the what are the keys to pass in arguments for result screen
    //visit static route function in resultScreen.dart
    final lifelinesKeys = lifelines.keys
        .where((e) => lifelines[e] == LifelineStatus.used)
        .toList();
    Navigator.of(context).pushReplacementNamed(
      Routes.result,
      arguments: {
        'quizType': widget.quizType,
        'questions': context.read<QuestionsCubit>().questions(),
        'subcategoryMaxLevel': widget.subcategoryMaxLevel,
        'unlockedLevel': widget.unlockedLevel,
        'categoryId': widget.categoryId,
        'subcategoryId': widget.subcategoryId,
        'isPlayed': widget.isPlayed,
        'comprehension': widget.comprehension,
        'timeTakenToCompleteQuiz': totalSecondsToCompleteQuiz,
        'lifelines': lifelinesKeys,
        'entryFee': 0,
        'isPremiumCategory': widget.isPremiumCategory,
      },
    );
  }

  void markLifeLineUsed() {
    if (lifelines[fiftyFifty] == LifelineStatus.using) {
      lifelines[fiftyFifty] = LifelineStatus.used;
    }
    if (lifelines[audiencePoll] == LifelineStatus.using) {
      lifelines[audiencePoll] = LifelineStatus.used;
    }
    if (lifelines[resetTime] == LifelineStatus.using) {
      lifelines[resetTime] = LifelineStatus.used;
    }
    if (lifelines[skip] == LifelineStatus.using) {
      lifelines[skip] = LifelineStatus.used;
    }
    setState(() {});
  }

  void changeQuestion() {
    questionAnimationController.forward(from: 0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
        markLifeLineUsed();
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted;
  }

  Map<String, LifelineStatus> getLifeLines() {
    if (widget.quizType == QuizTypes.quizZone ||
        widget.quizType == QuizTypes.dailyQuiz) {
      return lifelines;
    }
    return {};
  }

  void updateTotalSecondsToCompleteQuiz() {
    final configCubit = context.read<SystemConfigCubit>();
    totalSecondsToCompleteQuiz =
        totalSecondsToCompleteQuiz +
        UiUtils.timeTakenToSubmitAnswer(
          animationControllerValue: timerAnimationController.value,
          quizTimer: configCubit.quizTimer(widget.quizType),
        );
  }

  //update answer locally and on cloud
  Future<void> submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop(canceled: false);
    if (!context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted) {
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
        context.read<QuestionsCubit>().questions()[currentQuestionIndex].id,
        submittedAnswer,
        context.read<UserDetailsCubit>().getUserFirebaseId(),
      );
      updateTotalSecondsToCompleteQuiz();
      await timerAnimationController.reverse();
      //change question
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );

      if (currentQuestionIndex !=
          (context.read<QuestionsCubit>().questions().length - 1)) {
        changeQuestion();
        //if quizType is not audio or latex(math or chemistry) then start timer again
        if (widget.quizType == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.mathMania) {
          timerAnimationController.value = 0.0;
          await showOptionAnimationController.forward();
        } else {
          await timerAnimationController.forward(from: 0);
        }
      } else {
        markLifeLineUsed();
        navigateToResultScreen();
      }
    }
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer('-1');
    } else if (status == AnimationStatus.forward) {
      if (widget.quizType == QuizTypes.audioQuestions) {
        showOptionAnimationController.reverse();
      }
    }
  }

  bool hasEnoughCoinsForLifeline(BuildContext context) {
    final currentCoins = int.parse(
      context.read<UserDetailsCubit>().getCoins()!,
    );
    //cost of using lifeline is 5 coins
    if (currentCoins < context.read<SystemConfigCubit>().lifelinesDeductCoins) {
      return false;
    }
    return true;
  }

  Widget _buildShowOptionButton() {
    if (widget.quizType == QuizTypes.audioQuestions) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: showOptionAnimation.drive<Offset>(
            Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: context.height * 0.025,
              left: context.width * UiUtils.hzMarginPct,
              right: context.width * UiUtils.hzMarginPct,
            ),
            child: CustomRoundedButton(
              widthPercentage: context.width,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: context.tr(showOptionsKey),
              titleColor: Theme.of(context).colorScheme.surface,
              onTap: () {
                if (!showOptionAnimationController.isAnimating) {
                  showOptionAnimationController.reverse();
                  audioQuestionContainerKeys[currentQuestionIndex].currentState!
                      .changeShowOption();
                  timerAnimationController.forward(from: 0);
                }
              },
              showBorder: false,
              radius: 8,
              height: 40,
              elevation: 5,
              fontWeight: FontWeight.w600,
              textSize: 18,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildLifelineContainer({
    required String title,
    required String icon,
    VoidCallback? onTap,
  }) {
    final onTertiary = Theme.of(context).colorScheme.onTertiary;

    return GestureDetector(
      onTap:
          title == fiftyFifty &&
              context
                      .read<QuestionsCubit>()
                      .questions()[currentQuestionIndex]
                      .answerOptions!
                      .length ==
                  2
          ? () {
              context.showSnack(context.tr('notAvailable')!);
            }
          : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTertiary.withValues(alpha: 0.6)),
        ),
        width: isSmallDevice ? 65.0 : 75.0,
        height: isSmallDevice ? 45.0 : 55.0,
        padding: const EdgeInsets.all(11),
        child: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            lifelines[title] == LifelineStatus.unused
                ? onTertiary
                : onTertiary.withValues(alpha: 0.6),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    context
        .showDialog<void>(
          title: context.tr('quizExitTitle'),
          message: context.tr('quizExitLbl'),
          image: Assets.quitQuizIcon,
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            context
              ..shouldPop()
              ..shouldPop();
          },
        )
        .then((_) {
          isExitDialogOpen = false;
          if (widget.quizType == QuizTypes.quizZone) {
            if (widget.subcategoryId == '0' || widget.subcategoryId == '') {
              context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                widget.categoryId,
                '0',
                quizType: QuizTypes.quizZone,
              );
            } else {
              context.read<SubCategoryCubit>().fetchSubCategory(
                widget.categoryId,
              );
            }
          }
        });
  }

  void _addCoinsAfterRewardAd() {
    final rewardAdsCoins = context.read<SystemConfigCubit>().rewardAdsCoins;

    context.read<UserDetailsCubit>().updateCoins(
      addCoin: true,
      coins: rewardAdsCoins,
    );
    context.read<UpdateCoinsCubit>().updateCoins(
      coins: rewardAdsCoins,
      addCoin: true,
      type: watchedRewardAdKey,
      title: watchedRewardAdKey,
    );

    timerAnimationController.forward(from: timerAnimationController.value);
  }

  void showAdDialog() {
    // Hide Ads in Premium Category/Subcategory.
    if (widget.isPremiumCategory) return;

    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      context.showSnack(
        context.tr(convertErrorCodeToLanguageKey(errorCodeNotEnoughCoins))!,
      );
      return;
    }
    //stop timer
    timerAnimationController.stop();
    showWatchAdDialog(
      context,
      onConfirm: () {
        context.read<RewardedAdCubit>().showAd(
          context: context,
          onAdDismissedCallback: _addCoinsAfterRewardAd,
        );
      },
      onCancel: () {
        //pass true to start timer
        context.shouldPop(true);
      },
    ).then((startTimer) {
      //if user do not want to see ad
      if (startTimer != null && startTimer) {
        timerAnimationController.forward(from: timerAnimationController.value);
      }
    });
  }

  bool get isSmallDevice => MediaQuery.sizeOf(context).width <= 360;

  Widget _buildLifeLines() {
    if (widget.quizType == QuizTypes.dailyQuiz ||
        widget.quizType == QuizTypes.quizZone) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(
          bottom: context.height * (isSmallDevice ? .015 : .025),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (context
                    .read<QuestionsCubit>()
                    .questions()[currentQuestionIndex]
                    .answerOptions!
                    .length !=
                2) ...[
              _buildLifelineContainer(
                onTap: () {
                  if (lifelines[fiftyFifty] == LifelineStatus.unused) {
                    /// Can't use 50/50 and audience poll one after one.
                    if (lifelines[audiencePoll] == LifelineStatus.using) {
                      context.showSnack(
                        context.tr('cantUseFiftyFiftyAfterPoll')!,
                      );
                    } else {
                      if (context.read<UserDetailsCubit>().removeAds()) {
                        setState(() {
                          lifelines[fiftyFifty] = LifelineStatus.using;
                        });
                        return;
                      }

                      if (hasEnoughCoinsForLifeline(context)) {
                        if (context
                                .read<QuestionsCubit>()
                                .questions()[currentQuestionIndex]
                                .answerOptions!
                                .length ==
                            2) {
                          context.showSnack(
                            context.tr('notAvailable')!,
                          );
                        } else {
                          final lifeLineDeductCoins = context
                              .read<SystemConfigCubit>()
                              .lifelinesDeductCoins;
                          //deduct coins for using lifeline
                          context.read<UserDetailsCubit>().updateCoins(
                            addCoin: false,
                            coins: lifeLineDeductCoins,
                          );
                          //mark fiftyFifty lifeline as using

                          setState(() {
                            lifelines[fiftyFifty] = LifelineStatus.using;
                          });
                        }
                      } else {
                        showAdDialog();
                      }
                    }
                  } else {
                    context.showSnack(
                      context.tr(
                        convertErrorCodeToLanguageKey(errorCodeLifeLineUsed),
                      )!,
                    );
                  }
                },
                title: fiftyFifty,
                icon: Assets.fiftyFiftyLifeline,
              ),
              _buildLifelineContainer(
                onTap: () {
                  if (lifelines[audiencePoll] == LifelineStatus.unused) {
                    /// Can't use 50/50 and audience poll one after one.
                    if (lifelines[fiftyFifty] == LifelineStatus.using) {
                      context.showSnack(
                        context.tr('cantUsePollAfterFiftyFifty')!,
                      );
                    } else {
                      if (context.read<UserDetailsCubit>().removeAds()) {
                        setState(() {
                          lifelines[audiencePoll] = LifelineStatus.using;
                        });
                        return;
                      }
                      if (hasEnoughCoinsForLifeline(context)) {
                        final lifeLineDeductCoins = context
                            .read<SystemConfigCubit>()
                            .lifelinesDeductCoins;
                        //deduct coins for using lifeline
                        context.read<UserDetailsCubit>().updateCoins(
                          addCoin: false,
                          coins: lifeLineDeductCoins,
                        );
                        setState(() {
                          lifelines[audiencePoll] = LifelineStatus.using;
                        });
                      } else {
                        showAdDialog();
                      }
                    }
                  } else {
                    context.showSnack(
                      context.tr(
                        convertErrorCodeToLanguageKey(errorCodeLifeLineUsed),
                      )!,
                    );
                  }
                },
                title: audiencePoll,
                icon: Assets.audiencePollLifeline,
              ),
            ],
            _buildLifelineContainer(
              onTap: () {
                if (lifelines[resetTime] == LifelineStatus.unused) {
                  if (context.read<UserDetailsCubit>().removeAds()) {
                    setState(() {
                      lifelines[resetTime] = LifelineStatus.using;
                    });
                    timerAnimationController
                      ..stop()
                      ..forward(from: 0);
                    return;
                  }
                  if (hasEnoughCoinsForLifeline(context)) {
                    final lifeLineDeductCoins = context
                        .read<SystemConfigCubit>()
                        .lifelinesDeductCoins;
                    //deduct coins for using lifeline
                    context.read<UserDetailsCubit>().updateCoins(
                      addCoin: false,
                      coins: lifeLineDeductCoins,
                    );
                    //mark fiftyFifty lifeline as using

                    setState(() {
                      lifelines[resetTime] = LifelineStatus.using;
                    });
                    timerAnimationController
                      ..stop()
                      ..forward(from: 0);
                  } else {
                    showAdDialog();
                  }
                } else {
                  context.showSnack(
                    context.tr(
                      convertErrorCodeToLanguageKey(errorCodeLifeLineUsed),
                    )!,
                  );
                }
              },
              title: resetTime,
              icon: Assets.resetTimeLifeline,
            ),
            if (context.read<QuestionsCubit>().questions().length > 1) ...[
              _buildLifelineContainer(
                onTap: () {
                  if (lifelines[skip] == LifelineStatus.unused) {
                    if (context.read<UserDetailsCubit>().removeAds()) {
                      setState(() {
                        lifelines[skip] = LifelineStatus.using;
                      });
                      submitAnswer('0');
                      return;
                    }
                    if (hasEnoughCoinsForLifeline(context)) {
                      //deduct coins for using lifeline
                      context.read<UserDetailsCubit>().updateCoins(
                        addCoin: false,
                        coins: 5,
                      );

                      setState(() {
                        lifelines[skip] = LifelineStatus.using;
                      });
                      submitAnswer('0');
                    } else {
                      showAdDialog();
                    }
                  } else {
                    context.showSnack(
                      context.tr(
                        convertErrorCodeToLanguageKey(errorCodeLifeLineUsed),
                      )!,
                    );
                  }
                },
                title: skip,
                icon: Assets.skipQueLifeline,
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Duration get timer =>
      timerAnimationController.duration! -
      (timerAnimationController.lastElapsedDuration ?? Duration.zero);

  String get remaining =>
      "${timer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timer.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();

    return BlocListener<UpdateCoinsCubit, UpdateCoinsState>(
      listener: (context, state) {
        if (state is UpdateCoinsFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            timerAnimationController.stop();
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      child: BlocConsumer<QuestionsCubit, QuestionsState>(
        bloc: quesCubit,
        listener: (_, state) {
          if (state is QuestionsFetchSuccess) {
            if (state.questions.isNotEmpty) {
              if (currentQuestionIndex == 0 &&
                  !state.questions[currentQuestionIndex].attempted) {
                if (widget.quizType == QuizTypes.audioQuestions) {
                  for (final _ in state.questions) {
                    audioQuestionContainerKeys.add(
                      GlobalKey<AudioQuestionContainerState>(),
                    );
                  }

                  //
                  showOptionAnimationController.forward();
                  questionContentAnimationController.forward();
                  //add audio question container keys
                }
                //
                else if (widget.quizType == QuizTypes.mathMania) {
                  questionContentAnimationController.forward();
                } else {
                  timerAnimationController.forward();
                  questionContentAnimationController.forward();
                }
              }
            }
          } else if (state is QuestionsFetchFailure) {
            if (state.errorMessage == errorCodeUnauthorizedAccess) {
              showAlreadyLoggedInDialog(context);
            }
          }
        },
        builder: (context, state) {
          if (state is QuestionsFetchInProgress || state is QuestionsInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressContainer()),
            );
          }
          if (state is QuestionsFetchFailure) {
            return Scaffold(
              appBar: const QAppBar(title: SizedBox(), roundedAppBar: false),
              body: Center(
                child: ErrorContainer(
                  showBackButton: true,
                  errorMessage: convertErrorCodeToLanguageKey(
                    state.errorMessage,
                  ),
                  showRTryButton:
                      widget.showRetryButton &&
                      convertErrorCodeToLanguageKey(state.errorMessage) !=
                          dailyQuizAlreadyPlayedKey,
                  onTapRetry: _getQuestions,
                  showErrorImage: true,
                ),
              ),
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;

              onTapBackButton();
            },
            child: Scaffold(
              appBar: QAppBar(
                onTapBackButton: onTapBackButton,
                roundedAppBar: false,
                title: widget.quizType == QuizTypes.funAndLearn
                    ? AnimatedBuilder(
                        builder: (context, c) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiary.withValues(alpha: 0.4),
                              width: 4,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            remaining,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        animation: timerAnimationController,
                      )
                    : TextCircularTimer(
                        animationController: timerAnimationController,
                        arcColor: Theme.of(context).primaryColor,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiary.withValues(alpha: 0.2),
                      ),
              ),
              body: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: QuestionsContainer(
                      audioQuestionContainerKeys: audioQuestionContainerKeys,
                      quizType: widget.quizType,
                      answerMode: context.read<SystemConfigCubit>().answerMode,
                      lifeLines: getLifeLines(),
                      timerAnimationController: timerAnimationController,
                      topPadding:
                          context.height *
                          UiUtils.getQuestionContainerTopPaddingPercentage(
                            context.height,
                          ),
                      hasSubmittedAnswerForCurrentQuestion:
                          hasSubmittedAnswerForCurrentQuestion,
                      questions: context.read<QuestionsCubit>().questions(),
                      submitAnswer: submitAnswer,
                      questionContentAnimation: questionContentAnimation,
                      questionScaleDownAnimation: questionScaleDownAnimation,
                      questionScaleUpAnimation: questionScaleUpAnimation,
                      questionSlideAnimation: questionSlideAnimation,
                      currentQuestionIndex: currentQuestionIndex,
                      questionAnimationController: questionAnimationController,
                      questionContentAnimationController:
                          questionContentAnimationController,
                      guessTheWordQuestions: const [],
                      guessTheWordQuestionContainerKeys: const [],
                      level: widget.level,
                    ),
                  ),
                  _buildLifeLines(),
                  _buildShowOptionButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
