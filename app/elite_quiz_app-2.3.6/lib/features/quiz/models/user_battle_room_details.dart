class UserBattleRoomDetails {
  const UserBattleRoomDetails({
    required this.points,
    required this.answers,
    required this.correctAnswers,
    required this.name,
    required this.profileUrl,
    required this.uid,
  });

  UserBattleRoomDetails.fromJson(Map<String, dynamic> json)
    : answers = (json['answers'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Map<String, String>.from)
          .toList(),
      points = int.tryParse(json['points'].toString()) ?? 0,
      correctAnswers = json['correctAnswers'] as int? ?? 0,
      name = json['name'] as String? ?? '',
      profileUrl = json['profileUrl'] as String? ?? '',
      uid = json['uid'] as String? ?? '';

  final String name;
  final String profileUrl;
  final String uid;
  final int correctAnswers;
  final List<Map<String, String>> answers;
  final int points;
}
