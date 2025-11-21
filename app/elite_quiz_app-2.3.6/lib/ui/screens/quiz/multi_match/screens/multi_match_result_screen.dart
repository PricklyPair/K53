import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_review_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radial_result_container.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

final class MultiMatchResultScreenArgs extends RouteArgs {
  const MultiMatchResultScreenArgs({
    required this.questions,
    required this.totalLevels,
    required this.unlockedLevel,
    required this.categoryId,
    required this.timeTakenToCompleteQuiz,
    required this.isPremiumCategory,
    this.subcategoryId,
  });

  final List<MultiMatchQuestion> questions;
  final int totalLevels;
  final int unlockedLevel;
  final String categoryId;
  final String? subcategoryId;
  final int timeTakenToCompleteQuiz;
  final bool isPremiumCategory;
}

class MultiMatchResultScreen extends StatefulWidget {
  const MultiMatchResultScreen({required this.args, super.key});

  final MultiMatchResultScreenArgs args;

  @override
  State<MultiMatchResultScreen> createState() => _MultiMatchResultScreenState();

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.args<MultiMatchResultScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          // For Updating Result
          BlocProvider(create: (_) => SetCoinScoreCubit()),
          // For Deducting coins for Review Answers
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: MultiMatchResultScreen(args: args),
      ),
    );
  }
}

class _MultiMatchResultScreenState extends State<MultiMatchResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  late final String userName = context.read<UserDetailsCubit>().getUserName();

  bool _isWinner = false;

  late final int _currLevel = int.parse(widget.args.questions.first.level);

  @override
  void initState() {
    super.initState();

    /// show ad
    Future.delayed(Duration.zero, () {
      if (!widget.args.isPremiumCategory) {
        context.read<InterstitialAdCubit>().showAd(context);
      }
    });

    Future.delayed(Duration.zero, () async {
      await _updateResult();
      await _fetchUserDetails();
    });
  }

  Future<void> _updateResult() async {
    final type = QuizTypes.multiMatch.typeValue!;

    final playedQuestions = widget.args.questions
        .map(
          (q) => <String, String>{
            'id': q.id,
            'answer': q.submittedIds.join(','),
          },
        )
        .toList();

    await context.read<SetCoinScoreCubit>().setCoinScore(
      categoryId: widget.args.categoryId,
      subcategoryId: widget.args.subcategoryId,
      quizType: type,
      playedQuestions: playedQuestions,
    );
  }

  Future<void> _fetchUserDetails() async {
    await context.read<UserDetailsCubit>().fetchUserDetails();
  }

  void _onBack() {
    if (widget.args.subcategoryId == null) {
      context.read<UnlockedLevelCubit>().fetchUnlockLevel(
        widget.args.categoryId,
        '',
        quizType: QuizTypes.multiMatch,
      );
    } else {
      context.read<SubCategoryCubit>().fetchSubCategory(widget.args.categoryId);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: Text(context.tr('multiMatchQuizResultLbl')!),
          onTapBackButton: _onBack,
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
    );
  }

  Widget _buildGreetingMessage(int scorePct, String userName) {
    final (title, message) = switch (scorePct) {
      <= 30 => (goodEffort, keepLearning),
      <= 50 => (wellDone, makingProgress),
      <= 70 => (greatJob, closerToMastery),
      <= 90 => (excellentWork, keepGoing),
      _ => (fantasticJob, achievedMastery),
    };

    final titleStyle = TextStyle(
      fontSize: 26,
      color: Theme.of(context).colorScheme.onTertiary,
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
              Text(
                context.tr(title)!,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              Flexible(
                child: Text(
                  " ${userName.split(' ').first}",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).primaryColor,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ),
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
            style: TextStyle(
              fontSize: 19,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultContainer(BuildContext context) {
    final userProfileUrl =
        context.read<UserDetailsCubit>().getUserProfile().profileUrl ?? '';

    return Screenshot(
      controller: screenshotController,
      child: BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
        listener: (context, state) {
          if (state is SetCoinScoreSuccess) {
            setState(() {
              _isWinner =
                  state.percentage >=
                  context.read<SystemConfigCubit>().quizWinningPercentage;
            });
          }
        },
        builder: (context, state) {
          if (state is SetCoinScoreFailure) {
            return Container(
              height: context.height * 0.560,
              width: context.width * 0.90,
              decoration: BoxDecoration(
                color: _isWinner
                    ? context.surfaceColor
                    : context.primaryTextColor.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: ErrorContainer(
                  showBackButton: true,
                  errorMessageColor: Theme.of(context).primaryColor,
                  errorMessage: convertErrorCodeToLanguageKey(state.error),
                  onTapRetry: () async {
                    await _updateResult();
                  },
                  showErrorImage: true,
                ),
              ),
            );
          }

          if (state is SetCoinScoreSuccess) {
            final confetti = _isWinner
                ? Assets.winConfetti
                : Assets.loseConfetti;

            return Container(
              height: context.height * 0.560,
              width: context.width * 0.90,
              decoration: BoxDecoration(
                color: _isWinner
                    ? context.surfaceColor
                    : context.primaryTextColor.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// Confetti
                  Align(
                    alignment: Alignment.topCenter,
                    child: Lottie.asset(confetti, fit: BoxFit.fill),
                  ),

                  /// Greeting and User Profile Image
                  Align(
                    alignment: Alignment.topCenter,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        var verticalSpacePercentage = 0.0;

                        if (constraints.maxHeight <
                            UiUtils.profileHeightBreakPointResultScreen) {
                          verticalSpacePercentage = 0.015;
                        } else {
                          verticalSpacePercentage = 0.035;
                        }

                        return Column(
                          children: [
                            _buildGreetingMessage(state.percentage, userName),
                            SizedBox(
                              height:
                                  constraints.maxHeight *
                                  verticalSpacePercentage,
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                QImage.circular(
                                  imageUrl: userProfileUrl,
                                  width: 107,
                                  height: 107,
                                ),
                                SvgPicture.asset(
                                  Assets.hexagonFrame,
                                  width: 132,
                                  height: 132,
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
                            timeTakenToCompleteQuizInSeconds:
                                widget.args.timeTakenToCompleteQuiz,
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
              ),
            );
          }

          return const Center(child: CircularProgressContainer());
        },
      ),
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
      titleColor: Theme.of(context).colorScheme.surface,
      onTap: onTap,
      textSize: 20,
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (_isWinner && _currLevel != widget.args.totalLevels) ...[
          _buildPlayNextLevelButton(),
          buttonSpace,
        ],
        if (!_isWinner) ...[_buildPlayAgainButton(), buttonSpace],
        _buildReviewAnswersButton(),
        buttonSpace,
        _buildShareYourScoreButton(),
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  Widget _buildPlayAgainButton() {
    return _buildButton(context.tr('playAgainBtn')!, () {
      context.pushReplacementNamed(
        Routes.multiMatchQuiz,
        arguments: MultiMatchQuizArgs(
          categoryId: widget.args.categoryId,
          subcategoryId: widget.args.subcategoryId,
          level: _currLevel.toString(),
          unlockedLevel: widget.args.unlockedLevel,
          totalLevels: widget.args.totalLevels,
          isPremiumCategory: widget.args.isPremiumCategory,
        ),
      );
    });
  }

  Widget _buildPlayNextLevelButton() {
    return _buildButton(context.tr('nextLevelBtn')!, () {
      final unlockedLevel = _currLevel == widget.args.unlockedLevel
          ? _currLevel + 1
          : widget.args.unlockedLevel;

      context.pushReplacementNamed(
        Routes.multiMatchQuiz,
        arguments: MultiMatchQuizArgs(
          categoryId: widget.args.categoryId,
          subcategoryId: widget.args.subcategoryId,
          level: (_currLevel + 1).toString(),
          unlockedLevel: unlockedLevel,
          totalLevels: widget.args.totalLevels,
          isPremiumCategory: widget.args.isPremiumCategory,
        ),
      );
    });
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
                Routes.multiMatchReviewScreen,
                arguments: MultiMatchReviewScreenArgs(
                  questions: widget.args.questions,
                ),
              );
            }
          });
    }

    return _buildButton(
      context.tr('reviewAnsBtn')!,
      () async {
        if (_unlockedReviewAnswersOnce) {
          await context.pushNamed(
            Routes.multiMatchReviewScreen,
            arguments: MultiMatchReviewScreenArgs(
              questions: widget.args.questions,
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
      },
    );
  }

  Widget _buildShareYourScoreButton() {
    Future<void> onTap() async {
      try {
        final image = await screenshotController.capture();
        final directory = (await getApplicationDocumentsDirectory()).path;

        final fileName = DateTime.now().microsecondsSinceEpoch.toString();
        final file = await File('$directory/$fileName.png').create();
        await file.writeAsBytes(image!.buffer.asUint8List());

        final appLink = context.read<SystemConfigCubit>().appUrl;

        final referralCode =
            context.read<UserDetailsCubit>().getUserProfile().referCode ?? '';

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
          context.tr(convertErrorCodeToLanguageKey(errorCodeDefaultMessage))!,
        );
      }
    }

    return Builder(
      builder: (context) {
        return _buildButton(context.tr('shareScoreBtn')!, onTap);
      },
    );
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      _fetchUserDetails();
      context.pushNamedAndRemoveUntil(Routes.home, predicate: (_) => false);
    }

    return _buildButton(context.tr('homeBtn')!, onTapHomeButton);
  }
}
