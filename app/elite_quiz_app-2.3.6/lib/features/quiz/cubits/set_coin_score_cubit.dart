import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class SetCoinScoreState {
  const SetCoinScoreState();
}

final class SetCoinScoreInitial extends SetCoinScoreState {
  const SetCoinScoreInitial();
}

class SetCoinScoreInProgress extends SetCoinScoreState {
  const SetCoinScoreInProgress();
}

class SetCoinScoreFailure extends SetCoinScoreState {
  const SetCoinScoreFailure(this.error);

  final String error;
}

class SetCoinScoreSuccess extends SetCoinScoreState {
  const SetCoinScoreSuccess({
    required this.totalQuestions,
    required this.correctAnswer,
    required this.percentage,
    required this.earnCoin,
    required this.earnScore,
    required this.currentLevel,
    required this.totalLevels,
    this.userId,
    this.user1Id,
    this.user2Id,
    this.user3Id,
    this.user4Id,
    this.winnerUserId,
    this.winnersIds = const [],
    this.userRanks = const [],
    this.winnerCoins,
    this.user1Data,
    this.user2Data,
  });

  final int totalQuestions;
  final int correctAnswer;
  final int percentage;
  final int earnCoin;
  final int earnScore;
  final int currentLevel;
  final int totalLevels;

  /// Battle Data
  final String? userId;
  final String? user1Id;
  final String? user2Id;
  final String? user3Id;
  final String? user4Id;
  final String? winnerUserId;
  final int? winnerCoins;
  final BattleUserData? user1Data;
  final BattleUserData? user2Data;
  final List<String> winnersIds;
  final List<BattleUserRank> userRanks;

  bool get isWinner => userId == winnerUserId;
  bool get isDraw => winnerUserId == null || winnerUserId! == '0';
}

final class BattleUserRank {
  const BattleUserRank({
    required this.userId,
    required this.rank,
    required this.correctAnswers,
  });

  BattleUserRank.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'].toString(),
      rank = int.parse(json['rank']?.toString() ?? '0'),
      correctAnswers = int.parse(json['correct_answer']?.toString() ?? '0');

  final String userId;
  final int rank;
  final int correctAnswers;
}

final class BattleUserData {
  const BattleUserData({
    required this.correctAnswers,
    required this.points,
    required this.earnedCoins,
    required this.isQuickest,
    required this.quickestBonus,
    required this.secondQuickestBonus,
  });

  BattleUserData.fromJson(Map<String, dynamic> json)
    : correctAnswers = int.parse(json['correctAnswer']?.toString() ?? '0'),
      points = int.parse(json['userPoints']?.toString() ?? '0'),
      earnedCoins = int.parse(json['earnCoin']?.toString() ?? '0'),
      isQuickest = json['is_quickest'] as bool? ?? false,
      quickestBonus = int.parse(json['quickest_bonus']?.toString() ?? '0'),
      secondQuickestBonus = int.parse(
        json['second_quickest_bonus']?.toString() ?? '0',
      );

  final int correctAnswers;
  final int points;
  final int earnedCoins;
  final bool isQuickest;
  final int quickestBonus;
  final int secondQuickestBonus;
}

class SetCoinScoreCubit extends Cubit<SetCoinScoreState> {
  SetCoinScoreCubit() : super(const SetCoinScoreInitial());

  final _repo = QuizRepository();

  Future<void> setCoinScore({
    required String quizType,
    required dynamic playedQuestions,
    String? categoryId,
    String? subcategoryId,
    List<String>? lifelines,
    String? roomId,
    bool? playWithBot,
    int? noOfHintUsed,
    String? matchId,
    int? joinedUsersCount,
  }) async {
    emit(const SetCoinScoreInProgress());
    try {
      final result = await _repo.setQuizCoinScore(
        categoryId: categoryId,
        quizType: quizType,
        playedQuestions: playedQuestions,
        subcategoryId: subcategoryId,
        lifelines: lifelines,
        roomId: roomId,
        playWithBot: playWithBot,
        noOfHintUsed: noOfHintUsed,
        matchId: matchId,
        joinedUsersCount: joinedUsersCount,
      );

      emit(
        SetCoinScoreSuccess(
          totalQuestions: int.parse(
            result['total_questions']?.toString() ?? '0',
          ),
          correctAnswer: int.parse(result['correctAnswer']?.toString() ?? '0'),
          percentage: double.parse(
            result['winningPer']?.toString() ?? '0',
          ).toInt(),
          earnCoin: int.parse(result['earnCoin']?.toString() ?? '0'),
          earnScore: int.parse(result['userScore']?.toString() ?? '0'),
          currentLevel: int.parse(result['currentLevel']?.toString() ?? '0'),
          totalLevels: int.parse(result['totalLevel']?.toString() ?? '0'),
          userId: result['user_id']?.toString(),
          user1Id: result['user1_id']?.toString(),
          user2Id: result['user2_id']?.toString(),
          user3Id: result['user3_id']?.toString(),
          user4Id: result['user4_id']?.toString(),
          winnerUserId: result['winner_user_id']?.toString(),
          winnerCoins: int.parse(result['winner_coin']?.toString() ?? '0'),
          user1Data: result['user1_data'] != null
              ? BattleUserData.fromJson(
                  result['user1_data'] as Map<String, dynamic>,
                )
              : null,
          user2Data: result['user2_data'] != null
              ? BattleUserData.fromJson(
                  result['user2_data'] as Map<String, dynamic>,
                )
              : null,
          winnersIds: (result['winners_ids'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
          userRanks:
              (result['user_rank'] as Map<String, dynamic>? ?? {}).values
                  .map(
                    (e) => BattleUserRank.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
                ..sort((a, b) => a.rank.compareTo(b.rank)),
        ),
      );
    } on Exception catch (e) {
      emit(SetCoinScoreFailure(e.toString()));
    }
  }
}
