import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmark_repository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

@immutable
abstract class AudioQuestionBookMarkState {}

class AudioQuestionBookmarkInitial extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchInProgress extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchSuccess extends AudioQuestionBookMarkState {
  AudioQuestionBookmarkFetchSuccess(this.questions);

  final List<Question> questions;
}

class AudioQuestionBookmarkFetchFailure extends AudioQuestionBookMarkState {
  AudioQuestionBookmarkFetchFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class AudioQuestionBookmarkCubit extends Cubit<AudioQuestionBookMarkState> {
  AudioQuestionBookmarkCubit(this._bookmarkRepository)
    : super(AudioQuestionBookmarkInitial());

  final BookmarkRepository _bookmarkRepository;

  Future<void> getBookmark() async {
    emit(AudioQuestionBookmarkFetchInProgress());

    try {
      final questions =
          await _bookmarkRepository.getBookmark('4') as List<Question>;

      emit(AudioQuestionBookmarkFetchSuccess(questions));
    } on Exception catch (e) {
      emit(AudioQuestionBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String questionId) {
    return questions().indexWhere((e) => e.id == questionId) != -1;
  }

  void addBookmarkQuestion(Question question) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      emit(AudioQuestionBookmarkFetchSuccess(questions()..insert(0, question)));
    }
  }

  void removeBookmarkQuestion(String questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      emit(
        AudioQuestionBookmarkFetchSuccess(
          questions()..removeWhere((e) => e.id == questionId),
        ),
      );
    }
  }

  List<Question> questions() {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      return (state as AudioQuestionBookmarkFetchSuccess).questions;
    }
    return [];
  }

  void updateState(AudioQuestionBookMarkState updatedState) {
    emit(updatedState);
  }
}
