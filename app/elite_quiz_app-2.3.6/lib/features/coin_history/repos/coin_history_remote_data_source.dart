import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

final class CoinHistoryRemoteDataSource {
  const CoinHistoryRemoteDataSource();

  Future<({int total, List<Map<String, dynamic>> data})> getCoinHistory({
    required String limit,
    required String offset,
  }) async {
    try {
      final body = <String, String>{
        if (limit.isNotEmpty) limitKey: limit,
        if (offset.isNotEmpty) offsetKey: offset,
      };

      final response = await http.post(
        Uri.parse(getCoinHistoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      final total = int.parse(responseJson['total'] as String? ?? '0');
      final data = (responseJson['data'] as List).cast<Map<String, dynamic>>();

      return (total: total, data: data);
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }
}
