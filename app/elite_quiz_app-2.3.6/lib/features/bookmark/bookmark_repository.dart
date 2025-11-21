import 'package:flutterquiz/features/bookmark/bookmark_exception.dart';
import 'package:flutterquiz/features/bookmark/bookmark_remote_data_source.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class BookmarkRepository {
  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  static final BookmarkRepository _bookmarkRepository =
      BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;

  Future<List<dynamic>> getBookmark(String type) async {
    try {
      final result = await _bookmarkRemoteDataSource.getBookmark(type);

      if (type == '3') {
        return result.map(GuessTheWordQuestion.fromBookmarkJson).toList();
      }
      return result.map(Question.fromBookmarkJson).toList();
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //to update bookmark status (add(1) or remove(0))
  Future<void> updateBookmark(
    String questionId,
    String status,
    String type,
  ) async {
    try {
      await _bookmarkRemoteDataSource.updateBookmark(questionId, status, type);
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }
}
