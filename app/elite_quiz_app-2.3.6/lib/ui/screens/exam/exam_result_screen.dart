import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/exam/models/exam_result.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({required this.examResult, super.key});

  final ExamResult examResult;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(examResult.date),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final size = context;

    return Scaffold(
      appBar: QAppBar(elevation: 0, title: Text(context.tr(examResultKey)!)),
      body: Column(
        children: [
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 8,
                  color: context.primaryTextColor.withValues(alpha: .1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeights.regular,
                    height: 1.33,
                    color: colorScheme.onTertiary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  examResult.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.33,
                    fontWeight: FontWeights.medium,
                    color: colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.onTertiary.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  width: context.width * .65,
                  alignment: Alignment.center,
                  child: Text(
                    '${context.tr(obtainedMarksLblKey)!} : ${examResult.obtainedMarks()}/${examResult.totalMarks}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeights.medium,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: context.primaryTextColor.withValues(alpha: .2)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('totalQuestions')!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeights.medium,
                          color: colorScheme.onTertiary,
                          height: 1.31,
                        ),
                      ),
                      Text(
                        "[ ${examResult.totalQuestions()} ${context.tr("quesLbl")!}]",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeights.medium,
                          color: colorScheme.onTertiary,
                          height: 1.31,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: context.primaryColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    height: 75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      spacing: 48,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${examResult.totalCorrectAnswers()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeights.semiBold,
                                color: colorScheme.surface,
                                height: 1.33,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('correctAnswersLbl')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeights.regular,
                                color: colorScheme.surface,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${examResult.totalInCorrectAnswers()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeights.semiBold,
                                color: colorScheme.surface,
                                height: 1.33,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('incorrectAnswersLbl')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeights.regular,
                                color: colorScheme.surface,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.only(top: 12, bottom: 60),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: examResult.getUniqueMarksOfQuestion().length,
              itemBuilder: (_, i) {
                final marks = examResult.getUniqueMarksOfQuestion()[i];
                return _StatCard(
                  marks: marks,
                  totalQues: examResult.totalQuestionsByMark(marks).toString(),
                  correctAns: examResult
                      .totalCorrectAnswersByMark(marks)
                      .toString(),
                  incorrectAns: examResult
                      .totalInCorrectAnswersByMark(marks)
                      .toString(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.marks,
    required this.totalQues,
    required this.correctAns,
    required this.incorrectAns,
  });

  final String marks;
  final String totalQues;
  final String correctAns;
  final String incorrectAns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$marks ${context.tr("markQuestionsLbl")!}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeights.medium,
                  color: context.primaryTextColor,
                ),
              ),
              Text(
                "[ $totalQues ${context.tr("quesLbl")!} ]",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeights.medium,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.surfaceColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      correctAns,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeights.semiBold,
                        fontSize: 18,
                        height: 1.33,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('correctAnswersLbl')!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.medium,
                        color: context.primaryTextColor.withValues(alpha: .3),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 6,
                      width: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          color: kCorrectAnswerColor,
                        ),
                      ),
                    ),
                  ],
                ),
                VerticalDivider(
                  indent: 10,
                  endIndent: 20,
                  color: context.primaryTextColor.withValues(alpha: .2),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      incorrectAns,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeights.semiBold,
                        fontSize: 18,
                        height: 1.33,
                        color: context.primaryTextColor,
                      ),
                    ),
                    Text(
                      context.tr('incorrectAnswersLbl')!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.medium,
                        color: context.primaryTextColor.withValues(alpha: .3),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 6,
                      width: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          color: kWrongAnswerColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
