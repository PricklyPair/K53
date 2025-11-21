import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/models/user_profile.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehension_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/user_battle_room_details.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/review_answers_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radial_result_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.isPlayed,
    required this.comprehension,
    required this.isPremiumCategory,
    super.key,
    this.exam,
    this.playWithBot,
    this.correctExamAnswers,
    this.incorrectExamAnswers,
    this.obtainedMarks,
    this.timeTakenToCompleteQuiz,
    this.battleRoom,
    this.questions,
    this.unlockedLevel,
    this.quizType,
    this.subcategoryMaxLevel,
    this.guessTheWordQuestions,
    this.entryFee,
    this.categoryId,
    this.subcategoryId,
    this.lifelines = const [],
    this.totalHintUsed,
    this.matchId,
  });

  final QuizTypes? quizType;
  final List<Question>? questions;
  final BattleRoom? battleRoom;
  final bool? playWithBot;
  final Comprehension comprehension;
  final List<GuessTheWordQuestion>? guessTheWordQuestions;
  final int? entryFee;
  final String? subcategoryMaxLevel;
  final int? unlockedLevel;
  final double? timeTakenToCompleteQuiz;
  final Exam? exam;
  final int? obtainedMarks;
  final int? correctExamAnswers;
  final int? incorrectExamAnswers;
  final String? categoryId;
  final String? subcategoryId;
  final bool isPlayed;
  final bool isPremiumCategory;
  final List<String> lifelines;
  final int? totalHintUsed;
  final String? matchId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SetCoinScoreCubit()),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: ResultScreen(
          battleRoom: args['battleRoom'] as BattleRoom?,
          categoryId: args['categoryId'] as String? ?? '',
          comprehension:
              args['comprehension'] as Comprehension? ?? Comprehension.empty(),
          correctExamAnswers: args['correctExamAnswers'] as int?,
          entryFee: args['entryFee'] as int?,
          exam: args['exam'] as Exam?,
          guessTheWordQuestions:
              args['guessTheWordQuestions'] as List<GuessTheWordQuestion>?,
          incorrectExamAnswers: args['incorrectExamAnswers'] as int?,
          isPlayed: args['isPlayed'] as bool? ?? true,
          obtainedMarks: args['obtainedMarks'] as int?,
          playWithBot: args['play_with_bot'] as bool?,
          questions: args['questions'] as List<Question>?,
          quizType: args['quizType'] as QuizTypes?,
          subcategoryId: args['subcategoryId'] as String? ?? '',
          subcategoryMaxLevel: args['subcategoryMaxLevel'] as String?,
          timeTakenToCompleteQuiz: args['timeTakenToCompleteQuiz'] as double?,
          unlockedLevel: args['unlockedLevel'] as int?,
          isPremiumCategory: args['isPremiumCategory'] as bool? ?? false,
          lifelines: args['lifelines'] as List<String>? ?? const [],
          totalHintUsed: args['totalHintUsed'] as int?,
          matchId: args['matchId'] as String?,
        ),
      ),
    );
  }

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isWinner = false;

  bool _displayedAlreadyLoggedInDialog = false;

  late final UserProfile userProfile = context
      .read<UserDetailsCubit>()
      .getUserProfile();
  late final String userProfileUrl = userProfile.profileUrl ?? '';
  late final String userName = userProfile.name ?? '';

  /// THIS is only for Self Challenge and Exam
  /// we need to calculate things locally,
  // as we don't give out any coins, score, nor update the statistics.
  late final String _userFirebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  int get totalQuestions => widget.quizType == QuizTypes.exam
      ? widget.correctExamAnswers! + widget.incorrectExamAnswers!
      : widget.questions?.length ?? 0;

  int get correctAnswers {
    if (widget.quizType == QuizTypes.exam) return widget.correctExamAnswers!;

    if (widget.questions == null) return 0;

    return widget.questions!.where((question) {
      final ans = AnswerEncryption.decryptCorrectAnswer(
        rawKey: _userFirebaseId,
        correctAnswer: question.correctAnswer!,
      );

      return question.submittedAnswerId == ans;
    }).length;
  }

  int get wrongAnswers => widget.quizType == QuizTypes.exam
      ? widget.incorrectExamAnswers!
      : totalQuestions - correctAnswers;

  double get winPercentage => widget.quizType == QuizTypes.exam
      ? (widget.obtainedMarks! * 100) / int.parse(widget.exam!.totalMarks)
      : (correctAnswers * 100) / totalQuestions;

  /// --- End

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!widget.isPremiumCategory) {
        context.read<InterstitialAdCubit>().showAd(context);
      }

      if (widget.quizType == QuizTypes.selfChallenge) {
        setState(() {
          _isWinner =
              winPercentage >
              context.read<SystemConfigCubit>().quizWinningPercentage;
        });
      }

      await _updateResult();

      await fetchUpdateUserDetails();
    });
  }

  Future<void> _updateResult() async {
    // We are calculating and showing result locally for exam and self challenge
    // so no need to call api for updating result.
    if (widget.quizType case QuizTypes.selfChallenge || QuizTypes.exam) return;

    final type = switch (widget.quizType) {
      QuizTypes.dailyQuiz => '1.1',
      QuizTypes.trueAndFalse => '1.2',
      QuizTypes.randomBattle => '1.3',
      QuizTypes.oneVsOneBattle => '1.4',
      QuizTypes.contest => 'contest',
      _ => widget.quizType!.typeValue!,
    };

    final playedQuestion = switch (widget.quizType) {
      QuizTypes.oneVsOneBattle || QuizTypes.randomBattle => {
        'user1_id': widget.battleRoom!.user1!.uid,
        'user2_id': widget.battleRoom!.user2!.uid,
        'user1_data': widget.battleRoom!.user1!.answers,
        'user2_data': widget.battleRoom!.user2!.answers,
      },
      QuizTypes.guessTheWord =>
        widget.guessTheWordQuestions!
            .map(
              (q) => <String, String>{
                'id': q.id,
                'answer': q.submittedAnswer.join(),
              },
            )
            .toList(),
      _ =>
        widget.questions!
            .map(
              (q) => <String, String>{
                'id': q.id!,
                'answer': q.submittedAnswerId,
              },
            )
            .toList(),
    };

    final categoryId = switch (widget.quizType) {
      QuizTypes.guessTheWord => widget.guessTheWordQuestions?.first.category,
      QuizTypes.dailyQuiz || QuizTypes.trueAndFalse => '',
      _ => widget.questions?.first.categoryId,
    };

    await context.read<SetCoinScoreCubit>().setCoinScore(
      categoryId: categoryId,
      quizType: type,
      playedQuestions: playedQuestion,
      lifelines: widget.lifelines,
      subcategoryId: widget.subcategoryId,
      playWithBot: widget.playWithBot,
      noOfHintUsed: widget.totalHintUsed,
      matchId: widget.matchId,
    );
  }

  Future<void> fetchUpdateUserDetails() async {
    await context.read<UserDetailsCubit>().fetchUserDetails();
  }

  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.funAndLearn &&
        _isWinner &&
        !widget.comprehension.isPlayed) {
      context.read<ComprehensionCubit>().getComprehension(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: widget.questions!.first.subcategoryId! == '0'
            ? 'category'
            : 'subcategory',
        typeId: widget.questions!.first.subcategoryId! == '0'
            ? widget.questions!.first.categoryId!
            : widget.questions!.first.subcategoryId!,
      );
    } else if (widget.quizType == QuizTypes.audioQuestions &&
        _isWinner &&
        !widget.isPlayed) {
      //
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(
            QuizTypes.audioQuestions,
          ),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.questions!.first.categoryId!,
        );
      }
    } else if (widget.quizType == QuizTypes.guessTheWord &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.guessTheWordQuestions!.first.subcategory == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(
            QuizTypes.guessTheWord,
          ),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.guessTheWordQuestions!.first.category,
        );
      }
    } else if (widget.quizType == QuizTypes.mathMania &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.mathMania),
        );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
          widget.questions!.first.categoryId!,
        );
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (widget.subcategoryId == '') {
        context.read<UnlockedLevelCubit>().fetchUnlockLevel(
          widget.categoryId!,
          '0',
          quizType: QuizTypes.quizZone,
        );
      } else {
        context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
      }
    } else if (widget.quizType == QuizTypes.contest) {
      context.read<ContestCubit>().getContest(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
      );
    }
  }

  Widget _buildGreetingMessage({
    int? scorePct,
    String? userName,
    bool? isWinner,
    bool? isDraw,
  }) {
    final String title;
    final String message;

    if (widget.quizType == QuizTypes.oneVsOneBattle ||
        widget.quizType == QuizTypes.randomBattle) {
      (title, message) = switch ((isWinner, isDraw)) {
        // Win
        (true, false) => ('victoryLbl', 'congratulationsLbl'),
        // Lose
        (false, false) => ('defeatLbl', 'betterNextLbl'),
        // Draw
        (false, true) => ('matchDrawLbl', ''),
        _ => throw Exception('Match cannot be drawn and won'),
      };
    } else if (widget.quizType == QuizTypes.exam) {
      title = widget.exam!.title;
      message = examResultKey;
    } else {
      (title, message) = switch (scorePct!) {
        <= 30 => (goodEffort, keepLearning),
        <= 50 => (wellDone, makingProgress),
        <= 70 => (greatJob, closerToMastery),
        <= 90 => (excellentWork, keepGoing),
        _ => (fantasticJob, achievedMastery),
      };
    }

    final titleStyle = TextStyle(
      fontSize: 26,
      color: context.primaryTextColor,
      fontWeight: FontWeights.bold,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.quizType == QuizTypes.exam
                      ? title
                      : context.tr(title)!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              if (widget.quizType != QuizTypes.exam &&
                  widget.quizType != QuizTypes.oneVsOneBattle &&
                  widget.quizType != QuizTypes.randomBattle) ...[
                Flexible(
                  child: Text(
                    " ${userName!.split(' ').first}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          alignment: Alignment.center,
          width: context.shortestSide * .85,
          child: Text(
            context.tr(message)!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, color: context.primaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
    String title,
    String icon,
    EdgeInsetsGeometry margin,
  ) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: context.width * 0.2125,
      height: 32,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              context.primaryTextColor,
              BlendMode.srcIn,
            ),
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: context.primaryTextColor,
              fontWeight: FontWeights.bold,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualResultContainer() {
    return BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          if (widget.quizType
              case QuizTypes.oneVsOneBattle || QuizTypes.randomBattle) {
            final currUserId = context.read<UserDetailsCubit>().userId();

            // Delete room
            if (state.userRanks.first.userId == currUserId) {
              context.read<BattleRoomCubit>().deleteBattleRoom();
            }
          }
        }
      },
      builder: (context, state) {
        if (state is SetCoinScoreSuccess) {
          final confetti = _isWinner ? Assets.winConfetti : Assets.loseConfetti;

          ///
          return Stack(
            clipBehavior: Clip.none,
            children: [
              /// Confetti
              Align(
                alignment: Alignment.topCenter,
                child: Lottie.asset(confetti, fit: BoxFit.fill),
              ),

              /// User Details
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    var verticalSpacePercentage = 0.0;
                    final mh = constraints.maxHeight;
                    final mw = constraints.maxWidth;

                    if (constraints.maxHeight <
                        UiUtils.profileHeightBreakPointResultScreen) {
                      verticalSpacePercentage = 0.015;
                    } else {
                      verticalSpacePercentage = 0.035;
                    }

                    return Column(
                      children: [
                        _buildGreetingMessage(
                          scorePct: state.percentage,
                          userName: userName,
                        ),
                        SizedBox(height: mh * verticalSpacePercentage),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QImage.circular(
                              imageUrl: userProfileUrl,
                              width: mw * .30,
                              height: mw * .30,
                            ),
                            SvgPicture.asset(
                              Assets.hexagonFrame,
                              width: mw * .37,
                              height: mw * .37,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// Correct Answer
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                  '${state.correctAnswer}/${state.totalQuestions}',
                  Assets.correct,
                  const EdgeInsetsDirectional.only(start: 15, bottom: 60),
                ),
              ),

              /// Incorrect Answer
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                  '${state.totalQuestions - state.correctAnswer}/${state.totalQuestions}',
                  Assets.wrong,
                  const EdgeInsetsDirectional.only(start: 15, bottom: 20),
                ),
              ),

              /// Score
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  '${state.earnScore}',
                  Assets.score,
                  const EdgeInsetsDirectional.only(end: 15, bottom: 60),
                ),
              ),

              /// Coins
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  '${state.earnCoin}',
                  Assets.earnedCoin,
                  const EdgeInsetsDirectional.only(end: 15, bottom: 20),
                ),
              ),

              /// Radial Percentage
              Align(
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final mh = constraints.maxHeight;
                    final double radialSizePercentage;
                    if (mh < UiUtils.profileHeightBreakPointResultScreen) {
                      radialSizePercentage = 0.4;
                    } else {
                      radialSizePercentage = 0.325;
                    }

                    return Transform.translate(
                      offset: const Offset(0, 15),
                      child: RadialPercentageResultContainer(
                        percentage: state.percentage.toDouble(),
                        timeTakenToCompleteQuizInSeconds: widget
                            .timeTakenToCompleteQuiz
                            ?.toInt(),
                        size: Size(
                          mh * radialSizePercentage,
                          mh * radialSizePercentage,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is SetCoinScoreFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessageColor: context.primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.error),
              onTapRetry: () async {
                await _updateResult();
              },
              showErrorImage: true,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildSelfChallengeOrExamResultContainer() {
    final confetti = _isWinner ? Assets.winConfetti : Assets.loseConfetti;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Confetti
        Align(
          alignment: Alignment.topCenter,
          child: Lottie.asset(confetti, fit: BoxFit.fill),
        ),

        /// User Details
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              var verticalSpacePercentage = 0.0;
              final mh = constraints.maxHeight;
              final mw = constraints.maxWidth;

              var radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                radialSizePercentage = 0.525;
              }

              return Column(
                children: [
                  _buildGreetingMessage(
                    scorePct: winPercentage.toInt(),
                    userName: userName,
                  ),
                  SizedBox(height: mh * verticalSpacePercentage),

                  if (widget.quizType == QuizTypes.exam) ...[
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: RadialPercentageResultContainer(
                        percentage: winPercentage,
                        timeTakenToCompleteQuizInSeconds: widget
                            .timeTakenToCompleteQuiz
                            ?.toInt(),
                        size: Size(
                          mh * radialSizePercentage,
                          mh * radialSizePercentage,
                        ),
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Text(
                        '${widget.obtainedMarks}/${widget.exam!.totalMarks} ${context.tr(markKey)!}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(
                            context,
                          ).textScaler.scale(22),
                          fontWeight: FontWeight.w400,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QImage.circular(
                          imageUrl: userProfileUrl,
                          width: mw * .30,
                          height: mw * .30,
                        ),
                        SvgPicture.asset(
                          Assets.hexagonFrame,
                          width: mw * .37,
                          height: mw * .37,
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        /// Correct Answer
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: _buildResultDataWithIconContainer(
            '$correctAnswers/$totalQuestions',
            Assets.correct,
            const EdgeInsetsDirectional.only(end: 15, bottom: 30),
          ),
        ),

        /// Incorrect Answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
            '$wrongAnswers/$totalQuestions',
            Assets.wrong,
            const EdgeInsetsDirectional.only(start: 15, bottom: 30),
          ),
        ),

        if (widget.quizType == QuizTypes.selfChallenge)
          Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mh = constraints.maxHeight;
                final double radialSizePercentage;
                if (mh < UiUtils.profileHeightBreakPointResultScreen) {
                  radialSizePercentage = 0.4;
                } else {
                  radialSizePercentage = 0.325;
                }

                return Transform.translate(
                  offset: const Offset(0, 15),
                  child: RadialPercentageResultContainer(
                    percentage: winPercentage,
                    timeTakenToCompleteQuizInSeconds: widget
                        .timeTakenToCompleteQuiz
                        ?.toInt(),
                    size: Size(
                      mh * radialSizePercentage,
                      mh * radialSizePercentage,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBattleResultDetails() {
    return BlocBuilder<SetCoinScoreCubit, SetCoinScoreState>(
      builder: (context, state) {
        if (state is SetCoinScoreSuccess) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final coinsString = widget.entryFee! > 0
                  ? " ${state.isWinner ? state.winnerCoins : widget.entryFee} ${context.tr("coinsLbl")!}"
                  : '';

              final BattleUserData winnerUserData;
              final BattleUserData loserUserData;
              final UserBattleRoomDetails winnerDetails;
              final UserBattleRoomDetails loserDetails;

              if (state.isDraw) {
                winnerUserData = state.user1Data!;
                loserUserData = state.user2Data!;
                winnerDetails = widget.battleRoom!.user1!;
                loserDetails = widget.battleRoom!.user2!;
              } else {
                final isUser1Winner = state.user1Id == state.winnerUserId;
                winnerUserData = isUser1Winner
                    ? state.user1Data!
                    : state.user2Data!;
                loserUserData = isUser1Winner
                    ? state.user2Data!
                    : state.user1Data!;
                winnerDetails = isUser1Winner
                    ? widget.battleRoom!.user1!
                    : widget.battleRoom!.user2!;
                loserDetails = isUser1Winner
                    ? widget.battleRoom!.user2!
                    : widget.battleRoom!.user1!;
              }

              return Column(
                children: [
                  _buildGreetingMessage(
                    isWinner: state.isWinner,
                    isDraw: state.isDraw,
                  ),

                  /// Status, You Won or You Lost
                  if (!state.isDraw)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: state.isWinner
                              ? context.primaryColor.withValues(alpha: 0.2)
                              : context.primaryTextColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${context.tr(state.isWinner ? 'youWonLbl' : 'youLostLbl')!}$coinsString",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: state.isWinner
                                ? context.primaryColor
                                : context.primaryTextColor,
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  QImage.circular(
                                    width: 80,
                                    height: 80,
                                    imageUrl: winnerDetails.profileUrl,
                                  ),
                                  const QImage(
                                    imageUrl: Assets.hexagonFrame,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                winnerDetails.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 16,
                                  color: context.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${winnerUserData.points} ${context.tr('scoreLbl')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: context.primaryColor,
                                  ),
                                ),
                              ),
                              if (winnerUserData.quickestBonus > 0 ||
                                  winnerUserData.secondQuickestBonus > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${winnerUserData.quickestBonus + winnerUserData.secondQuickestBonus} ${context.tr('speedBonus')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 12,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                '${winnerUserData.correctAnswers} / ${state.totalQuestions} ${context.tr("correctAnswersLbl")}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 12,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vs
                        const SizedBox(width: 4),
                        const Expanded(
                          child: QImage(
                            imageUrl: Assets.versus,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  QImage.circular(
                                    width: 80,
                                    height: 80,
                                    imageUrl: loserDetails.profileUrl,
                                  ),
                                  QImage(
                                    imageUrl: Assets.hexagonFrame,
                                    width: 100,
                                    height: 100,
                                    color: context.primaryTextColor,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loserDetails.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 16,
                                  color: context.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryTextColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${loserUserData.points} ${context.tr('scoreLbl')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                              if (loserUserData.quickestBonus > 0 ||
                                  loserUserData.secondQuickestBonus > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${loserUserData.quickestBonus + loserUserData.secondQuickestBonus} ${context.tr('speedBonus')}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 12,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                '${loserUserData.correctAnswers} / ${state.totalQuestions} ${context.tr("correctAnswersLbl")}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 12,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }

        if (state is SetCoinScoreFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.error),
              onTapRetry: () async {
                await _updateResult();
              },
              showErrorImage: true,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildResultContainer(BuildContext context) {
    return BlocListener<SetCoinScoreCubit, SetCoinScoreState>(
      listener: (context, state) {
        if (state is SetCoinScoreSuccess) {
          setState(() {
            _isWinner =
                state.percentage >
                context.read<SystemConfigCubit>().quizWinningPercentage;
          });
        }
      },
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          height: context.height * 0.56,
          width: context.width * 0.9,
          decoration: BoxDecoration(
            color: _isWinner
                ? context.surfaceColor
                : context.primaryTextColor.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: switch (widget.quizType) {
            QuizTypes.oneVsOneBattle ||
            QuizTypes.randomBattle => _buildBattleResultDetails(),
            QuizTypes.selfChallenge ||
            QuizTypes.exam => _buildSelfChallengeOrExamResultContainer(),
            _ => _buildIndividualResultContainer(),
          },
        ),
      ),
    );
  }

  Widget _buildButton(String buttonTitle, VoidCallback onTap) {
    return CustomRoundedButton(
      widthPercentage: 0.90,
      backgroundColor: context.primaryColor,
      buttonTitle: buttonTitle,
      radius: 8,
      elevation: 5,
      showBorder: false,
      fontWeight: FontWeights.regular,
      height: 50,
      titleColor: context.surfaceColor,
      onTap: onTap,
      textSize: 20,
    );
  }

  //play again button will be build different for every quizType
  Widget _buildPlayAgainButton() {
    if (widget.quizType == QuizTypes.audioQuestions) {
      return _buildButton(context.tr('playAgainBtn')!, () {
        fetchUpdateUserDetails();
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            'isPlayed': widget.isPlayed,
            'quizType': QuizTypes.audioQuestions,
            'subcategoryId': widget.questions!.first.subcategoryId == '0'
                ? ''
                : widget.questions!.first.subcategoryId,
            'categoryId': widget.questions!.first.subcategoryId == '0'
                ? widget.questions!.first.categoryId
                : '',
          },
        );
      });
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      if (_isWinner) {
        return const SizedBox();
      }

      return _buildButton(context.tr('playAgainBtn')!, () async {
        await context.pushReplacementNamed(
          Routes.guessTheWord,
          arguments: GuessTheWordQuizScreenArgs(
            categoryId: widget.categoryId!,
            subcategoryId: widget.subcategoryId!.isNotEmpty
                ? widget.subcategoryId
                : null,
            isPlayed: widget.isPlayed,
            isPremiumCategory: widget.isPremiumCategory,
          ),
        );
      });
    } else if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        final maxLevel = int.parse(widget.subcategoryMaxLevel!);
        final currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return const SizedBox.shrink();
        }
        return _buildButton(
          context.tr('nextLevelBtn')!,
          () {
            //if given level is same as unlocked level then we need to update level
            //else do not update level
            final unlockedLevel =
                int.parse(widget.questions!.first.level!) ==
                    widget.unlockedLevel
                ? (widget.unlockedLevel! + 1)
                : widget.unlockedLevel;
            //play quiz for next level
            Navigator.of(context).pushReplacementNamed(
              Routes.quiz,
              arguments: {
                'quizType': widget.quizType,
                //if subcategory id is empty for question means we need to fetch question by it's category
                'categoryId': widget.categoryId,
                'subcategoryId': widget.subcategoryId,
                'level': (currentLevel + 1).toString(),
                //increase level
                'subcategoryMaxLevel': widget.subcategoryMaxLevel,
                'unlockedLevel': unlockedLevel,
              },
            );
          },
        );
      }
      //if user failed to complete this level
      return _buildButton(context.tr('playAgainBtn')!, () {
        fetchUpdateUserDetails();
        //to play this level again (for quizZone quizType)
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            'quizType': widget.quizType,
            //if subcategory id is empty for question means we need to fetch questions by it's category
            'categoryId': widget.categoryId,
            'subcategoryId': widget.subcategoryId,
            'level': widget.questions!.first.level,
            'unlockedLevel': widget.unlockedLevel,
            'subcategoryMaxLevel': widget.subcategoryMaxLevel,
          },
        );
      });
    }

    return const SizedBox.shrink();
  }

  Widget _buildShareYourScoreButton() {
    return Builder(
      builder: (context) {
        return _buildButton(context.tr('shareScoreBtn')!, () async {
          try {
            //capturing image
            final image = await screenshotController.capture();
            //root directory path
            final directory = (await getApplicationDocumentsDirectory()).path;

            final fileName = DateTime.now().microsecondsSinceEpoch.toString();
            //create file with given path
            final file = await File('$directory/$fileName.png').create();
            //write as bytes
            await file.writeAsBytes(image!.buffer.asUint8List());

            final appLink = context.read<SystemConfigCubit>().appUrl;

            final referralCode =
                context.read<UserDetailsCubit>().getUserProfile().referCode ??
                '';

            final scoreText =
                '$kAppName'
                "\n${context.tr('myScoreLbl')!}"
                "\n${context.tr("appLink")!}"
                '\n$appLink'
                "\n${context.tr("useMyReferral")} $referralCode ${context.tr("toGetCoins")}";

            await UiUtils.share(
              scoreText,
              files: [XFile(file.path)],
              context: context,
            ).onError((e, s) => ShareResult('$e', ShareResultStatus.dismissed));
          } on Exception catch (_) {
            if (!mounted) return;

            context.showSnack(
              context.tr(
                convertErrorCodeToLanguageKey(errorCodeDefaultMessage),
              )!,
            );
          }
        });
      },
    );
  }

  bool _unlockedReviewAnswersOnce = false;

  Widget _buildReviewAnswersButton() {
    Future<void> onTapYesReviewAnswers() async {
      final reviewAnswersDeductCoins = context
          .read<SystemConfigCubit>()
          .reviewAnswersDeductCoins;
      //check if user has enough coins
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) <
          reviewAnswersDeductCoins) {
        await showNotEnoughCoinsDialog(context);
        return;
      }

      /// update coins
      await context
          .read<UpdateCoinsCubit>()
          .updateCoins(
            coins: reviewAnswersDeductCoins,
            addCoin: false,
            title: reviewAnswerLbl,
          )
          .then((_) async {
            final state = context.read<UpdateCoinsCubit>().state;
            if (state is UpdateCoinsFailure) {
              context
                ..shouldPop()
                ..showSnack(
                  context.tr(
                        convertErrorCodeToLanguageKey(state.errorMessage),
                      ) ??
                      context.tr(errorCodeDefaultMessage)!,
                );
              return;
            } else if (state is UpdateCoinsSuccess) {
              context.read<UserDetailsCubit>().updateCoins(
                addCoin: false,
                coins: reviewAnswersDeductCoins,
              );

              _unlockedReviewAnswersOnce = true;
              await context.pushNamed(
                Routes.reviewAnswers,
                arguments: ReviewAnswersScreenArgs(
                  quizType: widget.quizType!,
                  questions: widget.quizType == QuizTypes.guessTheWord
                      ? []
                      : widget.questions!,
                  guessTheWordQuestions:
                      widget.quizType == QuizTypes.guessTheWord
                      ? widget.guessTheWordQuestions!
                      : [],
                ),
              );
            }
          });
    }

    return _buildButton(context.tr('reviewAnsBtn')!, () async {
      if (_unlockedReviewAnswersOnce) {
        await context.pushNamed(
          Routes.reviewAnswers,
          arguments: ReviewAnswersScreenArgs(
            quizType: widget.quizType!,
            questions: widget.quizType == QuizTypes.guessTheWord
                ? []
                : widget.questions!,
            guessTheWordQuestions: widget.quizType == QuizTypes.guessTheWord
                ? widget.guessTheWordQuestions!
                : [],
          ),
        );
        return;
      }

      await context.showDialog<void>(
        title: context.tr('reviewAnswers'),
        image: Assets.coinsDialogIcon,
        message:
            '${context.tr('spend')} ${context.read<SystemConfigCubit>().reviewAnswersDeductCoins} ${context.tr('reviewAnsMessage')}',
        onConfirm: onTapYesReviewAnswers,
        confirmButtonText: context.tr('reviewAndImprove'),
        cancelButtonText: context.tr('notNow'),
      );
    });
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      fetchUpdateUserDetails();
      globalCtx.pushNamedAndRemoveUntil(Routes.home, predicate: (_) => false);
      dashboardScreenKey.currentState?.changeTab(NavTabType.home);
    }

    return _buildButton(context.tr('homeBtn')!, onTapHomeButton);
  }

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (widget.quizType! == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.guessTheWord ||
            widget.quizType == QuizTypes.quizZone) ...[
          _buildPlayAgainButton(),
          buttonSpace,
        ],
        if (widget.quizType == QuizTypes.quizZone ||
            widget.quizType == QuizTypes.dailyQuiz ||
            widget.quizType == QuizTypes.trueAndFalse ||
            widget.quizType == QuizTypes.selfChallenge ||
            widget.quizType == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.guessTheWord ||
            widget.quizType == QuizTypes.funAndLearn ||
            widget.quizType == QuizTypes.mathMania) ...[
          _buildReviewAnswersButton(),
          buttonSpace,
        ],
        _buildShareYourScoreButton(),
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  late final String _appbarTitle = context.tr(switch (widget.quizType) {
    QuizTypes.selfChallenge => 'selfChallengeResult',
    QuizTypes.audioQuestions => 'audioQuizResult',
    QuizTypes.mathMania => 'mathQuizResult',
    QuizTypes.guessTheWord => 'guessTheWordResult',
    QuizTypes.exam => 'examResult',
    QuizTypes.dailyQuiz => 'dailyQuizResult',
    QuizTypes.randomBattle => 'randomBattleResult',
    QuizTypes.oneVsOneBattle => 'oneVsOneBattleResult',
    QuizTypes.funAndLearn => 'funAndLearnResult',
    QuizTypes.trueAndFalse => 'truefalseQuizResult',
    QuizTypes.bookmarkQuiz => 'bookmarkQuizResult',
    _ => 'quizResultLbl',
  })!;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (context.read<UserDetailsCubit>().state
            is UserDetailsFetchInProgress) {
          return;
        }

        onPageBackCalls();
        context.shouldPop();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateCoinsCubit, UpdateCoinsState>(
            listener: (context, state) {
              if (state is UpdateCoinsFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            title: Text(_appbarTitle),
            onTapBackButton: () {
              onPageBackCalls();
              Navigator.pop(context);
            },
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(child: _buildResultContainer(context)),
                const SizedBox(height: 20),
                _buildResultButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
