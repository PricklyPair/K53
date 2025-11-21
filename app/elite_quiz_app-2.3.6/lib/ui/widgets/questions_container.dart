import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/answer_option.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/utils/quiz_utils.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audio_question_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guess_the_word_question_container.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/latex_answer_options_list.dart';
import 'package:flutterquiz/ui/widgets/option_container.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/lifeline_options.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionsContainer extends StatefulWidget {
  const QuestionsContainer({
    required this.submitAnswer,
    required this.quizType,
    required this.guessTheWordQuestionContainerKeys,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.currentQuestionIndex,
    required this.guessTheWordQuestions,
    required this.questionAnimationController,
    required this.questionContentAnimationController,
    required this.questionContentAnimation,
    required this.questionScaleDownAnimation,
    required this.questionScaleUpAnimation,
    required this.questionSlideAnimation,
    required this.questions,
    required this.lifeLines,
    required this.timerAnimationController,
    required this.answerMode,
    super.key,
    this.showGuessTheWordHint,
    this.audioQuestionContainerKeys,
    this.level,
    this.topPadding,
  });

  final List<GlobalKey> guessTheWordQuestionContainerKeys;

  final List<GlobalKey>? audioQuestionContainerKeys;
  final QuizTypes quizType;
  final bool Function() hasSubmittedAnswerForCurrentQuestion;
  final int currentQuestionIndex;
  final void Function(String) submitAnswer;
  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
  final double? topPadding;
  final String? level;
  final Map<String, LifelineStatus> lifeLines;
  final AnswerMode answerMode;
  final AnimationController timerAnimationController;
  final bool? showGuessTheWordHint;

  @override
  State<QuestionsContainer> createState() => _QuestionsContainerState();
}

class _QuestionsContainerState extends State<QuestionsContainer> {
  List<AnswerOption> filteredOptions = [];
  List<int> audiencePollPercentages = [];

  late double textSize;

  late final bool _isLatex = context.read<SystemConfigCubit>().isLatexEnabled(
    widget.quizType,
  );

  @override
  void initState() {
    textSize = widget.quizType == QuizTypes.groupPlay
        ? 20
        : context.read<SettingsCubit>().getSettings().playAreaFontSize;
    super.initState();
  }

  int get totalQuestions => widget.questions.isNotEmpty
      ? widget.questions.length
      : widget.guessTheWordQuestions.length;

  var _usingAudiencePoll = false;
  var _usingFiftyFifty = false;

  Widget _buildOptions(Question question, BoxConstraints constraints) {
    final correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
      rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
      correctAnswer: question.correctAnswer!,
    );

    if (!question.attempted && widget.lifeLines.isNotEmpty) {
      _usingAudiencePoll =
          widget.lifeLines[audiencePoll] == LifelineStatus.using;
      _usingFiftyFifty = widget.lifeLines[fiftyFifty] == LifelineStatus.using;

      if (_usingAudiencePoll) {
        audiencePollPercentages = LifeLineOptions.getAudiencePollPercentage(
          question.answerOptions!,
          correctAnswerId,
        );
      }

      if (_usingFiftyFifty) {
        filteredOptions = LifeLineOptions.getFiftyFiftyOptions(
          question.answerOptions!,
          correctAnswerId,
        );
      }
    }

    ///
    if (_isLatex) {
      return LatexAnswerOptions(
        hasSubmittedAnswerForCurrentQuestion:
            widget.hasSubmittedAnswerForCurrentQuestion,
        submitAnswer: widget.submitAnswer,
        constraints: constraints,
        submittedAnswerId: question.submittedAnswerId,
        correctAnswerId: correctAnswerId,
        showAudiencePoll: _usingAudiencePoll,
        answerMode: widget.answerMode,
        audiencePollPercentages: audiencePollPercentages,
        answerOptions: _usingFiftyFifty
            ? filteredOptions
            : question.answerOptions!,
      );
    } else {
      return Column(
        children: (_usingFiftyFifty ? filteredOptions : question.answerOptions!)
            .map((option) {
              final idx = question.answerOptions!.indexOf(option);
              return OptionContainer(
                quizType: widget.quizType,
                submittedAnswerId: question.submittedAnswerId,
                answerMode: widget.answerMode,
                audiencePollPercentage: _usingAudiencePoll
                    ? audiencePollPercentages[idx]
                    : null,
                showAudiencePoll: _usingAudiencePoll,
                hasSubmittedAnswerForCurrentQuestion:
                    widget.hasSubmittedAnswerForCurrentQuestion,
                constraints: constraints,
                answerOption: option,
                correctOptionId: correctAnswerId,
                submitAnswer: widget.submitAnswer,
                trueFalseOption: question.questionType == '2',
              );
            })
            .toList(),
      );
    }
  }

  Widget _buildCurrentCoins() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      bloc: context.read<UserDetailsCubit>(),
      builder: (context, state) {
        if (state is UserDetailsFetchSuccess) {
          return Align(
            alignment: AlignmentDirectional.topEnd,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${context.tr("coinsLbl")!} : ",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onTertiary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '${state.userProfile.coins}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCurrentQuestionIndex() {
    final onTertiary = Theme.of(context).colorScheme.onTertiary;
    return Align(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.currentQuestionIndex + 1}',
              style: TextStyle(
                color: onTertiary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: ' / ${widget.questions.length}',
              style: TextStyle(color: onTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText({
    required String questionText,
    required String questionType,
  }) {
    return _isLatex
        ? TeXView(
            onRenderFinished: (_) {
              if (widget.quizType != QuizTypes.selfChallenge) {
                widget.timerAnimationController.forward();
              }
            },
            child: TeXViewDocument(questionText),
            style: TeXViewStyle(
              contentColor: Theme.of(context).colorScheme.onTertiary,
              sizeUnit: TeXViewSizeUnit.pixels,
              textAlign: TeXViewTextAlign.center,
              fontStyle: TeXViewFontStyle(fontSize: textSize.toInt() + 5),
            ),
          )
        : Text(
            questionText,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                height: 1.125,
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: textSize,
              ),
            ),
          );
  }

  Widget _buildQuestionContainer(
    double scale,
    int index,
    bool showContent,
    BuildContext context,
  ) {
    final child = LayoutBuilder(
      builder: (context, constraints) {
        if (widget.questions.isEmpty) {
          return GuessTheWordQuestionContainer(
            answerMode: widget.answerMode,
            showHint: widget.showGuessTheWordHint ?? true,
            timerAnimationController: widget.timerAnimationController,
            key: showContent
                ? widget.guessTheWordQuestionContainerKeys[widget
                      .currentQuestionIndex]
                : null,
            submitAnswer: widget.submitAnswer,
            constraints: constraints,
            currentQuestionIndex: widget.currentQuestionIndex,
            questions: widget.guessTheWordQuestions,
          );
        } else {
          if (widget.quizType == QuizTypes.audioQuestions) {
            return AudioQuestionContainer(
              answerMode: widget.answerMode,
              key: widget
                  .audioQuestionContainerKeys![widget.currentQuestionIndex],
              hasSubmittedAnswerForCurrentQuestion:
                  widget.hasSubmittedAnswerForCurrentQuestion,
              constraints: constraints,
              currentQuestionIndex: widget.currentQuestionIndex,
              questions: widget.questions,
              submitAnswer: widget.submitAnswer,
              timerAnimationController: widget.timerAnimationController,
            );
          }

          final question = widget.questions[index];

          final hasImage =
              question.imageUrl != null && question.imageUrl!.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.quizType == QuizTypes.oneVsOneBattle ||
                    widget.quizType == QuizTypes.groupPlay)
                  const SizedBox()
                else
                  const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.lifeLines.isNotEmpty) ...[_buildCurrentCoins()],
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox(),
                    ],
                    _buildCurrentQuestionIndex(),
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox(),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: _buildQuestionText(
                    questionText: question.question!,
                    questionType: question.questionType!,
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * (hasImage ? .0175 : .02),
                ),
                if (hasImage)
                  Container(
                    width: context.width,
                    height:
                        constraints.maxHeight *
                        (widget.quizType == QuizTypes.groupPlay ? 0.25 : 0.325),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      child: CachedNetworkImage(
                        placeholder: (_, _) =>
                            const Center(child: CircularProgressContainer()),
                        imageUrl: question.imageUrl!,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: widget.quizType == QuizTypes.groupPlay
                                    ? BoxFit.contain
                                    : BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                        errorWidget: (_, i, e) {
                          return Center(
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                SizedBox(height: constraints.maxHeight * .015),
                _buildOptions(question, constraints),
                const SizedBox(height: 5),
              ],
            ),
          );
        }
      },
    );

    return Container(
      transform: Matrix4.identity()..scaleByDouble(scale, scale, scale, 1),
      transformAlignment: Alignment.center,
      width: context.width * QuizUtils.questionContainerWidthPercentage,
      height:
          context.height *
          (QuizUtils.questionContainerHeightPercentage -
              0.045 * (widget.quizType == QuizTypes.groupPlay ? 1.0 : 0.0)),
      child: showContent
          ? SlideTransition(
              position: widget.questionContentAnimation.drive(
                Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero),
              ),
              child: FadeTransition(
                opacity: widget.questionContentAnimation,
                child: child,
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildQuestion(int questionIndex, BuildContext context) {
    //
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currentQuestionIndex == questionIndex) {
      return FadeTransition(
        opacity: widget.questionSlideAnimation.drive(
          Tween<double>(begin: 1, end: 0),
        ),
        child: SlideTransition(
          position: widget.questionSlideAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0)),
          ),
          child: _buildQuestionContainer(1, questionIndex, true, context),
        ),
      );
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95
    else if (questionIndex > widget.currentQuestionIndex &&
        (questionIndex == widget.currentQuestionIndex + 1)) {
      return AnimatedBuilder(
        animation: widget.questionAnimationController,
        builder: (context, child) {
          final scale =
              0.95 +
              widget.questionScaleUpAnimation.value -
              widget.questionScaleDownAnimation.value;
          return _buildQuestionContainer(scale, questionIndex, false, context);
        },
      );
    }
    //to build question except top 2
    else if (questionIndex > widget.currentQuestionIndex) {
      return _buildQuestionContainer(1, questionIndex, false, context);
    }
    //if the question is already animated that show empty container
    return const SizedBox();
  }

  //to build questions
  List<Widget> _buildQuestions(BuildContext context) {
    final children = <Widget>[];

    //loop terminate condition will be questions.length instead of 4
    for (var i = 0; i < totalQuestions; i++) {
      //add question
      children.add(_buildQuestion(i, context));
    }
    //need to reverse the list in order to display 1st question in top

    return children.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    //Font Size change Lister to change questions font size
    return BlocListener<SettingsCubit, SettingsState>(
      bloc: context.read<SettingsCubit>(),
      listener: (context, state) {
        if (state.settingsModel!.playAreaFontSize != textSize) {
          setState(() {
            textSize = context
                .read<SettingsCubit>()
                .getSettings()
                .playAreaFontSize;
          });
        }
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: _buildQuestions(context),
      ),
    );
  }
}
