import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/badges_repository.dart';

abstract class BadgesState {}

class BadgesInitial extends BadgesState {}

class BadgesFetchInProgress extends BadgesState {}

class BadgesFetchSuccess extends BadgesState {
  BadgesFetchSuccess(this.badges);

  final List<Badges> badges;
}

class BadgesFetchFailure extends BadgesState {
  BadgesFetchFailure(this.errorMessage);

  final String errorMessage;
}

class BadgesCubit extends Cubit<BadgesState> {
  BadgesCubit(this.badgesRepository) : super(BadgesInitial());
  final BadgesRepository badgesRepository;

  void updateState(BadgesState updatedState) {
    emit(updatedState);
  }

  Future<void> getBadges() async {
    emit(BadgesFetchInProgress());
    await badgesRepository
        .getBadges()
        .then((value) {
          emit(BadgesFetchSuccess(value));
        })
        .catchError((dynamic e) {
          emit(BadgesFetchFailure(e.toString()));
        });
  }

  //update badges
  void _updateBadge(String badgeType, BadgesStatus status) {
    if (state is BadgesFetchSuccess) {
      final currentBadges = (state as BadgesFetchSuccess).badges;
      final updatedBadges = List<Badges>.from(currentBadges);
      final badgeIndex = currentBadges.indexWhere(
        (element) => element.type == badgeType,
      );
      updatedBadges[badgeIndex] = currentBadges[badgeIndex].copyWith(
        updatedStatus: status,
      );
      emit(BadgesFetchSuccess(updatedBadges));
    }
  }

  void unlockBadge(String badgeType) {
    _updateBadge(badgeType, BadgesStatus.unlocked);
  }

  void unlockReward(String badgeType) {
    _updateBadge(badgeType, BadgesStatus.rewardUnlocked);
  }

  //
  // ignore: avoid_bool_literals_in_conditional_expressions
  bool isBadgeLocked(String badgeType) => state is BadgesFetchSuccess
      ? (state as BadgesFetchSuccess).badges
                .firstWhere((e) => e.type == badgeType)
                .status ==
            BadgesStatus.locked
      : true;

  List<Badges> getUnlockedBadges() => state is BadgesFetchSuccess
      ? (state as BadgesFetchSuccess).badges
            .where((e) => e.status != BadgesStatus.locked)
            .toList()
      : [];

  //
  // ignore: avoid_bool_literals_in_conditional_expressions
  bool isRewardUnlocked(String badgeType) => state is BadgesFetchSuccess
      ? (state as BadgesFetchSuccess).badges
                .firstWhere((e) => e.type == badgeType)
                .status ==
            BadgesStatus.rewardUnlocked
      : true;

  List<Badges> getAllBadges() {
    if (state is BadgesFetchSuccess) {
      return (state as BadgesFetchSuccess).badges;
    }
    return [];
  }

  int getBadgeCounterByType(String type) {
    if (state is BadgesFetchSuccess) {
      final badges = (state as BadgesFetchSuccess).badges;
      return int.parse(
        badges[badges.indexWhere((element) => element.type == type)]
            .badgeCounter,
      );
    }
    return -1;
  }

  List<Badges> getRewards() {
    final rewards = getAllBadges()
        .where((e) => e.status != BadgesStatus.locked)
        .toList();

    final scratchedRewards = rewards
        .where((e) => e.status == BadgesStatus.rewardUnlocked)
        .toList();
    final unscratchedRewards = rewards
        .where((e) => e.status == BadgesStatus.unlocked)
        .toList();

    return [...unscratchedRewards, ...scratchedRewards];
  }

  int getRewardedCoins() {
    final rewards = getRewards();
    var totalCoins = 0;
    for (final element in rewards) {
      if (element.status == BadgesStatus.rewardUnlocked) {
        totalCoins = int.parse(element.badgeReward) + totalCoins;
      }
    }

    return totalCoins;
  }
}
