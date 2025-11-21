import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/wallet/repos/wallet_repository.dart';

enum CancelPaymentStatus { initial, loading, success, failure }

final class CancelPaymentRequestState {
  const CancelPaymentRequestState({
    this.status = CancelPaymentStatus.initial,
    this.error,
  });

  CancelPaymentRequestState copyWith({
    CancelPaymentStatus? status,
    String? error,
  }) => CancelPaymentRequestState(
    status: status ?? this.status,
    error: error ?? this.error,
  );

  final CancelPaymentStatus status;
  final String? error;
}

final class CancelPaymentRequestCubit extends Cubit<CancelPaymentRequestState> {
  CancelPaymentRequestCubit(this._walletRepository)
    : super(const CancelPaymentRequestState());

  final WalletRepository _walletRepository;

  void cancelPaymentRequest({required String paymentId}) {
    emit(state.copyWith(status: CancelPaymentStatus.loading));

    _walletRepository
        .cancelPaymentRequest(paymentId: paymentId)
        .then((_) => emit(state.copyWith(status: CancelPaymentStatus.success)))
        .onError(
          (e, st) => emit(
            state.copyWith(
              status: CancelPaymentStatus.failure,
              error: e.toString(),
            ),
          ),
        );
  }
}
