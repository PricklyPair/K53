import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/screens/dashboard_screen.dart';
import 'package:flutterquiz/features/coin_history/coin_history.dart';
import 'package:flutterquiz/features/wallet/wallet.dart';
import 'package:flutterquiz/ui/screens/about_app_screen.dart';
import 'package:flutterquiz/ui/screens/app_settings_screen.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_in_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_up_screen.dart';
import 'package:flutterquiz/ui/screens/badges_screen.dart';
import 'package:flutterquiz/ui/screens/battle/battle_room_find_opponent_screen.dart';
import 'package:flutterquiz/ui/screens/battle/battle_room_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/battle/multi_user_battle_room_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/battle/multi_user_battle_room_result_screen.dart';
import 'package:flutterquiz/ui/screens/battle/random_battle_screen.dart';
import 'package:flutterquiz/ui/screens/bookmark_screen.dart';
import 'package:flutterquiz/ui/screens/exam/exam_screen.dart';
import 'package:flutterquiz/ui/screens/exam/exams_screen.dart';
import 'package:flutterquiz/ui/screens/inapp_coin_store_screen.dart';
import 'package:flutterquiz/ui/screens/initial_language_selection_screen.dart';
import 'package:flutterquiz/ui/screens/notifications_screen.dart';
import 'package:flutterquiz/ui/screens/onboarding_screen.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/bookmark_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/contest_leaderboard_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/contest_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/fun_and_learn_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/fun_and_learn_title_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_result_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_review_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/result_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/review_answers_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/self_challenge_questions_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/self_challenge_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_and_level_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_screen.dart';
import 'package:flutterquiz/ui/screens/refer_and_earn_screen.dart';
import 'package:flutterquiz/ui/screens/rewards/rewards_screen.dart';
import 'package:flutterquiz/ui/screens/splash_screen.dart';
import 'package:flutterquiz/ui/screens/statistics_screen.dart';

final globalNavigator = GlobalKey<NavigatorState>();
final BuildContext globalCtx = globalNavigator.currentContext!;

class Routes {
  static const home = '/';
  static const login = 'login';
  static const splash = 'splash';
  static const signUp = 'signUp';
  static const introSlider = 'introSlider';
  static const selectProfile = 'selectProfile';
  static const quiz = '/quiz';
  static const multiMatchQuiz = '/multiMatchQuiz';
  static const multiMatchResultScreen = '/multiMatchResultScreen';
  static const multiMatchReviewScreen = '/multiMatchReviewScreen';
  static const subcategoryAndLevel = '/subcategoryAndLevel';
  static const subCategory = '/subCategory';

  static const referAndEarn = '/referAndEarn';
  static const notification = '/notification';
  static const bookmark = '/bookmark';
  static const bookmarkQuiz = '/bookmarkQuiz';
  static const coinStore = '/coinStore';
  static const rewards = '/rewards';
  static const result = '/result';
  static const selectRoom = '/selectRoom';
  static const category = '/category';
  static const editProfile = '/editProfile';
  static const settings = '/settings';
  static const reviewAnswers = '/reviewAnswers';
  static const selfChallenge = '/selfChallenge';
  static const selfChallengeQuestions = '/selfChallengeQuestions';
  static const battleRoomQuiz = '/battleRoomQuiz';
  static const battleRoomFindOpponent = '/battleRoomFindOpponent';

  static const logOut = '/logOut';
  static const trueFalse = '/trueFalse';
  static const multiUserBattleRoomQuiz = '/multiUserBattleRoomQuiz';
  static const multiUserBattleRoomQuizResult = '/multiUserBattleRoomQuizResult';

  static const contest = '/contest';
  static const contestLeaderboard = '/contestLeaderboard';
  static const funAndLearnTitle = '/funAndLearnTitle';
  static const funAndLearn = 'funAndLearn';
  static const guessTheWord = '/guessTheWord';
  static const appSettings = '/appSettings';
  static const levels = '/levels';
  static const aboutApp = '/aboutApp';
  static const badges = '/badges';
  static const exams = '/exams';
  static const exam = '/exam';
  static const otpScreen = '/otpScreen';
  static const statistics = '/statistics';
  static const coinHistory = '/coinHistory';
  static const wallet = '/wallet';
  static const randomBattle = '/randomBattle';
  static const languageSelect = '/language-select';

  static String currentRoute = splash;

  static Route<dynamic>? onGenerateRouted(RouteSettings rs) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = rs.name ?? '';

    if (rs.name!.contains('/link')) {
      return null;
    }

    log(name: 'Current Route', currentRoute);

    switch (rs.name) {
      case splash:
        return SplashScreen.route();
      case home:
        return DashboardScreen.route();
      case introSlider:
        return IntroSliderScreen.route();
      case login:
        return SignInScreen.route();
      case signUp:
        return SignUpScreen.route();
      case otpScreen:
        return OtpScreen.route();
      case subcategoryAndLevel:
        return SubCategoryAndLevelScreen.route(rs);
      case selectProfile:
        return CreateOrEditProfileScreen.route(rs);
      case quiz:
        return QuizScreen.route(rs);
      case multiMatchQuiz:
        return MultiMatchQuizScreen.route(rs);
      case multiMatchResultScreen:
        return MultiMatchResultScreen.route(rs);
      case multiMatchReviewScreen:
        return MultiMatchReviewScreen.route(rs);
      case wallet:
        return WalletScreen.route();
      case coinStore:
        return CoinStoreScreen.route();
      case rewards:
        return RewardsScreen.route(rs);
      case referAndEarn:
        return ReferAndEarnScreen.route();
      case result:
        return ResultScreen.route(rs);
      case reviewAnswers:
        return ReviewAnswersScreen.route(rs);
      case selfChallenge:
        return SelfChallengeScreen.route(rs);
      case selfChallengeQuestions:
        return SelfChallengeQuestionsScreen.route(rs);
      case category:
        return CategoryScreen.route(rs);
      case bookmark:
        return BookmarkScreen.route();
      case bookmarkQuiz:
        return BookmarkQuizScreen.route(rs);
      case battleRoomQuiz:
        return BattleRoomQuizScreen.route(rs);
      case notification:
        return NotificationScreen.route(rs);
      case funAndLearnTitle:
        return FunAndLearnTitleScreen.route(rs);
      case funAndLearn:
        return FunAndLearnScreen.route(rs);
      case multiUserBattleRoomQuiz:
        return MultiUserBattleRoomQuizScreen.route(rs);
      case contest:
        return ContestScreen.route(rs);
      case guessTheWord:
        return GuessTheWordQuizScreen.route(rs);
      case multiUserBattleRoomQuizResult:
        return MultiUserBattleRoomResultScreen.route(rs);
      case contestLeaderboard:
        return ContestLeaderBoardScreen.route(rs);
      case battleRoomFindOpponent:
        return BattleRoomFindOpponentScreen.route(rs);
      case appSettings:
        return AppSettingsScreen.route(rs);
      case levels:
        return LevelsScreen.route(rs);
      case coinHistory:
        return CoinHistoryScreen.route();
      case aboutApp:
        return AboutAppScreen.route();
      case subCategory:
        return SubCategoryScreen.route(rs);
      case badges:
        return BadgesScreen.route(rs);
      case exams:
        return ExamsScreen.route();
      case exam:
        return ExamScreen.route(rs);
      case statistics:
        return StatisticsScreen.route();
      case randomBattle:
        return RandomBattleScreen.route(rs);
      case languageSelect:
        return InitialLanguageSelectionScreen.route();
      default:
        return CupertinoPageRoute(builder: (_) => const Scaffold());
    }
  }
}
