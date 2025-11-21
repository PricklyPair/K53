import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectivity {
  static Future<bool> isUserOffline() async {
    return !await InternetConnectionChecker.instance.hasConnection;
  }
}
