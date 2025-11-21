import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/statistic/statistic_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class StatisticRemoteDataSource {
  Future<Map<String, dynamic>> getStatistic() async {
    try {
      //body of post request
      final response = await http.post(
        Uri.parse(getStatisticUrl),
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw StatisticException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<Map<String, dynamic>> getBattleStatistic() async {
    try {
      final response = await http.post(
        Uri.parse(getBattleStatisticsUrl),
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      return responseJson;
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
