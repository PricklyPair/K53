import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/answer_option.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_answer_type_enum.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/report_question/report_question_cubit.dart';
import 'package:flutterquiz/features/report_question/report_question_repository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/report_question_bottom_sheet.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

final class MultiMatchReviewScreenArgs extends RouteArgs {
  const MultiMatchReviewScreenArgs({required this.questions});

  final List<MultiMatchQuestion> questions;
}

class MultiMatchReviewScreen extends StatefulWidget {
  const MultiMatchReviewScreen({required this.args, super.key});

  final MultiMatchReviewScreenArgs args;

  @override
  State<MultiMatchReviewScreen> createState() => _MultiMatchReviewScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<MultiMatchReviewScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider<ReportQuestionCubit>(
        create: (_) => ReportQuestionCubit(ReportQuestionRepository()),
        child: MultiMatchReviewScreen(args: args),
      ),
    );
  }
}

class _MultiMatchReviewScreenState extends State<MultiMatchReviewScreen> {
  late final _pageController = PageController();
  int _currQueIdx = 0;

  late final String _firebaseId = context
      .read<UserDetailsCubit>()
      .getUserFirebaseId();

  late final List<List<String>> _correctAnswerIds = List.generate(
    widget.args.questions.length,
    (i) => AnswerEncryption.decryptCorrectAnswers(
      rawKey: _firebaseId,
      correctAnswer: widget.args.questions[i].correctAnswer,
    ),
    growable: false,
  );

  void _onPageChanged(int idx) {
    setState(() => _currQueIdx = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr('reviewAnswers')!),
        actions: [_buildReportButton()],
      ),
      body: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _buildQuestions()),
          Align(alignment: Alignment.bottomCenter, child: _buildBottomMenu()),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    void onTapReportQuestion() {
      showReportQuestionBottomSheet(
        context: context,
        questionId: widget.args.questions[_currQueIdx].id,
        reportQuestionCubit: context.read<ReportQuestionCubit>(),
        quizType: QuizTypes.multiMatch,
      );
    }

    return IconButton(
      onPressed: onTapReportQuestion,
      icon: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildQuestions() {
    return SizedBox(
      height: context.height * 0.85,
      child: PageView.builder(
        onPageChanged: _onPageChanged,
        controller: _pageController,
        itemCount: widget.args.questions.length,
        itemBuilder: (_, idx) => Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.height * UiUtils.vtMarginPct,
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          child: _buildQuestionAndOptions(widget.args.questions[idx], idx),
        ),
      ),
    );
  }

  Widget _buildQuestionAndOptions(MultiMatchQuestion question, int index) {
    final updatedOptions = List.generate(
      question.options.length,
      (idx) => MapEntry(optionIds[idx], question.options[idx]),
    );

    final mappedCorrectAnswersIds = _correctAnswerIds[_currQueIdx]
        .map((id) => updatedOptions.firstWhere((e) => e.value.id == id).key)
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (question.image.isNotEmpty) ...[
            Container(
              width: context.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: context.height * 0.225,
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                child: CachedNetworkImage(
                  errorWidget: (context, image, _) => Center(
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                  imageUrl: question.image,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressContainer()),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
          _buildOptions(),
          if (question.answerType == MultiMatchAnswerType.sequence) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeights.bold,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(text: context.tr('correctAnswersLbl')),
                  const TextSpan(text: ' : '),
                  TextSpan(
                    text: mappedCorrectAnswersIds
                        .map((e) => e.toUpperCase())
                        .join(', '),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
          if (question.note.isNotEmpty) _buildNotes(question.note),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildBottomMenu() {
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> onTapPageChange({required bool flipLeft}) async {
      if (_currQueIdx != (flipLeft ? 0 : widget.args.questions.length - 1)) {
        final idx = _currQueIdx + (flipLeft ? -1 : 1);
        await _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      height: context.height * UiUtils.bottomMenuPercentage,
      child: Row(
        mainAxisAlignment: widget.args.questions.length > 1
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (widget.args.questions.length > 1)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onTertiary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 5,
                left: 8,
                right: 2,
                bottom: 5,
              ),
              child: GestureDetector(
                onTap: () => onTapPageChange(flipLeft: true),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: colorScheme.onTertiary,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              '${_currQueIdx + 1} / ${widget.args.questions.length}',
              style: TextStyle(color: colorScheme.onTertiary, fontSize: 18),
            ),
          ),
          if (widget.args.questions.length > 1)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onTertiary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () => onTapPageChange(flipLeft: false),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  final optionIds = ['a', 'b', 'c', 'd', 'e'];

  Widget _buildOptions() {
    final question = widget.args.questions[_currQueIdx];

    final updatedOptions = List.generate(
      question.options.length,
      (idx) => MapEntry(optionIds[idx], question.options[idx]),
    );

    return Column(
      children: updatedOptions
          .map(
            (option) => _buildOption(option, answerType: question.answerType),
          )
          .toList(),
    );
  }

  bool isCurrOptionInAnswers(String id) =>
      _correctAnswerIds[_currQueIdx].contains(id);

  bool isCurrOptionSubmitted(String id) =>
      widget.args.questions[_currQueIdx].submittedIds.contains(id);

  Color _optionBorderColor(bool isOptionSubmitted) => isOptionSubmitted
      ? Theme.of(context).colorScheme.onTertiary
      : Theme.of(context).colorScheme.onTertiary.withValues(alpha: 0);

  Color _optionBackgroundColor(bool isOptionCorrect, bool isOptionSubmitted) {
    return isOptionCorrect
        ? kCorrectAnswerColor
        : isOptionSubmitted
        ? kWrongAnswerColor
        : Theme.of(context).colorScheme.surface;
  }

  Color _optionTextColor(bool isOptionCorrect, bool isOptionSubmitted) {
    if (isOptionCorrect || isOptionSubmitted) {
      return Theme.of(context).colorScheme.surface;
    }
    return Theme.of(context).colorScheme.onTertiary;
  }

  Widget _buildOption(
    MapEntry<String, AnswerOption> option, {
    required MultiMatchAnswerType answerType,
  }) {
    final isOptionCorrect = isCurrOptionInAnswers(option.value.id!);
    final isOptionSubmitted = isCurrOptionSubmitted(option.value.id!);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: answerType == MultiMatchAnswerType.sequence
              ? Colors.transparent
              : _optionBorderColor(isOptionSubmitted),
          width: 1.5,
        ),
        color: answerType == MultiMatchAnswerType.sequence
            ? Theme.of(context).colorScheme.surface
            : _optionBackgroundColor(isOptionCorrect, isOptionSubmitted),
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          if (answerType == MultiMatchAnswerType.sequence) ...[
            Text(
              '${option.key.toUpperCase()}.',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              option.value.title!,
              textAlign: answerType == MultiMatchAnswerType.sequence
                  ? TextAlign.start
                  : TextAlign.center,
              style: TextStyle(
                color: answerType == MultiMatchAnswerType.sequence
                    ? Theme.of(context).colorScheme.onTertiary
                    : _optionTextColor(isOptionCorrect, isOptionSubmitted),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(String notes) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: context.width * 0.8,
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(notesKey)!,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(notes, style: TextStyle(color: primaryColor)),
        ],
      ),
    );
  }
}
