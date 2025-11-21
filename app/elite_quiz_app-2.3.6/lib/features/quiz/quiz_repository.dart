import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/contest_leaderboard.dart';
import 'package:flutterquiz/features/quiz/models/guess_the_word_question.dart';
import 'package:flutterquiz/features/quiz/models/leaderboard_monthly.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quiz_exception.dart';
import 'package:flutterquiz/features/quiz/quiz_remote_data_source.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';

class QuizRepository {
  factory QuizRepository() {
    _quizRepository._quizRemoteDataSource = QuizRemoteDataSource();
    return _quizRepository;
  }

  QuizRepository._internal();

  static final QuizRepository _quizRepository = QuizRepository._internal();
  late QuizRemoteDataSource _quizRemoteDataSource;
  static List<LeaderBoardMonthly> leaderBoardMonthlyList = [];

  Future<List<Category>> getCategory({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategoryWithUser(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Category>> getCategoryWithoutUser({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategory(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Subcategory>> getSubCategory(String category) async {
    try {
      final result = await _quizRemoteDataSource.getSubCategory(category);

      return result.map(Subcategory.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<int> getUnlockedLevel(
    String category,
    String subCategory, {
    required QuizTypes quizType,
  }) async {
    try {
      return await _quizRemoteDataSource.getUnlockedLevel(
        category,
        subCategory,
        quizType: quizType,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getQuestions(
    QuizTypes? quizType, {
    String? languageId,
    String? categoryId,
    String? subcategoryId,
    String? numberOfQuestions,
    String? level,
    String? contestId,
    String? funAndLearnId,
  }) async {
    try {
      final List<Map<String, dynamic>> result;

      if (quizType == QuizTypes.dailyQuiz) {
        final (:gmt, :localTimezone) = await DateTimeUtils.getTimeZone();
        result = await _quizRemoteDataSource.getQuestionsForDailyQuiz(
          languageId: languageId,
          timezone: localTimezone,
          gmt: gmt,
        );
      } else if (quizType == QuizTypes.selfChallenge) {
        result = await _quizRemoteDataSource.getQuestionsForSelfChallenge(
          languageId: languageId!,
          categoryId: categoryId!,
          numberOfQuestions: numberOfQuestions!,
          subcategoryId: subcategoryId!,
        );
      } else if (quizType == QuizTypes.quizZone) {
        //if level is 0 means need to fetch questions by get_question api endpoint
        if (level! == '0') {
          final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
          final id = type == 'category' ? categoryId : subcategoryId!;
          result = await _quizRemoteDataSource
              .getQuestionByCategoryOrSubcategory(type: type, id: id);
        } else {
          result = await _quizRemoteDataSource.getQuestionsForQuizZone(
            languageId: languageId!,
            categoryId: categoryId!,
            subcategoryId: subcategoryId!,
            level: level,
          );
        }
      } else if (quizType == QuizTypes.trueAndFalse) {
        result = await _quizRemoteDataSource.getQuestionByType(languageId!);
      } else if (quizType == QuizTypes.contest) {
        result = await _quizRemoteDataSource.getQuestionContest(contestId!);
      } else if (quizType == QuizTypes.funAndLearn) {
        result = await _quizRemoteDataSource.getComprehensionQuestion(
          funAndLearnId,
        );
      } else if (quizType == QuizTypes.audioQuestions) {
        final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
        final id = type == 'category' ? categoryId : subcategoryId!;
        result = await _quizRemoteDataSource.getAudioQuestions(
          type: type,
          id: id,
        );
      } else if (quizType == QuizTypes.mathMania) {
        final type = subcategoryId != null && subcategoryId.isNotEmpty
            ? 'subcategory'
            : 'category';
        final id = type == 'category' ? categoryId! : subcategoryId!;
        result = await _quizRemoteDataSource.getLatexQuestions(
          type: type,
          id: id,
        );
      } else {
        result = [];
      }

      return result.map(Question.fromJson).toList(growable: false);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<GuessTheWordQuestion>> getGuessTheWordQuestions({
    required String languageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) async {
    try {
      final result = await _quizRemoteDataSource.getGuessTheWordQuestions(
        languageId: languageId,
        type: type,
        typeId: typeId,
      );

      return result.map(GuessTheWordQuestion.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<Contests> getContest({
    required String languageId,
    required String timezone,
    required String gmt,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getContest(
        languageId: languageId,
        timezone: timezone,
        gmt: gmt,
      );
      return Contests.fromJson(result);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<({int total, List<ContestLeaderboard> otherUsersRanks})>
  getContestLeaderboard(
    String contestId, {
    required int limit,
    int? offset,
  }) async {
    try {
      final (:total, :otherUsersRanks) = await _quizRemoteDataSource
          .getContestLeaderboard(
            contestId: contestId,
            limit: limit,
            offset: offset,
          );

      return (
        total: total,
        otherUsersRanks: otherUsersRanks
            .map(ContestLeaderboard.fromJson)
            .toList(),
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Comprehension>> getComprehension({
    required String languageId,
    required String type,
    required String typeId,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getComprehension(
        languageId: languageId,
        type: type,
        typeId: typeId,
      );

      return result.map(Comprehension.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> unlockPremiumCategory({required String categoryId}) async {
    try {
      await _quizRemoteDataSource.unlockPremiumCategory(categoryId: categoryId);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<Map<String, dynamic>> setQuizCoinScore({
    required String quizType,
    required dynamic playedQuestions,
    String? categoryId,
    String? subcategoryId,
    List<String>? lifelines,
    String? roomId,
    bool? playWithBot,
    int? noOfHintUsed,
    String? matchId,
    int? joinedUsersCount,
  }) async {
    try {
      return await _quizRemoteDataSource.setQuizCoinScore(
        categoryId: categoryId,
        quizType: quizType,
        playedQuestions: playedQuestions,
        subcategoryId: subcategoryId,
        lifelines: lifelines,
        roomId: roomId,
        playWithBot: playWithBot,
        noOfHintUsed: noOfHintUsed,
        matchId: matchId,
        joinedUsersCount: joinedUsersCount,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }
}
