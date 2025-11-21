import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/system_config/system_config_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

class SystemConfigRemoteDataSource {
  Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final response = await http.post(Uri.parse(getSystemConfigUrl));
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getSupportedQuestionLanguages() async {
    try {
      final response = await http.post(
        Uri.parse(getSupportedQuestionLanguageUrl),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getSupportedLanguageList() async {
    try {
      final response = await http.post(
        Uri.parse(getSupportedLanguageListUrl),
        //from :: 1 - App, 2 - Web
        body: {'from': '1'},
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<Map<String, dynamic>> getSystemLanguage(
    String name,
    String title,
  ) async {
    try {
      final body = {
        'language': name,
        //from :: 1 - App, 2 - Web
        'from': '1',
      };

      final response = await http.post(
        Uri.parse(getSystemLanguageJson),
        body: body,
      );

      if (response.statusCode != 200) {
        throw SystemConfigException(
          errorMessageCode: response.reasonPhrase.toString(),
        );
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonData['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: jsonData['message'] as String,
        );
      }

      final translations = (jsonData['data'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v.toString()),
      );

      return {
        'name': name,
        'title': title,
        'app_rtl_support': jsonData['rtl_support'] as String,
        'app_version': jsonData['version'] as String,
        'app_default': jsonData['default'] as String,
        'translations': translations,
      };
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {typeKey: type};
      final response = await http.post(
        Uri.parse(getAppSettingsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'].toString();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
