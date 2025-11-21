//State
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

@immutable
abstract class QuestionsState {}

class QuestionsInitial extends QuestionsState {}

class QuestionsFetchInProgress extends QuestionsState {
  QuestionsFetchInProgress(this.quizType);

  final QuizTypes quizType;
}

class QuestionsFetchFailure extends QuestionsState {
  QuestionsFetchFailure(this.errorMessage);

  final String errorMessage;
}

class QuestionsFetchSuccess extends QuestionsState {
  QuestionsFetchSuccess({
    required this.questions,
    required this.quizType,
  });

  final List<Question> questions;
  final QuizTypes quizType;
}

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._quizRepository) : super(QuestionsInitial());
  final QuizRepository _quizRepository;

  void updateState(QuestionsState newState) {
    emit(newState);
  }

  void getQuestions(
    QuizTypes quizType, {
    String? languageId, //
    String?
    categoryId, //will be in use for quizZone and self-challenge (quizType)
    String?
    subcategoryId, //will be in use for quizZone and self-challenge (quizType)
    String? numberOfQuestions, //will be in use for self-challenge (quizType),
    String? level, //will be in use for quizZone (quizType)
    String? contestId,
    String? funAndLearnId,
  }) {
    emit(QuestionsFetchInProgress(quizType));
    _quizRepository
        .getQuestions(
          quizType,
          languageId: languageId,
          categoryId: categoryId,
          numberOfQuestions: numberOfQuestions,
          subcategoryId: subcategoryId,
          level: level,
          contestId: contestId,
          funAndLearnId: funAndLearnId,
        )
        .then((questions) {
          emit(
            QuestionsFetchSuccess(
              questions: questions,
              quizType: quizType,
            ),
          );
        })
        .catchError((Object e) {
          emit(QuestionsFetchFailure(e.toString()));
        });
  }

  //submitted AnswerId will contain -1, 0 or optionId (a,b,c,d,e)
  void updateQuestionWithAnswerAndLifeline(
    String? questionId,
    String submittedAnswerId,
    String firebaseId,
  ) {
    //fetching questions that need to update
    final updatedQuestions = (state as QuestionsFetchSuccess).questions;
    //fetching index of question that need to update with submittedAnswer
    final questionIndex = updatedQuestions.indexWhere(
      (element) => element.id == questionId,
    );
    //update question at given questionIndex with submittedAnswerId
    updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
        .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);

    emit(
      QuestionsFetchSuccess(
        questions: updatedQuestions,
        quizType: (state as QuestionsFetchSuccess).quizType,
      ),
    );
  }

  int getTotalQuestionInNumber() {
    if (state is QuestionsFetchSuccess) {
      return (state as QuestionsFetchSuccess).questions.length;
    }
    return 0;
  }

  List<Question> questions() {
    if (state is QuestionsFetchSuccess) {
      return (state as QuestionsFetchSuccess).questions;
    }
    return [];
  }
}
