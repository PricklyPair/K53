import 'package:flutterquiz/features/quiz/models/answer_option.dart';
import 'package:flutterquiz/features/quiz/models/correct_answer.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_answer_type_enum.dart';

final class MultiMatchQuestion {
  const MultiMatchQuestion({
    required this.id,
    required this.categoryId,
    required this.subcategoryId,
    required this.languageId,
    required this.image,
    required this.question,
    required this.questionType,
    required this.options,
    required this.answerType,
    required this.correctAnswer,
    required this.note,
    required this.level,
    this.submittedIds = const [],
    this.hasSubmittedAnswers = false,
  });

  factory MultiMatchQuestion.fromJson(Map<String, dynamic> json) {
    final optionIds = ['a', 'b', 'c', 'd', 'e'];
    final options = <AnswerOption>[];

    // parse options
    for (final id in optionIds) {
      final option = json['option$id'] as String? ?? '';
      if (option.isNotEmpty) options.add(AnswerOption(id: id, title: option));
    }

    final correctAnswer = (json['answer'] as List)
        .cast<Map<String, dynamic>>()
        .map(CorrectAnswer.fromJson)
        .toList(growable: false);

    final answerType = MultiMatchAnswerType.fromString(
      json['answer_type'] as String,
    );

    final submittedIds = options.map((e) => e.id!).toList();

    return MultiMatchQuestion(
      id: json['id'] as String,
      categoryId: json['category'] as String,
      subcategoryId: json['subcategory'] as String? ?? '',
      languageId: json['language_id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      question: json['question'] as String,
      questionType: json['question_type'] as String,
      answerType: answerType,
      correctAnswer: correctAnswer,
      note: json['note'] as String,
      level: json['level'] as String? ?? '0',
      options: options,
      submittedIds: answerType == MultiMatchAnswerType.sequence
          ? submittedIds.sublist(0, correctAnswer.length)
          : [],
    );
  }

  final String id;
  final String categoryId;
  final String subcategoryId;
  final String languageId;
  final String image;
  final String question;
  final List<AnswerOption> options;
  final MultiMatchAnswerType answerType;
  final List<CorrectAnswer> correctAnswer;
  final String note;
  final String level;

  // not used, and for both multi select and sequence question type is 1. so no use.
  final String questionType;

  /// not from api/json, but only used for app side, quiz play
  final List<String> submittedIds;
  final bool hasSubmittedAnswers;

  MultiMatchQuestion copyWith({
    String? id,
    String? question,
    MultiMatchAnswerType? answerType,
    List<CorrectAnswer>? correctAnswer,
    String? note,
    String? level,
    List<String>? submittedIds,
    String? categoryId,
    String? subcategoryId,
    List<AnswerOption>? options,
    String? image,
    String? questionType,
    String? languageId,
    bool? hasSubmittedAnswers,
  }) {
    return MultiMatchQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      answerType: answerType ?? this.answerType,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      note: note ?? this.note,
      level: level ?? this.level,
      submittedIds: submittedIds ?? this.submittedIds,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      languageId: languageId ?? this.languageId,
      image: image ?? this.image,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      hasSubmittedAnswers: hasSubmittedAnswers ?? this.hasSubmittedAnswers,
    );
  }
}
