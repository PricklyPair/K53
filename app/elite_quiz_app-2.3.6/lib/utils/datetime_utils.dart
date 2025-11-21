import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static final dateFormat = DateFormat('d MMM, y');

  static String minuteToHHMM(int totalMinutes, {bool? showHourAndMinute}) {
    final hh = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final mm = (totalMinutes % 60).toString().padLeft(2, '0');

    final showHourAndMinutePostText = showHourAndMinute ?? true;
    return "$hh:$mm ${showHourAndMinutePostText ? "hh:mm" : ""}";
  }

  static Future<({String gmt, String localTimezone})> getTimeZone() async {
    final localTimezone = await FlutterTimezone.getLocalTimezone();

    final offset = DateTime.now().timeZoneOffset;
    final hh = offset.inHours.toString().padLeft(2, '0');
    final mm = offset.inMinutes.remainder(60).toString().padLeft(2, '0');
    late String gmt;
    if (offset.inMinutes > 0) {
      gmt = '+$hh:$mm';
    } else {
      gmt = '$hh:$mm';
    }

    return (gmt: gmt, localTimezone: localTimezone.identifier);
  }
}
