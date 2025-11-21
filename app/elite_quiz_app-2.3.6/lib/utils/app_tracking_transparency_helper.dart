import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AppTrackingTransparencyHelper {
  static Future<TrackingStatus> requestTrackingPermission() async {
    if (!Platform.isIOS) {
      return TrackingStatus.authorized;
    }

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      final requestedStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      return requestedStatus;
    }

    return status;
  }

  static Future<bool> isTrackingAllowed() async {
    if (!Platform.isIOS) {
      return true;
    }

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    return status == TrackingStatus.authorized;
  }

  static Future<String?> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) {
      return null;
    }

    final isAllowed = await isTrackingAllowed();
    if (!isAllowed) {
      return null;
    }

    return AppTrackingTransparency.getAdvertisingIdentifier();
  }
}
