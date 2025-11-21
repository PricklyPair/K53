import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/features/system_config/model/room_code_char_type.dart';

class SystemConfigModel {
  SystemConfigModel({
    required this.adsEnabled,
    required this.adsType,
    required this.androidBannerId,
    required this.androidGameID,
    required this.androidInterstitialId,
    required this.androidRewardedId,
    required this.answerMode,
    required this.appLink,
    required this.appMaintenance,
    required this.appVersion,
    required this.appVersionIos,
    required this.audioQuestionMode,
    required this.audioTimer,
    required this.battleGroupCategoryMode,
    required this.groupBattleMode,
    required this.oneVsOneBattleMode,
    required this.randomBattleCategoryMode,
    required this.coinAmount,
    required this.coinLimit,
    required this.contestMode,
    required this.currencySymbol,
    required this.dailyQuizMode,
    required this.earnCoin,
    required this.examMode,
    required this.forceUpdate,
    required this.funAndLearnTimer,
    required this.funNLearnMode,
    required this.guessTheWordMode,
    required this.guessTheWordTimer,
    required this.inAppPurchaseMode,
    required this.iosAppLink,
    required this.iosBannerId,
    required this.iosGameID,
    required this.iosInterstitialId,
    required this.iosMoreApps,
    required this.iosRewardedId,
    required this.languageMode,
    required this.lifelineDeductCoins,
    required this.mathQuizMode,
    required this.mathsQuizTimer,
    required this.quizWinningPercentage,
    required this.paymentMode,
    required this.perCoin,
    required this.quizTimer,
    required this.randomBattleEntryCoins,
    required this.randomBattleTimer,
    required this.referCoin,
    required this.reviewAnswersDeductCoins,
    required this.rewardAdsCoin,
    required this.selfChallengeMode,
    required this.selfChallengeMaxMinutes,
    required this.shareAppText,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.truefalseMode,
    required this.botImage,
    required this.quizZoneMode,
    required this.guessTheWordHintsPerQuiz,
    required this.coinsPerDailyAdView,
    required this.isDailyAdsEnabled,
    required this.totalDailyAds,
    required this.groupBattleRoomCodeCharType,
    required this.groupBattleTimer,
    required this.oneVsOneBattleCategoryMode,
    required this.oneVsOneBattleRoomCodeCharType,
    required this.oneVsOneBattleTimer,
    required this.randomBattleMode,
    required this.trueAndFalseTimer,
    required this.randomBattleOpponentSearchDuration,
    required this.selfChallengeMaxQuestions,
    required this.groupBattleMinimumEntryFee,
    required this.oneVsOneBattleMinimumEntryFee,
    required this.resumeExamAfterCloseTimeout,
    required this.isLatexModeEnabled,
    required this.isExamLatexModeEnabled,
    required this.isEmailLoginEnabled,
    required this.isGmailLoginEnabled,
    required this.isAppleLoginEnabled,
    required this.isPhoneLoginEnabled,
    required this.multiMatchMode,
    required this.multiMatchDuration,
    required this.guessTheWordHintDeductCoins,
    required this.bannerIdAndroidIronSource,
    required this.bannerIdIosIronSource,
    required this.interstitialIdAndroidIronSource,
    required this.interstitialIdIosIronSource,
    required this.rewardedIdAndroidIronSource,
    required this.rewardedIdIosIronSource,
    required this.appKeyIosIronSource,
    required this.appKeyAndroidIronSource,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    adsEnabled = json['in_app_ads_mode'] == '1';
    adsType = adsEnabled
        ? AdType.fromString(json['ads_type'] as String? ?? '0')
        : AdType.none;
    androidBannerId = json['android_banner_id'] as String? ?? '';
    androidGameID = json['android_game_id'] as String? ?? '';
    androidInterstitialId = json['android_interstitial_id'] as String? ?? '';
    androidRewardedId = json['android_rewarded_id'] as String? ?? '';
    appLink = json['app_link'] as String? ?? '';
    appMaintenance = json['app_maintenance'] == '1';
    appVersion = json['app_version'] as String? ?? '';
    appVersionIos = json['app_version_ios'] as String? ?? '';
    audioQuestionMode = json['audio_mode_question'] == '1';
    audioTimer = int.parse(json['audio_quiz_seconds'] as String? ?? '0');
    battleGroupCategoryMode =
        (json['battle_mode_group_category'] ?? '0') == '1';
    groupBattleMode = json['battle_mode_group'] == '1';
    oneVsOneBattleMode = (json['battle_mode_one'] ?? '0') == '1';
    randomBattleCategoryMode =
        (json['battle_mode_random_category'] ?? '0') == '1';
    oneVsOneBattleCategoryMode =
        (json['battle_mode_one_category'] as String) == '1';

    randomBattleMode = (json['battle_mode_random'] ?? '0') == '1';

    coinAmount = int.parse(json['coin_amount'] as String? ?? '0');
    coinLimit = int.parse(json['coin_limit'] as String? ?? '0');
    contestMode = (json['contest_mode'] ?? '0') == '1';
    currencySymbol = json['currency_symbol'] as String? ?? r'$';
    dailyQuizMode = (json['daily_quiz_mode'] ?? '0') == '1';
    earnCoin = json['earn_coin'] as String? ?? '';
    examMode = (json['exam_module'] ?? '0') == '1';
    forceUpdate = json['force_update'] == '1';

    trueAndFalseTimer = int.parse(
      json['true_false_quiz_in_seconds'] as String? ?? '0',
    );
    funAndLearnTimer = int.parse(
      json['fun_and_learn_time_in_seconds'] as String? ?? '0',
    );

    funNLearnMode = (json['fun_n_learn_question'] ?? '0') == '1';

    guessTheWordMode = (json['guess_the_word_question'] ?? '0') == '1';
    guessTheWordTimer = int.parse(
      json['guess_the_word_seconds'] as String? ?? '0',
    );
    inAppPurchaseMode = json['in_app_purchase_mode'] == '1';
    iosAppLink = json['ios_app_link'] as String? ?? '';
    iosBannerId = json['ios_banner_id'] as String? ?? '';
    iosGameID = json['ios_game_id'] as String? ?? '';
    iosInterstitialId = json['ios_interstitial_id'] as String? ?? '';
    iosMoreApps = json['ios_more_apps'] as String? ?? '';
    iosRewardedId = json['ios_rewarded_id'] as String? ?? '';
    languageMode = (json['language_mode'] ?? '0') == '1';
    lifelineDeductCoins = int.parse(
      json['quiz_zone_lifeline_deduct_coin'] as String? ?? '0',
    );
    mathQuizMode = json['maths_quiz_mode'] == '1';
    mathsQuizTimer = int.parse(json['maths_quiz_seconds'] as String? ?? '0');
    quizWinningPercentage = double.parse(
      json['quiz_winning_percentage'] as String? ?? '0',
    );
    paymentMode = json['payment_mode'] == '1';
    perCoin = int.parse(json['per_coin'] as String? ?? '0');
    groupBattleTimer = int.parse(
      json['battle_mode_group_in_seconds'] as String? ?? '0',
    );
    oneVsOneBattleTimer = int.parse(
      json['battle_mode_one_in_seconds'] as String? ?? '0',
    );
    oneVsOneBattleMinimumEntryFee = int.parse(
      json['battle_mode_one_entry_coin'] as String,
    );

    groupBattleMinimumEntryFee = int.parse(
      json['battle_mode_group_entry_coin'] as String,
    );

    quizTimer = int.parse(json['quiz_zone_duration'] as String? ?? '0');
    referCoin = json['refer_coin'] as String? ?? '';
    reviewAnswersDeductCoins = int.parse(
      json['review_answers_deduct_coin'] as String? ?? '0',
    );
    randomBattleTimer = int.parse(
      json['battle_mode_random_in_seconds'] as String? ?? '0',
    );

    rewardAdsCoin = int.parse(json['reward_coin'] as String? ?? '0');
    selfChallengeMode = json['self_challenge_mode'] == '1';
    shareAppText = json['shareapp_text'] as String? ?? '';
    answerMode = AnswerMode.fromString(json['answer_mode'] as String);
    systemTimezone = json['system_timezone'] as String? ?? '';
    systemTimezoneGmt = json['system_timezone_gmt'] as String? ?? '';
    truefalseMode = (json['true_false_mode'] ?? '0') == '1';
    botImage = json['bot_image'] as String? ?? '';
    coinsPerDailyAdView = json['daily_ads_coins'] as String? ?? '0';
    isDailyAdsEnabled = (json['daily_ads_visibility'] ?? '0') == '1';
    totalDailyAds = int.parse(json['daily_ads_counter'] as String? ?? '0');
    quizZoneMode = (json['quiz_zone_mode'] ?? '0') == '1';
    randomBattleEntryCoins = int.parse(
      json['battle_mode_random_entry_coin'] as String? ?? '0',
    );

    groupBattleRoomCodeCharType = RoomCodeCharType.fromString(
      json['battle_mode_group_code_char'] as String,
    );
    oneVsOneBattleRoomCodeCharType = RoomCodeCharType.fromString(
      json['battle_mode_one_code_char'] as String,
    );

    randomBattleOpponentSearchDuration = int.parse(
      json['battle_mode_random_search_duration'] as String? ?? '0',
    );

    guessTheWordHintsPerQuiz = int.parse(
      json['guess_the_word_max_hints'] as String? ?? '0',
    );

    selfChallengeMaxMinutes = int.parse(
      json['self_challenge_max_minutes'] as String? ?? '0',
    );
    selfChallengeMaxQuestions = int.parse(
      json['self_challenge_max_questions'] as String? ?? '0',
    );

    resumeExamAfterCloseTimeout = int.parse(
      json['exam_module_resume_exam_timeout'] as String,
    );

    isLatexModeEnabled = (json['latex_mode'] == '1');
    isExamLatexModeEnabled = (json['exam_latex_mode'] == '1');

    isEmailLoginEnabled = (json['email_login'] == '1');
    isGmailLoginEnabled = (json['gmail_login'] == '1');
    isAppleLoginEnabled = (json['apple_login'] == '1');
    isPhoneLoginEnabled = (json['phone_login'] == '1');

    multiMatchMode = (json['multi_match_mode'] == '1');
    multiMatchDuration = int.parse(json['multi_match_duration'] as String);
    guessTheWordHintDeductCoins = int.parse(
      json['guess_the_word_hint_deduct_coin'] as String,
    );

    bannerIdAndroidIronSource =
        json['banner_id_android_iron_source'] as String? ?? '';
    bannerIdIosIronSource = json['banner_id_ios_iron_source'] as String? ?? '';
    interstitialIdAndroidIronSource =
        json['interstitial_id_android_iron_source'] as String? ?? '';
    interstitialIdIosIronSource =
        json['interstitial_id_ios_iron_source'] as String? ?? '';
    rewardedIdAndroidIronSource =
        json['rewarded_id_android_iron_source'] as String? ?? '';
    rewardedIdIosIronSource =
        json['rewarded_id_ios_iron_source'] as String? ?? '';
    appKeyIosIronSource = json['app_key_ios_iron_source'] as String? ?? '';
    appKeyAndroidIronSource =
        json['app_key_android_iron_source'] as String? ?? '';
  }

  /// to Check if Ads are enabled in whole App or not.
  late bool adsEnabled;
  late AdType adsType;
  late String androidBannerId;
  late String androidGameID;
  late String androidInterstitialId;
  late String androidRewardedId;
  late AnswerMode answerMode;
  late String appLink;
  late bool appMaintenance;
  late String appVersion;
  late String appVersionIos;
  late bool audioQuestionMode;
  late int audioTimer;
  late bool battleGroupCategoryMode;
  late bool groupBattleMode;
  late bool oneVsOneBattleMode;
  late final bool randomBattleMode;
  late bool randomBattleCategoryMode;
  late int coinAmount;
  late int coinLimit;
  late bool contestMode;
  late String currencySymbol;
  late bool dailyQuizMode;
  late String earnCoin;
  late bool examMode;
  late bool forceUpdate;
  late int funAndLearnTimer;
  late bool funNLearnMode;
  late bool guessTheWordMode;
  late int guessTheWordTimer;
  late bool inAppPurchaseMode;
  late String iosAppLink;
  late String iosBannerId;
  late String iosGameID;
  late String iosInterstitialId;
  late String iosMoreApps;
  late String iosRewardedId;
  late bool languageMode;
  late int lifelineDeductCoins;
  late bool mathQuizMode;
  late int mathsQuizTimer;
  late double quizWinningPercentage;
  late bool paymentMode;
  late int perCoin;

  // TODO(J): remove points etc from random and other battles, no need to calculate anything now, as everything is handled from panel side.
  late int quizTimer;
  late int randomBattleEntryCoins;
  late int randomBattleTimer;
  late String referCoin;
  late int reviewAnswersDeductCoins;
  late int rewardAdsCoin;
  late bool selfChallengeMode;
  late int selfChallengeMaxMinutes;
  late int selfChallengeMaxQuestions;
  late String shareAppText;
  late String systemTimezone;
  late String systemTimezoneGmt;
  late bool truefalseMode;
  late final String botImage;
  late final bool isDailyAdsEnabled;
  late final String coinsPerDailyAdView;
  late final int totalDailyAds;
  late final bool quizZoneMode;

  late final int guessTheWordHintsPerQuiz;
  late final int guessTheWordHintDeductCoins;
  late final RoomCodeCharType groupBattleRoomCodeCharType;
  late final RoomCodeCharType oneVsOneBattleRoomCodeCharType;
  late final int oneVsOneBattleTimer;
  late final int trueAndFalseTimer;

  late final int groupBattleTimer;
  late final int groupBattleMinimumEntryFee;

  late final bool oneVsOneBattleCategoryMode;
  late final int oneVsOneBattleMinimumEntryFee;

  late final int randomBattleOpponentSearchDuration;

  late final int resumeExamAfterCloseTimeout;

  late final bool isLatexModeEnabled;
  late final bool isExamLatexModeEnabled;

  late final bool isEmailLoginEnabled;
  late final bool isGmailLoginEnabled;
  late final bool isAppleLoginEnabled;
  late final bool isPhoneLoginEnabled;

  late final bool multiMatchMode;
  late final int multiMatchDuration;

  late final String appKeyIosIronSource;
  late final String appKeyAndroidIronSource;
  late final String bannerIdAndroidIronSource;
  late final String bannerIdIosIronSource;
  late final String interstitialIdAndroidIronSource;
  late final String interstitialIdIosIronSource;
  late final String rewardedIdAndroidIronSource;
  late final String rewardedIdIosIronSource;
}
