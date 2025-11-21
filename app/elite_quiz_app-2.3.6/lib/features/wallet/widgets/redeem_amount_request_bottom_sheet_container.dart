import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/wallet/blocs/payment_request_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';

final class RedeemAmountRequestBottomSheetContainer extends StatefulWidget {
  const RedeemAmountRequestBottomSheetContainer({
    required this.deductedCoins,
    required this.redeemableAmount,
    required this.paymentRequestCubit,
    super.key,
  });

  final double redeemableAmount;
  final int deductedCoins;

  final PaymentRequestCubit paymentRequestCubit;

  @override
  State<RedeemAmountRequestBottomSheetContainer> createState() =>
      _RedeemAmountRequestBottomSheetContainerState();
}

class _RedeemAmountRequestBottomSheetContainerState
    extends State<RedeemAmountRequestBottomSheetContainer>
    with TickerProviderStateMixin {
  late final List<TextEditingController> _inputDetailsControllers =
      kPayoutMethods[_selectedPaymentMethodIndex].inputs
          .map((e) => TextEditingController())
          .toList();

  late double _selectPaymentMethodDx = 0;

  late int _selectedPaymentMethodIndex = 0;
  late int _enterPayoutMethodDx = 1;
  late String _errorMessage = '';

  @override
  void dispose() {
    for (final element in _inputDetailsControllers) {
      element.dispose();
    }
    super.dispose();
  }

  Widget _buildPaymentSelectMethodContainer({required int paymentMethodIndex}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = paymentMethodIndex;
          _inputDetailsControllers.clear();
          for (final _ in kPayoutMethods[_selectedPaymentMethodIndex].inputs) {
            _inputDetailsControllers.add(TextEditingController());
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: context.width * .175,
        height: context.width * .175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedPaymentMethodIndex == paymentMethodIndex
                ? Colors.transparent
                : context.primaryTextColor.withValues(alpha: 0.6),
          ),
          color: _selectedPaymentMethodIndex == paymentMethodIndex
              ? context.primaryColor
              : context.scaffoldBackgroundColor,
        ),
        child: QImage(imageUrl: kPayoutMethods[paymentMethodIndex].image),
      ),
    );
  }

  Widget _buildInputDetailsContainer(int inputDetailsIndex) {
    final input =
        kPayoutMethods[_selectedPaymentMethodIndex].inputs[inputDetailsIndex];

    final inputFormatters = input.isNumber
        ? [FilteringTextInputFormatter.digitsOnly]
        : <TextInputFormatter>[];
    if (input.maxLength > 0) {
      inputFormatters.add(LengthLimitingTextInputFormatter(input.maxLength));
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: context.width * .1),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      height: context.height * 0.05,
      child: TextField(
        controller: _inputDetailsControllers[inputDetailsIndex],
        textAlign: TextAlign.center,
        keyboardType: input.isNumber ? TextInputType.phone : TextInputType.text,
        inputFormatters: inputFormatters,
        style: TextStyle(color: context.primaryTextColor),
        cursorColor: context.primaryTextColor,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: input.name,
          hintStyle: TextStyle(
            fontSize: 16,
            color: context.primaryTextColor.withValues(alpha: .6),
          ),
        ),
      ),
    );
  }

  Widget _buildEnterPayoutMethodDetailsContainer() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(0, 3, context.width * _enterPayoutMethodDx),
      duration: const Duration(milliseconds: 500),
      child: BlocConsumer<PaymentRequestCubit, PaymentRequestState>(
        listener: (context, state) {
          if (state is PaymentRequestFailure) {
            if (state.errorMessage == errorCodeUnauthorizedAccess) {
              showAlreadyLoggedInDialog(context);
              return;
            }
            setState(() {
              _errorMessage = context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!;
            });
          } else if (state is PaymentRequestSuccess) {
            context.read<UserDetailsCubit>().updateCoins(
              addCoin: false,
              coins: widget.deductedCoins,
            );
          }
        },
        bloc: widget.paymentRequestCubit,
        builder: (context, state) {
          if (state is PaymentRequestSuccess) {
            return Column(
              children: [
                //
                SizedBox(height: context.height * 0.025),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    context.tr(successfullyRequestedKey)!,
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: context.height * 0.025),
                LottieBuilder.asset(
                  'assets/animations/success.json',
                  fit: BoxFit.cover,
                  animate: true,
                  height: context.height * 0.2,
                ),

                SizedBox(height: context.height * 0.025),
                CustomRoundedButton(
                  widthPercentage: 0.525,
                  backgroundColor: context.primaryColor,
                  buttonTitle: context.tr(trackRequestKey),
                  radius: 15,
                  showBorder: false,
                  titleColor: context.surfaceColor,
                  fontWeight: FontWeight.bold,
                  textSize: 17,
                  onTap: () => context.shouldPop(true),
                  height: 40,
                ),
              ],
            );
          }

          final payoutMethod = kPayoutMethods[_selectedPaymentMethodIndex];

          return Column(
            children: [
              SizedBox(height: context.height * .015),
              //
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${context.tr(payoutMethodKey)!} - ${payoutMethod.type}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeights.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              SizedBox(height: context.height * .025),

              for (var i = 0; i < payoutMethod.inputs.length; i++)
                _buildInputDetailsContainer(i),

              SizedBox(height: context.height * 0.01),

              AnimatedOpacity(
                opacity: _errorMessage.isEmpty ? 0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.height * .0125),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width * UiUtils.hzMarginPct,
                ),
                child: CustomRoundedButton(
                  widthPercentage: 1,
                  backgroundColor: context.primaryColor,
                  buttonTitle: state is PaymentRequestInProgress
                      ? context.tr(requestingKey)
                      : context.tr(makeRequestKey),
                  radius: 10,
                  showBorder: false,
                  titleColor: context.surfaceColor,
                  fontWeight: FontWeight.bold,
                  textSize: 18,
                  onTap: () {
                    var isAnyInputFieldEmpty = false;
                    for (final textEditingController
                        in _inputDetailsControllers) {
                      if (textEditingController.text.trim().isEmpty) {
                        isAnyInputFieldEmpty = true;

                        break;
                      }
                    }

                    if (isAnyInputFieldEmpty) {
                      setState(() {
                        _errorMessage = context.tr(pleaseFillAllDataKey)!;
                      });
                      return;
                    }

                    widget.paymentRequestCubit.makePaymentRequest(
                      paymentType: payoutMethod.type,
                      paymentAddress: jsonEncode(
                        _inputDetailsControllers
                            .map((e) => e.text.trim())
                            .toList(),
                      ),
                      paymentAmount: widget.redeemableAmount.toString(),
                      coinUsed: widget.deductedCoins.toString(),
                      details: context.tr('redeemRequest')!,
                    );
                  },
                  height: 50,
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _selectPaymentMethodDx = 0;
                    _enterPayoutMethodDx = 1;
                    _errorMessage = '';
                  });
                },
                child: Text(
                  context.tr(changePayoutMethodKey)!,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeights.semiBold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPayoutSelectMethodContainer() {
    final children = <Widget>[];
    for (var i = 0; i < kPayoutMethods.length; i++) {
      children.add(_buildPaymentSelectMethodContainer(paymentMethodIndex: i));
    }
    return children;
  }

  Widget _buildSelectPayoutOption() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(0, 3, context.width * _selectPaymentMethodDx),
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Text(
                context.tr('payoutMethod')!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: context.primaryTextColor,
                ),
              ),
              const Divider(),
              Text(
                context.tr(redeemableAmountKey)!,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 18,
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${context.read<SystemConfigCubit>().payoutRequestCurrency} ${widget.redeemableAmount}',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeights.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${widget.deductedCoins} ${context.tr(coinsWillBeDeductedKey)}',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeights.medium,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: const Divider(),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              context.tr(selectPayoutOptionKey)!,
              style: TextStyle(
                color: context.primaryTextColor,
                fontWeight: FontWeights.medium,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: context.height * 0.55 * 0.05),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: Wrap(
              //alignment: WrapAlignment.center,
              children: _buildPayoutSelectMethodContainer(),
            ),
          ),
          SizedBox(height: context.height * 0.55 * 0.075),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: CustomRoundedButton(
              widthPercentage: 1,
              backgroundColor: context.primaryColor,
              buttonTitle: context.tr(continueLbl),
              radius: 10,
              showBorder: false,
              titleColor: context.colorScheme.surface,
              fontWeight: FontWeight.bold,
              textSize: 18,
              onTap: () {
                setState(() {
                  _selectPaymentMethodDx = -1;
                  _enterPayoutMethodDx = 0;
                });
              },
              height: 50,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.height * .8),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  _buildSelectPayoutOption(),
                  _buildEnterPayoutMethodDetailsContainer(),
                ],
              ),
              SizedBox(height: context.height * .05),
            ],
          ),
        ),
      ),
    );
  }
}
