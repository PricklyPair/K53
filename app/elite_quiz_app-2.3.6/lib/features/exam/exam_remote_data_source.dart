import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/exam/exam_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class ExamRemoteDataSource {
  Future<({int total, List<Map<String, dynamic>> data})> getExams({
    required String languageId,
    required String type,
    required String limit,
    required String offset,
    required String timezone,
    required String gmt,
  }) async {
    try {
      //body of post request
      final body = {
        languageIdKey: languageId,
        typeKey: type, // 1 for today , 2 for completed
        limitKey: limit,
        offsetKey: offset,
        timezoneKey: timezone,
        gmtFormatKey: gmt,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      if (limit.isEmpty) {
        body.remove(limitKey);
      }

      if (offset.isEmpty) {
        body.remove(offsetKey);
      }

      final response = await http.post(
        Uri.parse(getExamModuleUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ExamException(
          errorMessageCode:
              responseJson['message'].toString() == errorCodeDataNotFound
              ? type == '1'
                    ? errorCodeNoExamForToday
                    : errorCodeHaveNotCompletedExam
              : responseJson['message'].toString(),
        );
      }

      return (
        total: int.parse(responseJson['total'] as String? ?? '0'),
        data: (responseJson['data'] as List).cast<Map<String, dynamic>>(),
      );
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: errorCodeNoInternet);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw ExamException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionForExam({
    required String examId,
  }) async {
    try {
      final body = <String, String>{examModuleIdKey: examId};

      final response = await http.post(
        Uri.parse(getExamModuleQuestionsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ExamException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: errorCodeNoInternet);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw ExamException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> updateExamStatusToInExam({required String examModuleId}) async {
    try {
      final body = <String, String>{examModuleIdKey: examModuleId};

      final response = await http.post(
        Uri.parse(setExamModuleResultUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ExamException(
          errorMessageCode:
              responseJson['message'].toString() == errorCodeFillAllData
              ? errorCodeAlreadyInExam
              : responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: errorCodeNoInternet);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw ExamException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> submitExamResult({
    required String examModuleId,
    required String totalDuration,
    required List<Map<String, dynamic>> statistics,
    required String obtainedMarks,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) async {
    try {
      final body = <String, String>{
        examModuleIdKey: examModuleId,
        statisticsKey: json.encode(statistics),
        totalDurationKey: totalDuration,
        obtainedMarksKey: obtainedMarks,
        rulesViolatedKey: rulesViolated ? '1' : '0',
        capturedQuestionIdsKey: json.encode(capturedQuestionIds),
      };

      final response = await http.post(
        Uri.parse(setExamModuleResultUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ExamException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: errorCodeNoInternet);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw ExamException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
