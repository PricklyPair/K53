import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/badges/badges_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class BadgesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBadges() async {
    try {
      final response = await http.post(
        Uri.parse(getUserBadgesUrl),
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw BadgesException(
          errorMessageCode: responseJson['message'] as String,
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw BadgesException(errorMessageCode: errorCodeNoInternet);
    } on BadgesException catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw BadgesException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
