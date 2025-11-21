import 'package:flutterquiz/features/wallet/models/payment_request.dart';
import 'package:flutterquiz/features/wallet/repos/wallet_remote_data_source.dart';

final class WalletRepository {
  factory WalletRepository() => _instance;

  WalletRepository._() {
    // Initialize data source once when singleton is created
    _walletRemoteDataSource = const WalletRemoteDataSource();
  }

  static final _instance = WalletRepository._();

  late final WalletRemoteDataSource _walletRemoteDataSource;

  Future<void> makePaymentRequest({
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    await _walletRemoteDataSource.makePaymentRequest(
      paymentType: paymentType,
      paymentAddress: paymentAddress,
      paymentAmount: paymentAmount,
      coinUsed: coinUsed,
      details: details,
    );
  }

  Future<({int total, List<PaymentRequest> data})> getTransactions({
    required String limit,
    required String offset,
  }) async {
    final (:total, :data) = await _walletRemoteDataSource.getTransactions(
      limit: limit,
      offset: offset,
    );

    return (total: total, data: data.map(PaymentRequest.fromJson).toList());
  }

  Future<bool> cancelPaymentRequest({required String paymentId}) async {
    return _walletRemoteDataSource.cancelPaymentRequest(paymentId: paymentId);
  }
}
