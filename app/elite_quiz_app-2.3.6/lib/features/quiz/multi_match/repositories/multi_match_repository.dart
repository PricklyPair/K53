import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/quiz/multi_match/models/multi_match_question_model.dart';
import 'package:flutterquiz/features/quiz/quiz_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

final class MultiMatchRepository {
  Future<List<MultiMatchQuestion>> getMultiMatchQuestions({
    required String categoryId,
    String? subcategoryId,
  }) async {
    try {
      final type = subcategoryId != null ? subCategoryKey : categoryKey;
      final id = subcategoryId ?? categoryId;

      final body = {typeIdKey: type, idKey: id};

      final response = await http.post(
        Uri.parse(getMultiMatchQuestionsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(MultiMatchQuestion.fromJson)
          .toList();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<MultiMatchQuestion>> getMultiMatchQuestionsByLevel({
    required String categoryId,
    required String level,
    String? subcategoryId,
  }) async {
    try {
      final body = {levelKey: level, categoryKey: categoryId};

      if (subcategoryId != null) {
        body[subCategoryKey] = subcategoryId;
      }

      final response = await http.post(
        Uri.parse(getMultiMatchQuestionsByLevelUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(MultiMatchQuestion.fromJson)
          .toList();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
