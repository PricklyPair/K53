import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/exam/cubits/exam_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_local_data_source.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

//Need to optimize and separate the ui and other logic related process

class UiUtils {
  static const profileHeightBreakPointResultScreen = 355.0;
  static const appBarHeightPercentage = 0.16;
  static const bottomMenuPercentage = 0.075;

  /// Dialog
  static const dialogBlurSigma = 9.0;

  /// Bottom Sheet
  static const bottomSheetTopRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  /// Badges
  static List<String> needToUpdateBadgesLocally = [];

  /// Global
  // Margin Percentage for Screen Content
  static const hzMarginPct = 0.04;
  static const vtMarginPct = 0.02;

  // Space in-between List Tiles
  static const listTileGap = 12.0;

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    //
    final msgType = message.data['type'].toString();
    if (msgType == 'badges') {
      needToUpdateBadgesLocally.add(message.data['badge_type'].toString());
    } else if (msgType == 'payment_request') {
      await ProfileManagementLocalDataSource().updateReversedCoins(
        double.parse(message.data['coins'].toString()).toInt(),
      );
    }
  }

  static void updateBadgesLocally(BuildContext context) {
    needToUpdateBadgesLocally
      ..forEach(context.read<BadgesCubit>().unlockBadge)
      ..clear();
  }

  static Future<void> needToUpdateCoinsLocally(BuildContext context) async {
    final coins = await ProfileManagementLocalDataSource()
        .getUpdateReversedCoins();

    if (coins != 0) {
      context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: coins);
    }
  }

  static String getCurrentQuizLanguageId(BuildContext context) {
    return context.read<SystemConfigCubit>().isLanguageModeEnabled
        ? context.read<QuizLanguageCubit>().languageId
        : '';
  }

  static double getQuestionContainerTopPaddingPercentage(double dheight) {
    if (dheight >= 800) {
      return 0.06;
    }
    if (dheight >= 700) {
      return 0.065;
    }
    if (dheight >= 600) {
      return 0.07;
    }
    return 0.075;
  }

  static String formatNumber(int number) {
    return NumberFormat.compact().format(number).toLowerCase();
  }

  static String getCategoryTypeNumberFromQuizType(QuizTypes quizType) {
    return switch (quizType) {
      QuizTypes.multiMatch => '6',
      QuizTypes.mathMania => '5',
      QuizTypes.audioQuestions => '4',
      QuizTypes.guessTheWord => '3',
      QuizTypes.funAndLearn => '2',
      _ => '1', // Quiz Zone
    };
  }

  static String subTypeFromQuizType(QuizTypes type) => switch (type) {
    QuizTypes.groupPlay => '3',
    QuizTypes.oneVsOneBattle => '2',
    QuizTypes.selfChallenge => '1',
    _ => '',
  };

  //calculate amount per coins based on users coins
  static double calculateAmountPerCoins({
    required int userCoins,
    required int amount,
    required int coins,
  }) {
    return (amount * userCoins) / coins;
  }

  //calculate coins based on entered amount
  static int calculateDeductedCoinsForRedeemableAmount({
    required double userEnteredAmount,
    required int amount,
    required int coins,
  }) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  static Future<bool> forceUpdate(String updatedVersion) async {
    if (updatedVersion.isEmpty) {
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    final updateBasedOnVersion = _shouldUpdateBasedOnVersion(
      currentVersion.split('+').first,
      updatedVersion.split('+').first,
    );

    if (updatedVersion.split('+').length == 1 ||
        currentVersion.split('+').length == 1) {
      return updateBasedOnVersion;
    }

    final updateBasedOnBuildNumber = _shouldUpdateBasedOnBuildNumber(
      currentVersion.split('+').last,
      updatedVersion.split('+').last,
    );

    return updateBasedOnVersion || updateBasedOnBuildNumber;
  }

  static bool _shouldUpdateBasedOnVersion(
    String currentVersion,
    String updatedVersion,
  ) {
    final currentVersionList = currentVersion
        .split('.')
        .map(int.parse)
        .toList();
    final updatedVersionList = updatedVersion
        .split('.')
        .map(int.parse)
        .toList();

    if (updatedVersionList[0] > currentVersionList[0]) {
      return true;
    }
    if (updatedVersionList[1] > currentVersionList[1]) {
      return true;
    }
    if (updatedVersionList[2] > currentVersionList[2]) {
      return true;
    }

    return false;
  }

  static bool _shouldUpdateBasedOnBuildNumber(
    String currentBuildNumber,
    String updatedBuildNumber,
  ) {
    return int.parse(updatedBuildNumber) > int.parse(currentBuildNumber);
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static void fetchBookmarkAndBadges({
    required BuildContext context,
    required String userId,
  }) {
    //fetch bookmark quiz zone
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      context.read<BookmarkCubit>().getBookmark();
    }

    //fetch guess the word bookmark
    if (context.read<GuessTheWordBookmarkCubit>().state
        is! GuessTheWordBookmarkFetchSuccess) {
      context.read<GuessTheWordBookmarkCubit>().getBookmark();
    }

    //fetch audio question bookmark
    if (context.read<AudioQuestionBookmarkCubit>().state
        is! AudioQuestionBookmarkFetchSuccess) {
      context.read<AudioQuestionBookmarkCubit>().getBookmark();
    }

    if (context.read<BadgesCubit>().state is! BadgesFetchSuccess) {
      //get badges for given user
      context.read<BadgesCubit>().getBadges();
    }

    //complete any pending exam
    context.read<ExamCubit>().completePendingExams();
  }

  static double timeTakenToSubmitAnswer({
    required double animationControllerValue,
    required int quizTimer,
  }) => quizTimer * animationControllerValue;

  /// Use Builder on top of the widget you use it. to get the correct context.
  /// and size of the widget.
  static Future<void> share(
    String text, {
    required BuildContext context,
    List<XFile>? files,
    String? subject,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
