import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/badges_exception.dart';
import 'package:flutterquiz/features/badges/badges_remote_data_source.dart';

class BadgesRepository {
  factory BadgesRepository() {
    _badgesRepository._badgesRemoteDataSource = BadgesRemoteDataSource();
    return _badgesRepository;
  }

  BadgesRepository._internal();

  static final _badgesRepository = BadgesRepository._internal();
  late BadgesRemoteDataSource _badgesRemoteDataSource;

  Future<List<Badges>> getBadges() async {
    try {
      final result = await _badgesRemoteDataSource.getBadges();

      return result.map(Badges.fromJson).toList();
    } catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    }
  }
}
