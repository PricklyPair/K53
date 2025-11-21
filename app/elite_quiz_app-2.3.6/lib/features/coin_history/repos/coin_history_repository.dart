import 'package:flutterquiz/features/coin_history/models/coin_history.dart';
import 'package:flutterquiz/features/coin_history/repos/coin_history_remote_data_source.dart';

final class CoinHistoryRepository {
  factory CoinHistoryRepository() => _instance;

  CoinHistoryRepository._() {
    _coinHistoryRemoteDataSource = const CoinHistoryRemoteDataSource();
  }

  static final CoinHistoryRepository _instance = CoinHistoryRepository._();

  late final CoinHistoryRemoteDataSource _coinHistoryRemoteDataSource;

  Future<({int total, List<CoinHistory> data})> getCoinHistory({
    required String offset,
    required String limit,
  }) async {
    final (:total, :data) = await _coinHistoryRemoteDataSource.getCoinHistory(
      limit: limit,
      offset: offset,
    );

    return (total: total, data: data.map(CoinHistory.fromJson).toList());
  }
}
