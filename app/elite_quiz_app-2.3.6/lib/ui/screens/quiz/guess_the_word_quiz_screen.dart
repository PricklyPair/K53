import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/guess_the_word_quiz_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guess_the_word_question_container.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/questions_container.dart';
import 'package:flutterquiz/ui/widgets/text_circular_timer.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

final class GuessTheWordQuizScreenArgs extends RouteArgs {
  const GuessTheWordQuizScreenArgs({
    required this.categoryId,
    required this.isPlayed,
    required this.isPremiumCategory,
    this.subcategoryId,
  });

  final String categoryId;
  final String? subcategoryId;
  final bool isPlayed;
  final bool isPremiumCategory;
}

class GuessTheWordQuizScreen extends StatefulWidget {
  const GuessTheWordQuizScreen({required this.args, super.key});

  final GuessTheWordQuizScreenArgs args;

  @override
  State<GuessTheWordQuizScreen> createState() => _GuessTheWordQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<GuessTheWordQuizScreenArgs>();

    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<GuessTheWordQuizCubit>(
            create: (_) => GuessTheWordQuizCubit(QuizRepository()),
          ),
        ],
        child: GuessTheWordQuizScreen(args: args),
      ),
    );
  }
}

class _GuessTheWordQuizScreenState extends State<GuessTheWordQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController timerAnimationController =
      PreserveAnimationController(
        duration: Duration(
          seconds: context.read<SystemConfigCubit>().quizTimer(
            QuizTypes.guessTheWord,
          ),
        ),
      )..addStatusListener(currentUserTimerAnimationStatusListener);

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;

  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;

  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;

  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;

  //to slude the question content from right to left
  late Animation<double> questionContentAnimation;

  int _currentQuestionIndex = 0;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  //
  double timeTakenToCompleteQuiz = 0;

  bool isExitDialogOpen = false;

  late List<GlobalKey<GuessTheWordQuestionContainerState>>
  questionContainerKeys = [];

  @override
  void initState() {
    super.initState();
    initializeAnimation();
    //fetching question for quiz
    _getQuestions();
  }

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<GuessTheWordQuizCubit>().getQuestion(
        questionLanguageId: UiUtils.getCurrentQuizLanguageId(context),
        type: widget.args.subcategoryId != null ? 'subcategory' : 'category',
        typeId: widget.args.subcategoryId ?? widget.args.categoryId,
      );
    });
  }

  @override
  void dispose() {
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    questionContentAnimationController.dispose();
    questionAnimationController.dispose();

    super.dispose();
  }

  void initializeAnimation() {
    questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
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
    questionScaleDownAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.5, 1, curve: Curves.easeOutQuad),
      ),
    );
    questionContentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionContentAnimationController,
        curve: Curves.easeInQuad,
      ),
    );
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer(
        questionContainerKeys[_currentQuestionIndex].currentState!
            .getSubmittedAnswer(),
      );
    }
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushReplacementNamed(
      Routes.result,
      arguments: {
        'categoryId': widget.args.categoryId,
        'subcategoryId': widget.args.subcategoryId,
        'quizType': QuizTypes.guessTheWord,
        'isPlayed': widget.args.isPlayed,
        'totalHintUsed': context.read<GuessTheWordQuizCubit>().noOfHintUsed,
        'isPremiumCategory': widget.args.isPremiumCategory,
        'timeTakenToCompleteQuiz': timeTakenToCompleteQuiz,
        'guessTheWordQuestions': context
            .read<GuessTheWordQuizCubit>()
            .getQuestions(),
      },
    );
  }

  Future<void> submitAnswer(List<String> submittedAnswer) async {
    timerAnimationController.stop();
    updateTimeTakenToCompleteQuiz();
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    //if answer not submitted then submit answer
    if (!guessTheWordQuizCubit
        .getQuestions()[_currentQuestionIndex]
        .hasAnswered) {
      //submitted answer
      guessTheWordQuizCubit.submitAnswer(
        guessTheWordQuizCubit.getQuestions()[_currentQuestionIndex].id,
        submittedAnswer,
        questionContainerKeys[_currentQuestionIndex].currentState!.noOfHintUsed,
      );
      //wait for some seconds
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );
      //if currentQuestion is last then move user to result screen
      if (_currentQuestionIndex ==
          (guessTheWordQuizCubit.getQuestions().length - 1)) {
        navigateToResultScreen();
      } else {
        //change question
        changeQuestion();
        await timerAnimationController.forward(from: 0);
      }
    }
  }

  void updateTimeTakenToCompleteQuiz() {
    timeTakenToCompleteQuiz =
        timeTakenToCompleteQuiz +
        UiUtils.timeTakenToSubmitAnswer(
          animationControllerValue: timerAnimationController.value,
          quizTimer: context.read<SystemConfigCubit>().quizTimer(
            QuizTypes.guessTheWord,
          ),
        );
  }

  //next question
  void changeQuestion() {
    questionAnimationController.forward(from: 0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        _currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //
  Widget _buildQuestions(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      builder: (context, state) {
        if (state is GuessTheWordQuizInitial ||
            state is GuessTheWordQuizFetchInProgress) {
          return const Center(
            child: CircularProgressContainer(whiteLoader: true),
          );
        }

        if (state is GuessTheWordQuizFetchSuccess) {
          return Align(
            alignment: Alignment.topCenter,
            child: QuestionsContainer(
              timerAnimationController: timerAnimationController,
              quizType: QuizTypes.guessTheWord,
              answerMode: AnswerMode.showAnswerCorrectness,
              lifeLines: const {},
              guessTheWordQuestionContainerKeys: questionContainerKeys,
              topPadding:
                  context.height *
                  UiUtils.getQuestionContainerTopPaddingPercentage(
                    context.height,
                  ),
              guessTheWordQuestions: state.questions,
              hasSubmittedAnswerForCurrentQuestion: () {
                return false;
              },
              questions: const [],
              submitAnswer: (_) {},
              questionContentAnimation: questionContentAnimation,
              questionScaleDownAnimation: questionScaleDownAnimation,
              questionScaleUpAnimation: questionScaleUpAnimation,
              questionSlideAnimation: questionSlideAnimation,
              currentQuestionIndex: _currentQuestionIndex,
              questionAnimationController: questionAnimationController,
              questionContentAnimationController:
                  questionContentAnimationController,
            ),
          );
        }

        if (state is GuessTheWordQuizFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).colorScheme.surface,
              showBackButton: true,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: _getQuestions,
              showErrorImage: true,
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSubmitButton(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      bloc: guessTheWordQuizCubit,
      builder: (context, state) {
        if (state is GuessTheWordQuizFetchSuccess) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: context.height * 0.025),
              child: CustomRoundedButton(
                widthPercentage: 0.5,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('submitBtn'),
                elevation: 5,
                shadowColor: Colors.black45,
                titleColor: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold,
                onTap: () {
                  //
                  submitAnswer(
                    questionContainerKeys[_currentQuestionIndex].currentState!
                        .getSubmittedAnswer(),
                  );
                },
                radius: 10,
                showBorder: false,
                height: 45,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    context
        .showDialog<void>(
          title: context.tr('quizExitTitle'),
          message: context.tr('quizExitLbl'),
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            context
              ..shouldPop()
              ..shouldPop();
          },
        )
        .then((_) => isExitDialogOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        onTapBackButton();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<GuessTheWordQuizCubit, GuessTheWordQuizState>(
            bloc: guessTheWordQuizCubit,
            listener: (context, state) {
              if (state is GuessTheWordQuizFetchSuccess) {
                if (_currentQuestionIndex == 0 &&
                    !state.questions[_currentQuestionIndex].hasAnswered) {
                  for (final _ in state.questions) {
                    questionContainerKeys.add(
                      GlobalKey<GuessTheWordQuestionContainerState>(),
                    );
                  }
                  //start timer
                  timerAnimationController.forward();
                  questionContentAnimationController.forward();
                }
              } else if (state is GuessTheWordQuizFetchFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
          ),
          BlocListener<UpdateCoinsCubit, UpdateCoinsState>(
            listener: (context, state) {
              if (state is UpdateCoinsFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  timerAnimationController.stop();
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            onTapBackButton: onTapBackButton,
            title: TextCircularTimer(
              animationController: timerAnimationController,
              arcColor: Theme.of(context).primaryColor,
              color: Theme.of(
                context,
              ).colorScheme.onTertiary.withValues(alpha: 0.2),
            ),
          ),
          body: Stack(
            children: [
              _buildQuestions(guessTheWordQuizCubit),
              _buildSubmitButton(guessTheWordQuizCubit),
            ],
          ),
        ),
      ),
    );
  }
}
