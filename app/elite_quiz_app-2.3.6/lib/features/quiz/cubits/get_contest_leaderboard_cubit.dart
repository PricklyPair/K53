import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/contest_leaderboard.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

sealed class GetContestLeaderboardState {
  const GetContestLeaderboardState();
}

class GetContestLeaderboardInitial extends GetContestLeaderboardState {
  const GetContestLeaderboardInitial();
}

class GetContestLeaderboardProgress extends GetContestLeaderboardState {
  const GetContestLeaderboardProgress();
}

class GetContestLeaderboardSuccess extends GetContestLeaderboardState {
  const GetContestLeaderboardSuccess(
    this.getContestLeaderboardList, {
    required this.total,
    required this.hasMore,
  });

  final List<ContestLeaderboard> getContestLeaderboardList;
  final int total;
  final bool hasMore;
}

class GetContestLeaderboardFailure extends GetContestLeaderboardState {
  const GetContestLeaderboardFailure(this.errorMessage);

  final String errorMessage;
}

class GetContestLeaderboardCubit extends Cubit<GetContestLeaderboardState> {
  GetContestLeaderboardCubit(this._quizRepository)
    : super(const GetContestLeaderboardInitial());

  final QuizRepository _quizRepository;

  Future<void> getContestLeaderboard(String contestId) async {
    emit(const GetContestLeaderboardProgress());

    await _quizRepository
        .getContestLeaderboard(contestId, limit: 15)
        .then((result) {
          emit(
            GetContestLeaderboardSuccess(
              result.otherUsersRanks,
              total: result.total,
              hasMore: result.total > result.otherUsersRanks.length,
            ),
          );
        })
        .catchError((Object e) {
          emit(GetContestLeaderboardFailure(e.toString()));
        });
  }

  Future<void> getMoreContestLeaderboardData(String contestId) async {
    if (state is! GetContestLeaderboardSuccess) return;
    if (!(state as GetContestLeaderboardSuccess).hasMore) return;

    final successState = state as GetContestLeaderboardSuccess;

    await _quizRepository
        .getContestLeaderboard(
          contestId,
          limit: 15,
          offset: successState.getContestLeaderboardList.length,
        )
        .then((result) {
          final updatedLeaderboardList = successState.getContestLeaderboardList
            ..addAll(result.otherUsersRanks);

          emit(
            GetContestLeaderboardSuccess(
              updatedLeaderboardList,
              total: result.total,
              hasMore: successState.total > updatedLeaderboardList.length,
            ),
          );
        })
        .catchError((Object e) {
          emit(GetContestLeaderboardFailure(e.toString()));
        });
  }

  bool get hasMoreData =>
      (state is GetContestLeaderboardSuccess) &&
      (state as GetContestLeaderboardSuccess).hasMore;
}
