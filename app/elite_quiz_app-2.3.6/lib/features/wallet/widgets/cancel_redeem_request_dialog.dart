import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/wallet/blocs/cancel_payment_request_cubit.dart';
import 'package:flutterquiz/features/wallet/repos/wallet_repository.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';

Future<bool?> showCancelRequestDialog({
  required BuildContext context,
  required String paymentId,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (_) => BlocProvider(
      lazy: false,
      create: (_) => CancelPaymentRequestCubit(WalletRepository()),
      child: _CancelRedeemRequestDialog(paymentId: paymentId),
    ),
  );
}

class _CancelRedeemRequestDialog extends StatelessWidget {
  const _CancelRedeemRequestDialog({required this.paymentId});

  final String paymentId;

  void listener(BuildContext context, CancelPaymentRequestState state) {
    if (state.status == CancelPaymentStatus.success) {
      context.read<UserDetailsCubit>().fetchUserDetails().then((_) {
        context.shouldPop(true);
      });
    }

    if (state.status == CancelPaymentStatus.failure) {
      context
        ..shouldPop(false)
        ..showSnack('${state.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTapCancel() {
      context.read<CancelPaymentRequestCubit>().cancelPaymentRequest(
        paymentId: paymentId,
      );
    }

    return BlocConsumer<CancelPaymentRequestCubit, CancelPaymentRequestState>(
      listener: listener,
      builder: (context, state) {
        if (state.status == CancelPaymentStatus.initial) {
          return AlertDialog(
            title: Text(
              context.tr('cancelPaymentConfirmation')!,
              style: context.bodyLarge?.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: context.shouldPop,
                child: Text(
                  context.tr('close')!,
                  style: context.titleMedium?.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
              ),

              ///
              TextButton(
                onPressed: onTapCancel,
                style: TextButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '${context.tr('yesBtn')!}, ${context.tr('cancel')!}',
                  style: context.titleMedium?.copyWith(
                    color: context.surfaceColor,
                  ),
                ),
              ),
            ],
          );
        }

        return const AlertDialog(title: CircularProgressContainer());
      },
    );
  }
}
