import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/bookmark/bookmark_repository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/update_bookmark_cubit.dart';
import 'package:flutterquiz/features/music_player/music_player_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/answer_option.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/utils/quiz_utils.dart';
import 'package:flutterquiz/features/report_question/report_question_cubit.dart';
import 'package:flutterquiz/features/report_question/report_question_repository.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/music_player_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/question_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/report_question_bottom_sheet.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

final class ReviewAnswersScreenArgs extends RouteArgs {
  const ReviewAnswersScreenArgs({
    required this.quizType,
    this.questions = const [],
    this.guessTheWordQuestions = const [],
  });

  final QuizTypes quizType;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
}

class ReviewAnswersScreen extends StatefulWidget {
  const ReviewAnswersScreen({required this.args, super.key});

  final ReviewAnswersScreenArgs args;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<ReviewAnswersScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateBookmarkCubit>(
            create: (context) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<ReportQuestionCubit>(
            create: (_) => ReportQuestionCubit(ReportQuestionRepository()),
          ),
        ],
        child: ReviewAnswersScreen(args: args),
      ),
    );
  }

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen>
    with TickerProviderStateMixin {
  int _currQueIdx = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;

  late final String _firebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  late final _isGuessTheWord = widget.args.quizType == QuizTypes.guessTheWord;
  late final _isAudioQuestions =
      widget.args.quizType == QuizTypes.audioQuestions;

  late final int questionsLength = _isGuessTheWord
      ? widget.args.guessTheWordQuestions.length
      : widget.args.questions.length;

  late final List<GlobalKey<MusicPlayerContainerState>> _musicPlayerKeys =
      List.generate(
        widget.args.questions.length,
        (_) => GlobalKey<MusicPlayerContainerState>(),
        growable: false,
      );
  late final List<String> _correctAnswerIds = List.generate(
    widget.args.questions.length,
    (i) => AnswerEncryption.decryptCorrectAnswer(
      rawKey: _firebaseId,
      correctAnswer: widget.args.questions[i].correctAnswer!,
    ),
    growable: false,
  );

  late final bool isLatex = context.read<SystemConfigCubit>().isLatexEnabled(
    widget.args.quizType,
  );

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onTapReportQuestion() {
    showReportQuestionBottomSheet(
      context: context,
      questionId: _isGuessTheWord
          ? widget.args.guessTheWordQuestions[_currQueIdx].id
          : widget.args.questions[_currQueIdx].id!,
      reportQuestionCubit: context.read<ReportQuestionCubit>(),
      quizType: widget.args.quizType,
    );
  }

  Future<void> _navigateToQuestion(
    int newIndex, {
    bool slideRight = false,
  }) async {
    if (_isAnimating || newIndex < 0 || newIndex >= questionsLength) return;

    _isAnimating = true;

    // Handle audio questions
    if (_isAudioQuestions) {
      _musicPlayerKeys[_currQueIdx].currentState?.stopAudio();
      _musicPlayerKeys[newIndex].currentState?.playAudio();
    }

    // slide out animation
    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(slideRight ? 1.0 : -1.0, 0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOut,
          ),
        );

    // Slide out current question
    await _slideController.forward();

    // Update question index
    setState(() {
      _currQueIdx = newIndex;
    });

    // Slide in animation
    _slideAnimation =
        Tween<Offset>(
          begin: Offset(slideRight ? -1.0 : 1.0, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOut,
          ),
        );

    _slideController.reset();
    await _slideController.forward();

    _isAnimating = false;
  }

  Color _optionBackgroundColor(String? optionId) {
    if (optionId == _correctAnswerIds[_currQueIdx]) {
      return kCorrectAnswerColor;
    }

    if (optionId == widget.args.questions[_currQueIdx].submittedAnswerId) {
      return kWrongAnswerColor;
    }

    return Theme.of(context).colorScheme.surface;
  }

  Color _optionTextColor(String? optionId) {
    final correctAnswerId = _correctAnswerIds[_currQueIdx];
    final submittedAnswerId =
        widget.args.questions[_currQueIdx].submittedAnswerId;

    return optionId == correctAnswerId || optionId == submittedAnswerId
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.onTertiary;
  }

  Widget _buildBottomMenu() {
    Future<void> onTapPageChange({required bool flipLeft}) async {
      final newIndex = _currQueIdx + (flipLeft ? -1 : 1);
      if (newIndex >= 0 && newIndex < questionsLength) {
        if (context.read<SettingsCubit>().vibration) {
          unawaited(HapticFeedback.lightImpact());
        }
        await _navigateToQuestion(newIndex, slideRight: flipLeft);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          height: context.height * .07,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              InkWell(
                onTap: _currQueIdx > 0
                    ? () => onTapPageChange(flipLeft: true)
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.primaryTextColor.withValues(alpha: .3),
                    ),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _currQueIdx > 0
                            ? context.primaryTextColor
                            : context.primaryTextColor.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Question counter
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    top: BorderSide(
                      color: context.primaryTextColor.withValues(alpha: 0.2),
                    ),
                    bottom: BorderSide(
                      color: context.primaryTextColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    left: BorderSide(
                      color: context.primaryTextColor.withValues(alpha: 0.2),
                    ),
                    right: BorderSide(
                      color: context.primaryTextColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  '${_currQueIdx + 1} / $questionsLength',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Next button
              InkWell(
                onTap: _currQueIdx < questionsLength - 1
                    ? () => onTapPageChange(flipLeft: false)
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.primaryTextColor.withValues(alpha: .3),
                    ),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _currQueIdx < questionsLength - 1
                            ? context.primaryTextColor
                            : context.primaryTextColor.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //to build option of given question
  Widget _buildOption(AnswerOption option) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _optionBackgroundColor(option.id),
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        option.title!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _optionTextColor(option.id),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildOptions() => Column(
    children: widget.args.questions[_currQueIdx].answerOptions!
        .map(_buildOption)
        .toList(),
  );

  Widget _buildGuessTheWordOptionAndAnswer(GuessTheWordQuestion question) {
    final submittedAnswer = QuizUtils.buildGuessTheWordQuestionAnswer(
      question.submittedAnswer,
    );
    final isCorrect = submittedAnswer == question.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 25),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.tr("yourAnsLbl")!} : ',
                style: TextStyle(
                  fontSize: 18,
                  color: context.primaryTextColor,
                ),
              ),
              TextSpan(
                text: submittedAnswer,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: isCorrect
                      ? kCorrectAnswerColor
                      : kWrongAnswerColor,
                  decorationThickness: 2,
                  color: isCorrect ? kCorrectAnswerColor : kWrongAnswerColor,
                ),
              ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.tr("correctAndLbl")!} : ',
                style: TextStyle(
                  fontSize: 18,
                  color: context.primaryTextColor,
                ),
              ),
              TextSpan(
                text: question.answer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: kCorrectAnswerColor,
                  decorationThickness: 2,
                  color: kCorrectAnswerColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(String notes) {
    if (notes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: context.width * 0.8,
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(notesKey)!,
            style: TextStyle(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),

          ///
          Text(
            notes,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.primaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAndOptions(Question question, int index) {
    if (isLatex) {
      return LaTeXQuestionContainer(
        correctAnswerId: _correctAnswerIds[_currQueIdx],
        question: widget.args.questions[_currQueIdx],
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: context.height * UiUtils.vtMarginPct,
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: false,
            question: question,
            questionColor: context.primaryTextColor,
          ),
          if (_isAudioQuestions)
            BlocProvider<MusicPlayerCubit>(
              create: (_) => MusicPlayerCubit(),
              child: MusicPlayerContainer(
                currentIndex: _currQueIdx,
                index: index,
                url: question.audio!,
                key: _musicPlayerKeys[index],
              ),
            )
          else
            const SizedBox(),

          //build options
          _buildOptions(),
          _buildNotes(question.note!),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildGuessTheWordQuestionAndOptions(GuessTheWordQuestion question) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: context.height * UiUtils.vtMarginPct,
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: false,
            questionColor: context.primaryTextColor,
            question: Question(
              marks: '',
              id: question.id,
              question: question.question,
              imageUrl: question.image,
            ),
          ),
          //build options
          _buildGuessTheWordOptionAndAnswer(question),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return SizedBox(
      height: context.height * .82,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_slideAnimation.value.dx * context.width, 0),
          child: child,
        ),
        child: widget.args.quizType == QuizTypes.guessTheWord
            ? _buildGuessTheWordQuestionAndOptions(
                widget.args.guessTheWordQuestions[_currQueIdx],
              )
            : _buildQuestionAndOptions(
                widget.args.questions[_currQueIdx],
                _currQueIdx,
              ),
      ),
    );
  }

  Widget _buildReportButton() {
    return IconButton(
      onPressed: _onTapReportQuestion,
      icon: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildBookmarkButton() {
    if (widget.args.quizType == QuizTypes.quizZone) {
      final bookmarkCubit = context.read<BookmarkCubit>();
      final updateBookmarkCubit = context.read<UpdateBookmarkCubit>();
      return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
        bloc: updateBookmarkCubit,
        listener: (context, state) async {
          if (state is UpdateBookmarkFailure) {
            if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
              await showAlreadyLoggedInDialog(context);
              return;
            }

            if (state.failedStatus == '0') {
              bookmarkCubit.addBookmarkQuestion(
                widget.args.questions[_currQueIdx],
              );
            } else {
              bookmarkCubit.removeBookmarkQuestion(
                widget.args.questions[_currQueIdx].id!,
              );
            }

            context.showSnack(
              context.tr(
                convertErrorCodeToLanguageKey(errorCodeUpdateBookmarkFailure),
              )!,
            );
          }
          if (state is UpdateBookmarkSuccess) {}
        },
        child: BlocBuilder<BookmarkCubit, BookmarkState>(
          bloc: bookmarkCubit,
          builder: (context, state) {
            if (state is BookmarkFetchSuccess) {
              final isBookmarked = bookmarkCubit.hasQuestionBookmarked(
                widget.args.questions[_currQueIdx].id!,
              );
              return InkWell(
                onTap: () async {
                  if (isBookmarked) {
                    bookmarkCubit.removeBookmarkQuestion(
                      widget.args.questions[_currQueIdx].id!,
                    );
                    await updateBookmarkCubit.updateBookmark(
                      widget.args.questions[_currQueIdx].id!,
                      '0',
                      '1',
                    );
                  } else {
                    bookmarkCubit.addBookmarkQuestion(
                      widget.args.questions[_currQueIdx],
                    );
                    await updateBookmarkCubit.updateBookmark(
                      widget.args.questions[_currQueIdx].id!,
                      '1',
                      '1',
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isBookmarked
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              );
            }

            if (state is BookmarkFetchFailure) {
              log('Bookmark Fetch Failure: ${state.errorMessageCode}');
            }
            return const SizedBox();
          },
        ),
      );
    }

    //if quiz type is audio questions
    if (widget.args.quizType == QuizTypes.audioQuestions) {
      final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
      final updateBookmarkCubit = context.read<UpdateBookmarkCubit>();
      return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
        bloc: updateBookmarkCubit,
        listener: (context, state) async {
          //if failed to update bookmark status
          if (state is UpdateBookmarkFailure) {
            if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
              await showAlreadyLoggedInDialog(context);
              return;
            }

            if (state.failedStatus == '0') {
              bookmarkCubit.addBookmarkQuestion(
                widget.args.questions[_currQueIdx],
              );
            } else {
              //remove again
              //if unable to add question to bookmark then remove question
              bookmarkCubit.removeBookmarkQuestion(
                widget.args.questions[_currQueIdx].id!,
              );
            }

            context.showSnack(
              context.tr(
                convertErrorCodeToLanguageKey(errorCodeUpdateBookmarkFailure),
              )!,
            );
          }
        },
        child:
            BlocBuilder<AudioQuestionBookmarkCubit, AudioQuestionBookMarkState>(
              bloc: bookmarkCubit,
              builder: (context, state) {
                if (state is AudioQuestionBookmarkFetchSuccess) {
                  final isBookmarked = bookmarkCubit.hasQuestionBookmarked(
                    widget.args.questions[_currQueIdx].id!,
                  );
                  return InkWell(
                    onTap: () async {
                      if (isBookmarked) {
                        bookmarkCubit.removeBookmarkQuestion(
                          widget.args.questions[_currQueIdx].id!,
                        );
                        await updateBookmarkCubit.updateBookmark(
                          widget.args.questions[_currQueIdx].id!,
                          '0',
                          '4',
                        ); //type is 4 for audio questions
                      } else {
                        bookmarkCubit.addBookmarkQuestion(
                          widget.args.questions[_currQueIdx],
                        );
                        await updateBookmarkCubit.updateBookmark(
                          widget.args.questions[_currQueIdx].id!,
                          '1',
                          '4',
                        ); //type is 4 for audio questions
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isBookmarked
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
      );
    }

    if (widget.args.quizType == QuizTypes.guessTheWord) {
      final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
      final updateBookmarkCubit = context.read<UpdateBookmarkCubit>();
      return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
        bloc: updateBookmarkCubit,
        listener: (context, state) async {
          //if failed to update bookmark status
          if (state is UpdateBookmarkFailure) {
            if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
              await showAlreadyLoggedInDialog(context);
              return;
            }

            //remove bookmark question
            if (state.failedStatus == '0') {
              //if unable to remove question from bookmark then add question
              //add again
              bookmarkCubit.addBookmarkQuestion(
                widget.args.guessTheWordQuestions[_currQueIdx],
              );
            } else {
              //remove again
              //if unable to add question to bookmark then remove question
              bookmarkCubit.removeBookmarkQuestion(
                widget.args.guessTheWordQuestions[_currQueIdx].id,
              );
            }
            context.showSnack(
              context.tr(
                convertErrorCodeToLanguageKey(errorCodeUpdateBookmarkFailure),
              )!,
            );
          }
        },
        child:
            BlocBuilder<GuessTheWordBookmarkCubit, GuessTheWordBookmarkState>(
              bloc: context.read<GuessTheWordBookmarkCubit>(),
              builder: (context, state) {
                if (state is GuessTheWordBookmarkFetchSuccess) {
                  return InkWell(
                    onTap: () async {
                      if (bookmarkCubit.hasQuestionBookmarked(
                        widget.args.guessTheWordQuestions[_currQueIdx].id,
                      )) {
                        //remove
                        bookmarkCubit.removeBookmarkQuestion(
                          widget.args.guessTheWordQuestions[_currQueIdx].id,
                        );
                        await updateBookmarkCubit.updateBookmark(
                          widget.args.guessTheWordQuestions[_currQueIdx].id,
                          '0',
                          '3', //type is 3 for guess the word questions
                        );
                      } else {
                        //add
                        bookmarkCubit.addBookmarkQuestion(
                          widget.args.guessTheWordQuestions[_currQueIdx],
                        );
                        await updateBookmarkCubit.updateBookmark(
                          widget.args.guessTheWordQuestions[_currQueIdx].id,
                          '1',
                          '3',
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Icon(
                        bookmarkCubit.hasQuestionBookmarked(
                              widget.args.guessTheWordQuestions[_currQueIdx].id,
                            )
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr('reviewAnswers')!),
        actions: [
          _buildBookmarkButton(),
          if (widget.args.questions.isNotEmpty &&
              (widget.args.quizType == QuizTypes.quizZone ||
                  widget.args.quizType == QuizTypes.dailyQuiz ||
                  widget.args.quizType == QuizTypes.trueAndFalse ||
                  widget.args.quizType == QuizTypes.selfChallenge ||
                  widget.args.quizType == QuizTypes.oneVsOneBattle ||
                  widget.args.quizType == QuizTypes.groupPlay)) ...[
            _buildReportButton(),
          ],
        ],
      ),
      body: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _buildQuestions()),
          Align(alignment: Alignment.bottomCenter, child: _buildBottomMenu()),
        ],
      ),
    );
  }
}

class LaTeXQuestionContainer extends StatelessWidget {
  const LaTeXQuestionContainer({
    required this.correctAnswerId,
    required this.question,
    super.key,
  });

  final String correctAnswerId;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final submittedAnswerId = question.submittedAnswerId;

    Color optionBackgroundColor(String? optionId) {
      if (optionId == correctAnswerId) return kCorrectAnswerColor;

      if (optionId == submittedAnswerId) return kWrongAnswerColor;

      return context.surfaceColor;
    }

    Color optionTextColor(String? optionId) {
      return optionId == correctAnswerId || optionId == submittedAnswerId
          ? context.surfaceColor
          : context.primaryTextColor;
    }

    final options = question.answerOptions!
        .map(
          (option) => TeXViewDocument(
            option.title!,
            style: TeXViewStyle(
              contentColor: optionTextColor(option.id),
              backgroundColor: optionBackgroundColor(option.id),
              sizeUnit: TeXViewSizeUnit.pixels,
              textAlign: TeXViewTextAlign.center,
              fontStyle: TeXViewFontStyle(
                fontSize: 18,
                sizeUnit: TeXViewSizeUnit.pt,
              ),
              margin: const TeXViewMargin.only(top: 15),
              padding: const TeXViewPadding.only(
                left: 20,
                right: 20,
                bottom: 16,
                top: 16,
              ),
              borderRadius: const TeXViewBorderRadius.all(10),
            ),
          ),
        )
        .toList(growable: false);

    final hasImage = question.imageUrl != null && question.imageUrl!.isNotEmpty;
    final hasNote = question.note != null && question.note!.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: context.height * UiUtils.vtMarginPct,
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: TeXView(
        renderingEngine: const TeXViewRenderingEngine.katex(),
        child: TeXViewColumn(
          children: [
            /// Question
            TeXViewDocument(
              question.question!,
              style: TeXViewStyle(
                contentColor: context.primaryTextColor,
                backgroundColor: Colors.transparent,
                sizeUnit: TeXViewSizeUnit.pixels,
                textAlign: TeXViewTextAlign.center,
                fontStyle: TeXViewFontStyle(fontSize: 22),
              ),
            ),

            if (hasImage)
              TeXViewContainer(
                child: TeXViewImage.network(question.imageUrl!),
                style: const TeXViewStyle(
                  textAlign: TeXViewTextAlign.center,
                  sizeUnit: TeXViewSizeUnit.pixels,
                  borderRadius: TeXViewBorderRadius.all(20),
                  padding: TeXViewPadding.all(0),
                  margin: TeXViewMargin.only(top: 20, bottom: 20),
                  height: 200,
                ),
              ),

            ...options,

            /// Notes
            if (hasNote) ...[
              TeXViewDocument(
                context.tr(notesKey)!,
                style: TeXViewStyle(
                  textAlign: TeXViewTextAlign.left,
                  sizeUnit: TeXViewSizeUnit.pt,
                  contentColor: context.primaryColor,
                  fontStyle: TeXViewFontStyle(
                    fontSize: 16,
                    sizeUnit: TeXViewSizeUnit.pt,
                    fontFamily: kFonts.fontFamily,
                    fontWeight: TeXViewFontWeight.bold,
                  ),
                  padding: const TeXViewPadding.all(0),
                  margin: const TeXViewMargin.only(top: 20, bottom: 12),
                ),
              ),
              TeXViewDocument(
                question.note!,
                style: TeXViewStyle(
                  textAlign: TeXViewTextAlign.center,
                  sizeUnit: TeXViewSizeUnit.pt,
                  contentColor: context.primaryTextColor,
                  fontStyle: TeXViewFontStyle(
                    fontSize: 14,
                    sizeUnit: TeXViewSizeUnit.pt,
                    fontFamily: kFonts.fontFamily,
                    fontWeight: TeXViewFontWeight.normal,
                  ),
                  padding: const TeXViewPadding.all(0),
                  margin: const TeXViewMargin.only(bottom: 20),
                ),
              ),
            ] else ...[
              const TeXViewDocument(
                '',
                style: TeXViewStyle(
                  margin: TeXViewMargin.only(
                    bottom: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
