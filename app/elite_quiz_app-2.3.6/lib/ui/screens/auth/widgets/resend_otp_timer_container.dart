import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';

class ResendOtpTimerContainer extends StatefulWidget {
  const ResendOtpTimerContainer({
    required this.enableResendOtpButton,
    super.key,
  });

  final VoidCallback enableResendOtpButton;

  @override
  ResendOtpTimerContainerState createState() => ResendOtpTimerContainerState();
}

class ResendOtpTimerContainerState extends State<ResendOtpTimerContainer> {
  Timer? resendOtpTimer;
  int resendOtpTimeInSeconds = otpTimeOutSeconds - 1;

  void setResendOtpTimer() {
    setState(() {
      resendOtpTimeInSeconds = otpTimeOutSeconds - 1;
    });

    resendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendOtpTimeInSeconds == 0) {
        timer.cancel();
        widget.enableResendOtpButton();
      } else {
        setState(() {
          resendOtpTimeInSeconds--;
        });
      }
    });
  }

  void cancelOtpTimer() {
    resendOtpTimer?.cancel();
  }

  @override
  void dispose() {
    cancelOtpTimer();
    super.dispose();
  }

  String get formattedTime =>
      ' ${resendOtpTimeInSeconds.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr('resetLbl')! + formattedTime,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: 0.6),
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
