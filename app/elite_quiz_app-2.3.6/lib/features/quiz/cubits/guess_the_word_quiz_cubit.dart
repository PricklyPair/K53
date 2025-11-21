import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

abstract class GuessTheWordQuizState {}

class GuessTheWordQuizInitial extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchInProgress extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchFailure extends GuessTheWordQuizState {
  GuessTheWordQuizFetchFailure(this.errorMessage);

  final String errorMessage;
}

class GuessTheWordQuizFetchSuccess extends GuessTheWordQuizState {
  GuessTheWordQuizFetchSuccess({
    required this.questions,
    required this.noOfHintUsed,
  });

  final List<GuessTheWordQuestion> questions;
  final int noOfHintUsed;
}

class GuessTheWordQuizCubit extends Cubit<GuessTheWordQuizState> {
  GuessTheWordQuizCubit(this._quizRepository)
    : super(GuessTheWordQuizInitial());
  final QuizRepository _quizRepository;

  void getQuestion({
    required String questionLanguageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) {
    emit(GuessTheWordQuizFetchInProgress());
    _quizRepository
        .getGuessTheWordQuestions(
          languageId: questionLanguageId,
          type: type,
          typeId: typeId,
        )
        .then((questions) {
          emit(
            GuessTheWordQuizFetchSuccess(
              questions: questions,
              noOfHintUsed: 0,
            ),
          );
        })
        .catchError((Object e) {
          emit(GuessTheWordQuizFetchFailure(e.toString()));
        });
  }

  void updateAnswer(String answer, int answerIndex, String questionId) {
    if (state is GuessTheWordQuizFetchSuccess) {
      final questions = (state as GuessTheWordQuizFetchSuccess).questions;
      final questionIndex = questions.indexWhere(
        (element) => element.id == questionId,
      );
      final question = questions[questionIndex];
      final updatedAnswer = question.submittedAnswer;
      updatedAnswer[answerIndex] = answer;
      questions[questionIndex] = question.copyWith(
        updatedAnswer: updatedAnswer,
      );

      emit(
        GuessTheWordQuizFetchSuccess(
          questions: questions,
          noOfHintUsed: (state as GuessTheWordQuizFetchSuccess).noOfHintUsed,
        ),
      );
    }
  }

  List<GuessTheWordQuestion> getQuestions() {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).questions;
    }
    return [];
  }

  int get noOfHintUsed {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).noOfHintUsed;
    }
    return 0;
  }

  void submitAnswer(
    String questionId,
    List<String> answer,
    int noOfHintUsedForQuestion,
  ) {
    //update hasAnswer and current points

    if (state is GuessTheWordQuizFetchSuccess) {
      final currentState = state as GuessTheWordQuizFetchSuccess;
      final questions = currentState.questions;
      final questionIndex = questions.indexWhere(
        (element) => element.id == questionId,
      );
      final question = questions[questionIndex];

      questions[questionIndex] = question.copyWith(
        hasAnswerGiven: true,
        updatedAnswer: answer,
      );

      final currentTotalNoOfHintUsed =
          currentState.noOfHintUsed + noOfHintUsedForQuestion;

      emit(
        GuessTheWordQuizFetchSuccess(
          questions: questions,
          noOfHintUsed: currentTotalNoOfHintUsed,
        ),
      );
    }
  }

  void updateState(GuessTheWordQuizState updatedState) {
    emit(updatedState);
  }
}
