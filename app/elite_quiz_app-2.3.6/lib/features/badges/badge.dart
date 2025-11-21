class Badges {
  Badges({
    required this.id,
    required this.type,
    required this.badgeReward,
    required this.badgeIcon,
    required this.badgeCounter,
    required this.status,
  });

  Badges.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String? ?? '';
    type = json['type'] as String? ?? '';
    badgeReward = json['badge_reward'] as String? ?? '';
    badgeIcon = json['badge_icon'] as String? ?? '';
    badgeCounter = json['badge_counter'] as String? ?? '';
    status = BadgesStatus.fromString(json['status'] as String? ?? '0');
  }

  late final String id;
  late final String type;
  late final String badgeReward;
  late final String badgeIcon;
  late final String badgeCounter;
  late final BadgesStatus status;

  Badges copyWith({BadgesStatus? updatedStatus}) {
    return Badges(
      id: id,
      type: type,
      badgeReward: badgeReward,
      badgeIcon: badgeIcon,
      badgeCounter: badgeCounter,
      status: updatedStatus ?? status,
    );
  }
}

enum BadgesStatus {
  locked('0'),
  unlocked('1'),
  rewardUnlocked('2');

  const BadgesStatus(this.value);

  final String value;

  static BadgesStatus fromString(String value) => BadgesStatus.values
      .firstWhere((e) => e.value == value, orElse: () => BadgesStatus.locked);
}
