final class PaymentRequest {
  const PaymentRequest({
    required this.id,
    required this.userId,
    required this.uid,
    required this.paymentType,
    required this.paymentAddress,
    required this.paymentAmount,
    required this.coinUsed,
    required this.details,
    required this.status,
    required this.date,
  });

  PaymentRequest.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String? ?? '',
      userId = json['user_id'] as String? ?? '',
      uid = json['uid'] as String? ?? '',
      paymentType = json['payment_type'] as String? ?? '',
      paymentAddress = json['payment_address'] as String? ?? '',
      paymentAmount = json['payment_amount'] as String? ?? '',
      coinUsed = json['coin_used'] as String? ?? '',
      details = json['details'] as String? ?? '',
      status = json['status'] as String? ?? '',
      date = json['date'] as String? ?? '';

  final String id;
  final String userId;
  final String uid;
  final String paymentType;
  final String paymentAddress;
  final String paymentAmount;
  final String coinUsed;
  final String details;
  final String status;
  final String date;
}
