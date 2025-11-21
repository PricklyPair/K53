import 'package:flutterquiz/features/statistic/models/statistic_model.dart';
import 'package:flutterquiz/features/statistic/statistic_exception.dart';
import 'package:flutterquiz/features/statistic/statistic_remote_data_source.dart';

class StatisticRepository {
  factory StatisticRepository() {
    _statisticRepository._statisticRemoteDataSource =
        StatisticRemoteDataSource();

    return _statisticRepository;
  }

  StatisticRepository._internal();

  static final StatisticRepository _statisticRepository =
      StatisticRepository._internal();
  late StatisticRemoteDataSource _statisticRemoteDataSource;

  Future<StatisticModel> getStatistic({
    required bool getBattleStatistics,
  }) async {
    try {
      final result = await _statisticRemoteDataSource.getStatistic();
      if (getBattleStatistics) {
        final battleResult = await _statisticRemoteDataSource
            .getBattleStatistic();
        final battleStatistics = <String, dynamic>{};
        final myReports = (battleResult['myreport'] as List)
            .cast<Map<String, dynamic>>()
            .first;

        for (final element in myReports.keys) {
          battleStatistics.addAll({element: myReports[element]});
        }

        battleStatistics['playedBattles'] =
            (battleResult['data'] as List? ?? []).cast<Map<String, dynamic>>();

        return StatisticModel.fromJson(result, battleStatistics);
      }
      return StatisticModel.fromJson(result, {});
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }
}
