import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/coin_history/models/coin_history.dart';
import 'package:flutterquiz/features/coin_history/repos/coin_history_repository.dart';

sealed class CoinHistoryState {
  const CoinHistoryState();
}

final class CoinHistoryInitial extends CoinHistoryState {
  const CoinHistoryInitial();
}

final class CoinHistoryFetchInProgress extends CoinHistoryState {
  const CoinHistoryFetchInProgress();
}

final class CoinHistoryFetchSuccess extends CoinHistoryState {
  const CoinHistoryFetchSuccess({
    required this.coinHistory,
    required this.totalCoinHistoryCount,
    required this.hasMoreFetchError,
    required this.hasMore,
  });

  final List<CoinHistory> coinHistory;
  final int totalCoinHistoryCount;
  final bool hasMoreFetchError;
  final bool hasMore;
}

class CoinHistoryFetchFailure extends CoinHistoryState {
  CoinHistoryFetchFailure(this.errorMessage);

  final String errorMessage;
}

class CoinHistoryCubit extends Cubit<CoinHistoryState> {
  CoinHistoryCubit(this._repository) : super(const CoinHistoryInitial());

  final CoinHistoryRepository _repository;

  static const int _pageSize = 15;

  CoinHistoryFetchSuccess? get _currentSuccessState =>
      state is CoinHistoryFetchSuccess ? state as CoinHistoryFetchSuccess : null;

  bool get hasMoreHistory => _currentSuccessState?.hasMore ?? false;

  Future<void> fetchInitialHistory() async {
    emit(const CoinHistoryFetchInProgress());

    try {
      final (:total, :data) = await _repository.getCoinHistory(
        limit: _pageSize.toString(),
        offset: '0',
      );

      emit(
        CoinHistoryFetchSuccess(
          coinHistory: data,
          totalCoinHistoryCount: total,
          hasMoreFetchError: false,
          hasMore: data.length < total,
        ),
      );
    } on Exception catch (e) {
      emit(CoinHistoryFetchFailure(e.toString()));
    }
  }

  Future<void> fetchMoreHistory({required String userId}) async {
    final currentState = _currentSuccessState;
    if (currentState == null || !currentState.hasMore) return;

    try {
      final (:total, :data) = await _repository.getCoinHistory(
        limit: _pageSize.toString(),
        offset: currentState.coinHistory.length.toString(),
      );

      final updatedHistory = [...currentState.coinHistory, ...data];

      emit(
        CoinHistoryFetchSuccess(
          coinHistory: updatedHistory,
          totalCoinHistoryCount: total,
          hasMoreFetchError: false,
          hasMore: updatedHistory.length < total,
        ),
      );
    } on Exception catch (_) {
      emit(
        CoinHistoryFetchSuccess(
          coinHistory: currentState.coinHistory,
          totalCoinHistoryCount: currentState.totalCoinHistoryCount,
          hasMoreFetchError: true,
          hasMore: currentState.hasMore,
        ),
      );
    }
  }
}
