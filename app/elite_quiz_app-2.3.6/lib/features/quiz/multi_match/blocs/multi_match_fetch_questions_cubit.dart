import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_answer_type_enum.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/quiz/multi_match/repositories/multi_match_repository.dart';

part 'multi_match_fetch_questions_state.dart';

class MultiMatchFetchQuestionsCubit
    extends Cubit<MultiMatchFetchQuestionsState> {
  MultiMatchFetchQuestionsCubit()
    : super(const MultiMatchFetchQuestionsInitial());

  final _multiRepo = MultiMatchRepository();

  List<MultiMatchQuestion> get questions =>
      (state as MultiMatchQuestionsSuccess).questions;

  Future<void> fetchQuestions({
    required String categoryId,
    String? subcategoryId,
    String? level,
  }) async {
    emit(const MultiMatchFetchQuestionsInProgress());

    try {
      late final List<MultiMatchQuestion> questions;

      /// no levels, fetch by category or subcategory directly
      if (level == null || level == '0') {
        questions = await _multiRepo.getMultiMatchQuestions(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
        );
      } else {
        questions = await _multiRepo.getMultiMatchQuestionsByLevel(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          level: level,
        );
      }

      emit(MultiMatchQuestionsSuccess(questions: questions));
    } on Exception catch (e) {
      emit(MultiMatchFetchQuestionsFailure(error: e.toString()));
    }
  }

  void timeOutOnQuestion(int questionIndex) {
    if (state is! MultiMatchQuestionsSuccess) return;

    final successState = state as MultiMatchQuestionsSuccess;

    final questions = successState.questions;

    questions[questionIndex] = questions[questionIndex].copyWith(
      submittedIds: ['-1'],
      hasSubmittedAnswers: true,
    );

    emit(successState.copyWith(questions: questions));
  }

  void updateSelectedOptions(String questionId, String optionId) {
    if (state is! MultiMatchQuestionsSuccess) return;

    final successState = state as MultiMatchQuestionsSuccess;

    final questions = successState.questions;

    final idx = questions.indexWhere((q) => q.id == questionId);

    if (idx == -1) {
      throw Exception('Question not found');
    }

    final updatedSubmittedIds = List<String>.from(questions[idx].submittedIds);

    if (questions[idx].submittedIds.contains(optionId)) {
      updatedSubmittedIds.remove(optionId);
    } else {
      updatedSubmittedIds.add(optionId);
    }

    questions[idx] = questions[idx].copyWith(submittedIds: updatedSubmittedIds);

    emit(successState.copyWith(questions: questions));
  }

  void onReorderOptions(String questionId, List<String> selectedOptionsIds) {
    if (state is! MultiMatchQuestionsSuccess) return;

    final successState = state as MultiMatchQuestionsSuccess;
    final questions = successState.questions;

    final idx = questions.indexWhere((q) => q.id == questionId);

    if (idx == -1) {
      throw Exception('Question not found');
    }

    questions[idx] = questions[idx].copyWith(submittedIds: selectedOptionsIds);

    emit(successState.copyWith(questions: questions));
  }

  void submitAnswer(
    int currQueIdx, {
    required MultiMatchAnswerType answerType,
    required List<String> correctAnswersIds,
  }) {
    if (state is! MultiMatchQuestionsSuccess) return;

    final successState = state as MultiMatchQuestionsSuccess;
    final questions = successState.questions;

    questions[currQueIdx] = questions[currQueIdx].copyWith(
      hasSubmittedAnswers: true,
    );

    emit(
      successState.copyWith(questions: questions),
    );
  }
}
