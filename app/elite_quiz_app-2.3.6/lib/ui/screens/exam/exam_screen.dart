import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/exam/cubits/exam_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/exam_question_status_bottom_sheet_container.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/exam_timer_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/question_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/latex_answer_options_list.dart';
import 'package:flutterquiz/ui/widgets/option_container.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();

  static Route<ExamScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (context) => const ExamScreen());
  }
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  final timerKey = GlobalKey<ExamTimerContainerState>();

  late final pageController = PageController();

  Timer? canGiveExamAgainTimer;
  bool canGiveExamAgain = true;

  late int canGiveExamAgainTimeInSeconds = context
      .read<SystemConfigCubit>()
      .resumeExamAfterCloseTimeout;

  bool isExitDialogOpen = false;
  bool userLeftTheExam = false;

  bool showYouLeftTheExam = false;
  bool isExamQuestionStatusBottomSheetOpen = false;

  int currentQuestionIndex = 0;

  late bool isScreenRecordingInIos = false;

  List<String> iosCapturedScreenshotQuestionIds = [];

  late final bool isExamLatexModeEnabled = context
      .read<SystemConfigCubit>()
      .isLatexEnabled(QuizTypes.exam);

  @override
  void initState() {
    super.initState();

    //wake lock enable so phone will not lock automatically after sometime

    WakelockPlus.enable();

    WidgetsBinding.instance.addObserver(this);

    //start timer
    Future.delayed(Duration.zero, () {
      timerKey.currentState?.startTimer();
    });
  }

  void iosScreenshotCallback() {
    iosCapturedScreenshotQuestionIds.add(
      context.read<ExamCubit>().getQuestions()[currentQuestionIndex].id!,
    );
  }

  void iosScreenRecordCallback({required bool isRecording}) {
    setState(() => isScreenRecordingInIos = isRecording);
  }

  void setCanGiveExamTimer() {
    canGiveExamAgainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (canGiveExamAgainTimeInSeconds == 0) {
        timer.cancel();

        //can give exam again false
        canGiveExamAgain = false;

        //show user left the exam
        setState(() => showYouLeftTheExam = true);
        //submit result
        submitResult();
      } else {
        canGiveExamAgainTimeInSeconds--;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.paused) {
      setCanGiveExamTimer();
    } else if (appState == AppLifecycleState.resumed) {
      canGiveExamAgainTimer?.cancel();
      //if user can give exam again
      if (canGiveExamAgain) {
        canGiveExamAgainTimeInSeconds = context
            .read<SystemConfigCubit>()
            .resumeExamAfterCloseTimeout;
      }
    }
  }

  @override
  void dispose() {
    canGiveExamAgainTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  void showExamQuestionStatusBottomSheet() {
    isExamQuestionStatusBottomSheetOpen = true;
    showModalBottomSheet<void>(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => ExamQuestionStatusBottomSheetContainer(
        navigateToResultScreen: navigateToResultScreen,
        pageController: pageController,
      ),
    ).then((_) => isExamQuestionStatusBottomSheetOpen = false);
  }

  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<ExamCubit>()
        .getQuestions()[currentQuestionIndex]
        .attempted;
  }

  void submitResult() {
    context.read<ExamCubit>().submitResult(
      capturedQuestionIds: iosCapturedScreenshotQuestionIds,
      rulesViolated: iosCapturedScreenshotQuestionIds.isNotEmpty,
      userId: context.read<UserDetailsCubit>().getUserFirebaseId(),
      totalDuration:
          timerKey.currentState?.secondsTookToCompleteExam().toString() ?? '0',
    );
  }

  void submitAnswer(String submittedAnswerId) {
    final examCubit = context.read<ExamCubit>();
    if (hasSubmittedAnswerForCurrentQuestion()) {
      if (examCubit.canUserSubmitAnswerAgainInExam()) {
        examCubit.updateQuestionWithAnswer(
          examCubit.getQuestions()[currentQuestionIndex].id!,
          submittedAnswerId,
        );
      }
    } else {
      examCubit.updateQuestionWithAnswer(
        examCubit.getQuestions()[currentQuestionIndex].id!,
        submittedAnswerId,
      );
    }
  }

  void navigateToResultScreen() {
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    if (isExamQuestionStatusBottomSheetOpen) {
      Navigator.of(context).pop();
    }

    submitResult();

    final userFirebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();
    final examCubit = context.read<ExamCubit>();
    Navigator.of(context).pushReplacementNamed(
      Routes.result,
      arguments: {
        'quizType': QuizTypes.exam,
        'exam': examCubit.getExam(),
        'obtainedMarks': examCubit.obtainedMarks(userFirebaseId),
        'timeTakenToCompleteQuiz': timerKey.currentState
            ?.secondsTookToCompleteExam()
            .toDouble(),
        'correctExamAnswers': examCubit.correctAnswers(userFirebaseId),
        'incorrectExamAnswers': examCubit.incorrectAnswers(userFirebaseId),
        'numberOfPlayer': 1,
      },
    );
  }

  Widget _buildBottomMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            child: Opacity(
              opacity: currentQuestionIndex != 0 ? 1.0 : 0.5,
              child: IconButton(
                onPressed: () {
                  if (currentQuestionIndex != 0) {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            padding: const EdgeInsets.only(left: 42, right: 48),
            child: IconButton(
              onPressed: showExamQuestionStatusBottomSheet,
              icon: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Theme.of(context).colorScheme.surface,
                size: 40,
              ),
            ),
          ),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            child: Opacity(
              opacity:
                  (context.read<ExamCubit>().getQuestions().length - 1) !=
                      currentQuestionIndex
                  ? 1.0
                  : 0.5,
              child: IconButton(
                onPressed: () {
                  if (context.read<ExamCubit>().getQuestions().length - 1 !=
                      currentQuestionIndex) {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouLeftTheExam() {
    if (showYouLeftTheExam) {
      return Align(
        child: Container(
          width: context.width,
          height: context.height,
          alignment: Alignment.center,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          child: AlertDialog(
            content: Text(
              context.tr(youLeftTheExamKey)!,
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(okayLbl)!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildQuestions() {
    return BlocBuilder<ExamCubit, ExamState>(
      bloc: context.read<ExamCubit>(),
      builder: (context, state) {
        if (state is ExamFetchSuccess) {
          return PageView.builder(
            onPageChanged: (index) {
              setState(() => currentQuestionIndex = index);
            },
            controller: pageController,
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: state.questions[index].correctAnswer!,
              );

              final constraints = BoxConstraints(
                maxWidth: context.width * 0.85,
                maxHeight: context.height * 0.785,
              );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    QuestionContainer(
                      isMathQuestion: isExamLatexModeEnabled,
                      questionColor: Theme.of(context).colorScheme.onTertiary,
                      questionNumber: index + 1,
                      question: state.questions[index],
                    ),
                    const SizedBox(height: 25),
                    if (isExamLatexModeEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LatexAnswerOptions(
                          hasSubmittedAnswerForCurrentQuestion:
                              hasSubmittedAnswerForCurrentQuestion,
                          submitAnswer: submitAnswer,
                          answerMode: AnswerMode.noAnswerCorrectness,
                          constraints: constraints,
                          correctAnswerId: correctAnswerId,
                          showAudiencePoll: false,
                          audiencePollPercentages: const [],
                          answerOptions: state.questions[index].answerOptions!,
                          submittedAnswerId:
                              state.questions[index].submittedAnswerId,
                        ),
                      )
                    else
                      ...state.questions[index].answerOptions!.map(
                        (option) => OptionContainer(
                          quizType: QuizTypes.exam,
                          answerMode: AnswerMode.noAnswerCorrectness,
                          showAudiencePoll: false,
                          hasSubmittedAnswerForCurrentQuestion:
                              hasSubmittedAnswerForCurrentQuestion,
                          constraints: constraints,
                          answerOption: option,
                          correctOptionId: correctAnswerId,
                          submitAnswer: submitAnswer,
                          submittedAnswerId:
                              state.questions[index].submittedAnswerId,
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: showYouLeftTheExam,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        onTapBackButton();
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: ExamTimerContainer(
            navigateToResultScreen: navigateToResultScreen,
            examDurationInMinutes: int.parse(
              context.read<ExamCubit>().getExam().duration,
            ),
            key: timerKey,
          ),
          onTapBackButton: onTapBackButton,
        ),
        body: Stack(
          children: [
            _buildQuestions(),
            Align(alignment: Alignment.bottomCenter, child: _buildBottomMenu()),
            _buildYouLeftTheExam(),
            if (isScreenRecordingInIos)
              SizedBox(
                width: context.width,
                height: context.height,
                child: const ColoredBox(color: Colors.black),
              ),
          ],
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
          cancelButtonText: context.tr('leaveAnyways'),
          confirmButtonText: context.tr('keepPlaying'),
          onCancel: () {
            submitResult();
            context
              ..shouldPop()
              ..shouldPop();
          },
        )
        .then((_) => isExitDialogOpen = false);
  }
}
