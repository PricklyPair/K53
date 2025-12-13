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
    } on SocketException catch (e) {
      // DEBUG: Show actual network error
      throw SystemConfigException(errorMessageCode: 'Network Error: ${e.message}');
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (e) {
      // DEBUG: Show actual error instead of generic message
      throw SystemConfigException(errorMessageCode: 'Exception: $e');
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
    } on SocketException catch (e) {
      // DEBUG: Show actual network error
      throw SystemConfigException(errorMessageCode: 'Network Error: ${e.message}');
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on Exception catch (e) {
      // DEBUG: Show actual error
      throw SystemConfigException(errorMessageCode: 'Exception: $e');
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
      // Return default English language as fallback
      print('[DEBUG] Network error, using default English fallback');
      return _getDefaultEnglishLanguageList();
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on FormatException catch (_) {
      // Return default English language as fallback when server returns invalid JSON
      print('[DEBUG] Server returned invalid JSON, using default English fallback');
      return _getDefaultEnglishLanguageList();
    } on Exception catch (_) {
      // Return default English language as fallback
      print('[DEBUG] Unknown error, using default English fallback');
      return _getDefaultEnglishLanguageList();
    }
  }

  List<Map<String, dynamic>> _getDefaultEnglishLanguageList() {
    return [
      {
        'id': '1',
        'language': 'English',
        'code': 'en',
        'is_rtl': '0',
        'status': '1',
      }
    ];
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
          errorMessageCode: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // DEBUG: Log the raw response to see what we're getting
      print('[DEBUG] API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonData['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: jsonData['message'] as String,
        );
      }

      // Check for required fields
      if (!jsonData.containsKey('rtl_support')) {
        throw SystemConfigException(
          errorMessageCode: 'Missing field: rtl_support in API response',
        );
      }
      if (!jsonData.containsKey('version')) {
        throw SystemConfigException(
          errorMessageCode: 'Missing field: version in API response',
        );
      }
      if (!jsonData.containsKey('default')) {
        throw SystemConfigException(
          errorMessageCode: 'Missing field: default in API response',
        );
      }

      final translations = (jsonData['data'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v.toString()),
      );

      return {
        'name': name,
        'title': title,
        'app_rtl_support': jsonData['rtl_support']?.toString() ?? '0',
        'app_version': jsonData['version']?.toString() ?? '1',
        'app_default': jsonData['default']?.toString() ?? '0',
        'translations': translations,
      };
    } on SocketException catch (e) {
      // DEBUG: Show actual network error, return default English
      print('[DEBUG] Network error in getSystemLanguage, using default English: ${e.message}');
      return _getDefaultEnglishLanguage(name, title);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } on FormatException catch (e) {
      // DEBUG: JSON parsing error - likely receiving HTML instead of JSON
      print('[DEBUG] Server returned invalid JSON in getSystemLanguage: ${e.message}');
      return _getDefaultEnglishLanguage(name, title);
    } on Exception catch (e) {
      // DEBUG: Show actual error, return default English
      print('[DEBUG] Exception in getSystemLanguage: $e, using default English');
      return _getDefaultEnglishLanguage(name, title);
    }
  }

  Map<String, dynamic> _getDefaultEnglishLanguage(String name, String title) {
    return {
      'name': name.isEmpty ? 'English' : name,
      'title': title.isEmpty ? 'English' : title,
      'app_rtl_support': '0',
      'app_version': '1',
      'app_default': '1',
      'translations': _getDefaultEnglishTranslations(),
    };
  }

  Map<String, String> _getDefaultEnglishTranslations() {
    return {
      // Common UI strings
      'defaultErrorMessage': 'Something went wrong. Please try again.',
      'noInternet': 'No internet connection',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'pleaseWait': 'Please wait...',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'submit': 'Submit',
      'back': 'Back',
      'next': 'Next',
      'continue': 'Continue',
      'skip': 'Skip',
      'finish': 'Finish',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'share': 'Share',
      'report': 'Report',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'viewAll': 'View All',
      'close': 'Close',
      'apply': 'Apply',
      'reset': 'Reset',
      'clear': 'Clear',
      'confirm': 'Confirm',
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Info',
      'notification': 'Notification',
      'notifications': 'Notifications',
      'message': 'Message',
      'messages': 'Messages',
      'update': 'Update',
      'download': 'Download',
      'upload': 'Upload',
      'play': 'Play',
      'pause': 'Pause',
      'stop': 'Stop',
      'start': 'Start',
      'end': 'End',
      'welcome': 'Welcome',
      'welcomeMessage': 'Welcome to K53 Learner License Quiz!',
      'appName': 'K53 Learner License Quiz',
      'version': 'Version',
      'language': 'Language',
      'theme': 'Theme',
      'dark': 'Dark',
      'light': 'Light',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'on': 'On',
      'off': 'Off',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'quiz': 'Quiz',
      'quizzes': 'Quizzes',
      'question': 'Question',
      'questions': 'Questions',
      'answer': 'Answer',
      'answers': 'Answers',
      'correct': 'Correct',
      'incorrect': 'Incorrect',
      'score': 'Score',
      'points': 'Points',
      'rank': 'Rank',
      'leaderboard': 'Leaderboard',
      'statistics': 'Statistics',
      'history': 'History',
      'achievements': 'Achievements',
      'badges': 'Badges',
      'coins': 'Coins',
      'rewards': 'Rewards',
      'category': 'Category',
      'categories': 'Categories',
      'level': 'Level',
      'levels': 'Levels',
      'difficulty': 'Difficulty',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'time': 'Time',
      'timer': 'Timer',
      'seconds': 'Seconds',
      'minutes': 'Minutes',
      'hours': 'Hours',
      'days': 'Days',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'all': 'All',
      'none': 'None',
      'total': 'Total',
      'completed': 'Completed',
      'pending': 'Pending',
      'failed': 'Failed',
      'passed': 'Passed',
      'dataNotFound': 'No data found',
      'fillAllData': 'Please fill all required fields',
      'invalidEmail': 'Invalid email address',
      'weakPassword': 'Password is too weak',
      'wrongPassword': 'Incorrect password',
      'userNotFound': 'User not found',
      'emailAlreadyInUse': 'Email already in use',
      'accountHasBeenDeactive': 'Account has been deactivated',
      'unauthorizedAccess': 'Unauthorized access',
      'sessionExpired': 'Session expired. Please login again.',
      'networkError': 'Network error. Please check your connection.',
      'serverError': 'Server error. Please try again later.',
      'updateAvailable': 'Update available',
      'updateNow': 'Update Now',
      'laterBtn': 'Later',
      'shareApp': 'Share App',
      'rateApp': 'Rate App',
      'aboutUs': 'About Us',
      'privacyPolicy': 'Privacy Policy',
      'termsAndConditions': 'Terms and Conditions',
      'contactUs': 'Contact Us',
      'help': 'Help',
      'faq': 'FAQ',
      'support': 'Support',
    };
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
