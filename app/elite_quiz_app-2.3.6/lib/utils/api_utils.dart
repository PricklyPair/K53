import 'dart:developer';

import 'package:flutterquiz/features/auth/auth_local_data_source.dart';
import 'package:flutterquiz/features/auth/auth_remote_data_source.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    var jwtToken = AuthLocalDataSource.getJwtToken();

    if (jwtToken.isEmpty) {
      try {
        jwtToken = await AuthRemoteDataSource().getJWTTokenOfUser(
          firebaseId: AuthLocalDataSource.getUserFirebaseId(),
          type: AuthLocalDataSource.getAuthType(),
        );
        if (jwtToken.isNotEmpty) {
          await AuthLocalDataSource.setJwtToken(jwtToken);
        }
      } on Exception catch (e) {
        log(name: 'API: Get Headers', e.toString());
      }
    }

    log(name: 'API: JWT Token', jwtToken);

    if (jwtToken.isEmpty) {
      return {};
    }

    return {'Authorization': 'Bearer $jwtToken'};
  }
}
