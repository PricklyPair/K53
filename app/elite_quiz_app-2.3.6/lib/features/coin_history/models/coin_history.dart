final class CoinHistory {
  const CoinHistory({
    required this.id,
    required this.userId,
    required this.uid,
    required this.points,
    required this.type,
    required this.status,
    required this.date,
  });

  CoinHistory.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String? ?? '',
      userId = json['user_id'] as String? ?? '',
      uid = json['uid'] as String? ?? '',
      points = json['points'] as String? ?? '',
      type = json['type'] as String? ?? '',
      status = json['status'] as String? ?? '',
      date = json['date'] as String? ?? '';

  final String id;
  final String userId;
  final String uid;
  final String points;
  final String type;
  final String status;
  final String date;

  /// Returns true if this transaction is a deduction (status == '1')
  bool get isDeduction => status == '1';

  /// Returns the parsed integer points value
  int get pointsValue => int.tryParse(points) ?? 0;

  /// Returns the parsed DateTime from date string
  DateTime? get dateTime => DateTime.tryParse(date);
}
