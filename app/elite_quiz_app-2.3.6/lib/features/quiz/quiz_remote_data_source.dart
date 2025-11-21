import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class QuizRemoteDataSource {
  static late String profile;
  static late String score;
  static late String rank;

  Future<List<Map<String, dynamic>>> getQuestionsForDailyQuiz({
    required String timezone,
    required String gmt,
    String? languageId,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId!,
        timezoneKey: timezone,
        gmtFormatKey: gmt,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionForDailyQuizUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionByType(
    String languageId,
  ) async {
    try {
      final body = <String, String>{typeKey: '2', languageIdKey: languageId};
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionByTypeUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionContest(
    String contestId,
  ) async {
    try {
      final body = <String, String>{contestIdKey: contestId};

      final response = await http.post(
        Uri.parse(getQuestionContestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getGuessTheWordQuestions({
    required String languageId,
    required String type, //category or subcategory
    required String typeId,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        typeIdKey: typeId,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getGuessTheWordQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForQuizZone({
    required String languageId,
    required String categoryId,
    required String subcategoryId,
    required String level,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        levelKey: level,
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }
      if (subcategoryId.isNotEmpty) {
        body.remove(categoryKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionsByLevelUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionByCategoryOrSubcategory({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{typeKey: type, idKey: id};

      final response = await http.post(
        Uri.parse(getQuestionsByCategoryOrSubcategory),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getAudioQuestions({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{typeKey: type, typeIdKey: id};

      final response = await http.post(
        Uri.parse(getAudioQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getLatexQuestions({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{typeKey: type, typeIdKey: id};

      final response = await http.post(
        Uri.parse(getLatexQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryWithUser({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        subTypeKey: subType ?? '',
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subType != null && subType.isEmpty) {
        body.remove(subTypeKey);
      }

      final response = await http.post(
        Uri.parse(getCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getCategory({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        subTypeKey: subType ?? '',
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subType != null && subType.isEmpty) {
        body.remove(subTypeKey);
      }

      final response = await http.post(
        Uri.parse(getCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSelfChallenge({
    required String languageId,
    required String categoryId,
    required String subcategoryId,
    required String numberOfQuestions,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        limitKey: numberOfQuestions,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }

      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionForSelfChallengeUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getSubCategory(String category) async {
    try {
      //body of post request
      final body = <String, String>{categoryKey: category};

      final response = await http.post(
        Uri.parse(getSubCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<int> getUnlockedLevel(
    String category,
    String subCategory, {
    required QuizTypes quizType,
  }) async {
    try {
      // assert that quizType can only be quizzone or multimatch
      assert(
        quizType == QuizTypes.quizZone || quizType == QuizTypes.multiMatch,
        'quizType can only be quizzone or multimatch',
      );

      //body of post request
      final body = <String, String>{
        categoryKey: category,
        subCategoryKey: subCategory,
      };

      if (subCategory.isEmpty) body.remove(subCategoryKey);

      final url = quizType == QuizTypes.quizZone
          ? getLevelUrl
          : getMultiMatchLevelDataUrl;

      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      final data = responseJson['data'] as Map<String, dynamic>;

      return int.parse(data['level'] as String? ?? '0');
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<Map<String, dynamic>> getContest({
    required String languageId,
    required String timezone,
    required String gmt,
  }) async {
    try {
      //body of post request
      final body = {
        languageIdKey: languageId,
        timezoneKey: timezone,
        gmtFormatKey: gmt,
      };

      final response = await http.post(
        Uri.parse(getContestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body);

      return responseJson as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: notPlayedContestKey);
    }
  }

  Future<({int total, List<Map<String, dynamic>> otherUsersRanks})>
  getContestLeaderboard({
    required String contestId,
    required int limit,
    int? offset,
  }) async {
    try {
      final body = {
        contestIdKey: contestId,
        limitKey: limit.toString(),
        if (offset != null) offsetKey: offset.toString(),
      };

      final response = await http.post(
        Uri.parse(getContestLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      final total = int.parse(
        responseJson['total']?.toString() ?? '0',
      );
      final myRank = responseJson['my_rank'] as Map<String, dynamic>;

      rank = myRank['user_rank'].toString();
      profile = myRank[profileKey].toString();
      score = myRank['score'].toString();
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (
        total: total,
        otherUsersRanks: (responseJson['data'] as List? ?? [])
            .cast<Map<String, dynamic>>(),
      );
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getComprehension({
    required String languageId,
    required String type,
    required String typeId,
  }) async {
    try {
      final body = {
        typeKey: type,
        typeIdKey: typeId,
        languageIdKey: languageId,
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(
        Uri.parse(getFunAndLearnUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getComprehensionQuestion(
    String? funAndLearnId,
  ) async {
    try {
      //body of post request
      final body = {funAndLearnKey: funAndLearnId};
      final response = await http.post(
        Uri.parse(getFunAndLearnQuestionsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> unlockPremiumCategory({required String categoryId}) async {
    try {
      final body = {categoryKey: categoryId};

      log('Body $body', name: 'unlockPremiumCategory API');
      final rawRes = await http.post(
        Uri.parse(unlockPremiumCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final jsonRes = jsonDecode(rawRes.body) as Map<String, dynamic>;

      if (jsonRes['error'] as bool) {
        throw QuizException(errorMessageCode: jsonRes['message'].toString());
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
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
      final body = <String, String>{
        if (categoryId != null && categoryId.isNotEmpty)
          categoryKey: categoryId,
        if (subcategoryId != null && subcategoryId.isNotEmpty)
          subCategoryKey: subcategoryId,
        'quiz_type': quizType,
        'play_questions': jsonEncode(playedQuestions),
        if (lifelines != null && lifelines.isNotEmpty)
          'lifeline': lifelines.join(','),
        'no_of_hint_used': ?noOfHintUsed?.toString(),
        if (roomId != null && roomId.isNotEmpty) 'match_id': roomId,
        if (playWithBot != null) 'is_bot': playWithBot ? '1' : '0',
        'match_id': ?matchId,
        'joined_users_count': ?joinedUsersCount?.toString(),
      };

      log('Body $body', name: 'setQuizCoinScore API');
      final response = await http.post(
        Uri.parse(setQuizCoinScoreUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      log('Response $responseJson', name: 'setQuizCoinScore API');
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
