import 'package:flutterquiz/features/exam/exam_exception.dart';
import 'package:flutterquiz/features/exam/exam_local_data_source.dart';
import 'package:flutterquiz/features/exam/exam_remote_data_source.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/exam/models/exam_result.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';

class ExamRepository {
  factory ExamRepository() {
    _examRepository._examRemoteDataSource = ExamRemoteDataSource();
    _examRepository._examLocalDataSource = ExamLocalDataSource();
    return _examRepository;
  }

  ExamRepository._internal();

  static final ExamRepository _examRepository = ExamRepository._internal();
  late ExamRemoteDataSource _examRemoteDataSource;
  late ExamLocalDataSource _examLocalDataSource;

  ExamLocalDataSource get examLocalDataSource => _examLocalDataSource;

  Future<List<Exam>> getExams({required String languageId}) async {
    try {
      final (:gmt, :localTimezone) = await DateTimeUtils.getTimeZone();

      final (total: _, :data) = await _examRemoteDataSource.getExams(
        limit: '',
        offset: '',
        languageId: languageId,
        type: '1',
        timezone: localTimezone,
        gmt: gmt,
      );

      return data.map(Exam.fromJson).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<({int total, List<ExamResult> data})> getCompletedExams({
    required String languageId,
    required String offset,
    required String limit,
  }) async {
    try {
      final (:gmt, :localTimezone) = await DateTimeUtils.getTimeZone();
      final (:total, :data) = await _examRemoteDataSource.getExams(
        languageId: languageId,
        type: '2',
        limit: limit,
        offset: offset,
        timezone: localTimezone,
        gmt: gmt,
      );
      return (total: total, data: data.map(ExamResult.fromJson).toList());
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getExamQuestions({required String examId}) async {
    try {
      final result = await _examRemoteDataSource.getQuestionForExam(
        examId: examId,
      );
      return result.map(Question.fromJson).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateExamStatusToInExam({required String examModuleId}) async {
    try {
      await _examRemoteDataSource.updateExamStatusToInExam(
        examModuleId: examModuleId,
      );
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> submitExamResult({
    required String obtainedMarks,
    required String examModuleId,
    required String totalDuration,
    required List<Map<String, dynamic>> statistics,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) async {
    try {
      await _examRemoteDataSource.submitExamResult(
        capturedQuestionIds: capturedQuestionIds,
        rulesViolated: rulesViolated,
        examModuleId: examModuleId,
        totalDuration: totalDuration,
        statistics: statistics,
        obtainedMarks: obtainedMarks,
      );
    } on Exception catch (_) {}
  }

  Future<void> completePendingExams() async {
    //
    final pendingExamIds = _examLocalDataSource.getAllExamModuleIds();
    for (final element in pendingExamIds) {
      await submitExamResult(
        examModuleId: element,
        totalDuration: '0',
        statistics: [],
        obtainedMarks: '0',
        rulesViolated: false,
        capturedQuestionIds: [],
      );
    }

    //delete exams
    for (final element in pendingExamIds) {
      await _examLocalDataSource.removeExamModuleId(element);
    }
  }
}
