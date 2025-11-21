import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/bookmark/bookmark_repository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/update_bookmark_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/guess_the_word_quiz_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/questions_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audio_question_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guess_the_word_question_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/questions_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BookmarkQuizScreen extends StatefulWidget {
  const BookmarkQuizScreen({required this.quizType, super.key});

  final QuizTypes quizType;

  @override
  State<BookmarkQuizScreen> createState() => _BookmarkQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<QuestionsCubit>(
            create: (_) => QuestionsCubit(QuizRepository()),
          ),
          BlocProvider<GuessTheWordQuizCubit>(
            create: (_) => GuessTheWordQuizCubit(QuizRepository()),
          ),
          BlocProvider<UpdateBookmarkCubit>(
            create: (_) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
        ],
        child: BookmarkQuizScreen(
          quizType: routeSettings.arguments! as QuizTypes,
        ),
      ),
    );
  }
}

class _BookmarkQuizScreenState extends State<BookmarkQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController =
      PreserveAnimationController(
        duration: Duration(
          seconds: context.read<SystemConfigCubit>().quizTimer(
            QuizTypes.bookmarkQuiz,
          ),
        ),
      )..addStatusListener(currentUserTimerAnimationStatusListener);
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;
  int currentQuestionIndex = 0;

  bool completedQuiz = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  late List<GlobalKey<GuessTheWordQuestionContainerState>>
  guessTheWordQuestionContainerKeys = [];

  late List<GlobalKey<AudioQuestionContainerState>> audioQuestionContainerKeys =
      [];

  late AnimationController showOptionAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  void _getQuestions() {
    /// Fetch Questions from Local Bookmark Cubits to Questions Cubit
    Future.delayed(Duration.zero, () {
      if (widget.quizType == QuizTypes.audioQuestions) {
        final bookmarkedQuestions = context
            .read<AudioQuestionBookmarkCubit>()
            .questions()
            .map((e) => e.copyWith(submittedAnswer: '', attempted: false))
            .toList(growable: false);

        context.read<QuestionsCubit>().updateState(
          QuestionsFetchSuccess(
            questions: bookmarkedQuestions,
            quizType: QuizTypes.bookmarkQuiz,
          ),
        );

        for (final _ in bookmarkedQuestions) {
          audioQuestionContainerKeys.add(
            GlobalKey<AudioQuestionContainerState>(),
          );
        }
      } else if (widget.quizType == QuizTypes.quizZone) {
        final bookmarkedQuestions = context
            .read<BookmarkCubit>()
            .questions()
            .map((e) => e.copyWith(submittedAnswer: '', attempted: false))
            .toList(growable: false);

        context.read<QuestionsCubit>().updateState(
          QuestionsFetchSuccess(
            questions: bookmarkedQuestions,
            quizType: QuizTypes.bookmarkQuiz,
          ),
        );
        timerAnimationController.forward();
      } else {
        final bookmarkedQuestions = context
            .read<GuessTheWordBookmarkCubit>()
            .questions()
            .map((e) => e.copyWith(hasAnswerGiven: false))
            .toList(growable: false);

        context.read<GuessTheWordQuizCubit>().updateState(
          GuessTheWordQuizFetchSuccess(
            questions: bookmarkedQuestions,
            noOfHintUsed: 0,
          ),
        );

        for (final _ in bookmarkedQuestions) {
          guessTheWordQuestionContainerKeys.add(
            GlobalKey<GuessTheWordQuestionContainerState>(),
          );
        }
        timerAnimationController.forward();
      }
    });
  }

  @override
  void initState() {
    initializeAnimation();
    _getQuestions();
    super.initState();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
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

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //change to next Question
  void changeQuestion() {
    questionAnimationController.forward(from: 0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    //
    // ignore: avoid_bool_literals_in_conditional_expressions
    return widget.quizType == QuizTypes.guessTheWord
        ? false
        : context
              .read<QuestionsCubit>()
              .questions()[currentQuestionIndex]
              .attempted;
  }

  Future<void> submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();
    if (!context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted) {
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
        context.read<QuestionsCubit>().questions()[currentQuestionIndex].id,
        submittedAnswer,
        context.read<UserDetailsCubit>().getUserFirebaseId(),
      ); //change question
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );
      if (currentQuestionIndex !=
          (context.read<QuestionsCubit>().questions().length - 1)) {
        changeQuestion();
        if (widget.quizType == QuizTypes.quizZone) {
          await timerAnimationController.forward(from: 0);
        } else {
          timerAnimationController.value = 0.0;
        }
      } else {
        setState(() {
          completedQuiz = true;
        });
      }
    }
  }

  Future<void> submitGuessTheWordAnswer(List<String> submittedAnswer) async {
    timerAnimationController.stop();
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    //if answer not submitted then submit answer
    if (!guessTheWordQuizCubit
        .getQuestions()[currentQuestionIndex]
        .hasAnswered) {
      //submitted answer
      guessTheWordQuizCubit.submitAnswer(
        guessTheWordQuizCubit.getQuestions()[currentQuestionIndex].id,
        submittedAnswer,
        0,
      );
      //wait for some seconds
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );
      //if currentQuestion is last then complete quiz to result screen
      if (currentQuestionIndex ==
          (guessTheWordQuizCubit.getQuestions().length - 1)) {
        //
        setState(() {
          completedQuiz = true;
        });
      } else {
        //change question
        changeQuestion();
        await timerAnimationController.forward(from: 0);
      }
    }
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer('-1');
    }
  }

  @override
  void dispose() {
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    showOptionAnimationController.dispose();
    super.dispose();
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

  Widget _buildQuestions() {
    if (widget.quizType == QuizTypes.guessTheWord) {
      return BlocConsumer<GuessTheWordQuizCubit, GuessTheWordQuizState>(
        bloc: context.read<GuessTheWordQuizCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GuessTheWordQuizFetchInProgress ||
              state is GuessTheWordQuizInitial) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            );
          }
          if (state is GuessTheWordQuizFetchFailure) {
            return Center(
              child: ErrorContainer(
                showBackButton: true,
                errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
                onTapRetry: () {
                  _getQuestions();
                },
                showErrorImage: true,
              ),
            );
          }
          final questions = (state as GuessTheWordQuizFetchSuccess).questions;

          return Align(
            alignment: Alignment.topCenter,
            child: QuestionsContainer(
              showGuessTheWordHint: false,
              timerAnimationController: timerAnimationController,
              quizType: widget.quizType,
              topPadding:
                  context.height *
                  UiUtils.getQuestionContainerTopPaddingPercentage(
                    context.height,
                  ),
              answerMode: AnswerMode.showAnswerCorrectnessAndCorrectAnswer,
              lifeLines: const {},
              hasSubmittedAnswerForCurrentQuestion: () {
                return false;
              },
              questions: const [],
              submitAnswer: (_) {},
              questionContentAnimation: questionContentAnimation,
              questionScaleDownAnimation: questionScaleDownAnimation,
              questionScaleUpAnimation: questionScaleUpAnimation,
              questionSlideAnimation: questionSlideAnimation,
              currentQuestionIndex: currentQuestionIndex,
              questionAnimationController: questionAnimationController,
              questionContentAnimationController:
                  questionContentAnimationController,
              guessTheWordQuestions: questions,
              guessTheWordQuestionContainerKeys:
                  guessTheWordQuestionContainerKeys,
            ),
          );
        },
      );
    }
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      bloc: context.read<QuestionsCubit>(),
      builder: (context, state) {
        if (state is QuestionsFetchInProgress || state is QuestionsInitial) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        }
        if (state is QuestionsFetchFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: true,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: () {
                _getQuestions();
              },
              showErrorImage: true,
            ),
          );
        }
        final questions = (state as QuestionsFetchSuccess).questions;

        return Align(
          alignment: Alignment.topCenter,
          child: QuestionsContainer(
            audioQuestionContainerKeys: audioQuestionContainerKeys,
            timerAnimationController: timerAnimationController,
            quizType: widget.quizType,
            topPadding:
                context.height *
                UiUtils.getQuestionContainerTopPaddingPercentage(
                  context.height,
                ),
            answerMode: AnswerMode.showAnswerCorrectnessAndCorrectAnswer,
            lifeLines: const {},
            hasSubmittedAnswerForCurrentQuestion:
                hasSubmittedAnswerForCurrentQuestion,
            questions: questions,
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
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    if (widget.quizType == QuizTypes.guessTheWord) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: context.height * 0.025),
          child: CustomRoundedButton(
            widthPercentage: 0.5,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: context.tr('submitBtn')!.toUpperCase(),
            elevation: 5,
            shadowColor: Colors.black45,
            titleColor: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
            onTap: () {
              submitGuessTheWordAnswer(
                guessTheWordQuestionContainerKeys[currentQuestionIndex]
                    .currentState!
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
    if (widget.quizType == QuizTypes.audioQuestions) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1.5))
              .animate(
                CurvedAnimation(
                  parent: showOptionAnimationController,
                  curve: Curves.easeInOut,
                ),
              ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: context.height * 0.025,
              left: context.width * 0.2,
              right: context.width * 0.2,
            ),
            child: CustomRoundedButton(
              widthPercentage: context.width * 0.5,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: context.tr(showOptionsKey),
              radius: 5,
              onTap: () {
                if (!showOptionAnimationController.isAnimating) {
                  showOptionAnimationController.reverse();
                  audioQuestionContainerKeys[currentQuestionIndex].currentState!
                      .changeShowOption();
                  timerAnimationController.forward(from: 0);
                }
              },
              titleColor: Theme.of(context).colorScheme.surface,
              showBorder: false,
              height: 40,
              elevation: 5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: completedQuiz,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        onTapBackButton();
      },
      child: Scaffold(
        appBar: const QAppBar(roundedAppBar: false, title: SizedBox()),
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: completedQuiz
                  ? Align(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${context.tr("completeAllQueLbl")!} (:",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 18,
                              fontWeight: FontWeights.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.width * 0.3,
                            ),
                            child: CustomRoundedButton(
                              widthPercentage: context.width * 0.3,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              buttonTitle: context.tr('goBAckLbl'),
                              titleColor: Theme.of(context).primaryColor,
                              radius: 5,
                              showBorder: false,
                              elevation: 5,
                              onTap: () {
                                if (isSettingDialogOpen) {
                                  Navigator.of(context).pop();
                                }
                                if (isExitDialogOpen) {
                                  Navigator.of(context).pop();
                                }

                                Navigator.of(context).pop();
                              },
                              height: 35,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildQuestions(),
            ),
            if (!completedQuiz)
              _buildBottomButton()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
