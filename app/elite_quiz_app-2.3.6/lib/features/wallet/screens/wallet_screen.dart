import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/wallet/blocs/payment_request_cubit.dart';
import 'package:flutterquiz/features/wallet/blocs/transactions_cubit.dart';
import 'package:flutterquiz/features/wallet/models/payment_request.dart';
import 'package:flutterquiz/features/wallet/repos/wallet_repository.dart';
import 'package:flutterquiz/features/wallet/widgets/animated_coin_display.dart';
import 'package:flutterquiz/features/wallet/widgets/cancel_redeem_request_dialog.dart';
import 'package:flutterquiz/features/wallet/widgets/redeem_amount_request_bottom_sheet_container.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

final class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PaymentRequestCubit>(
            create: (_) => PaymentRequestCubit(WalletRepository()),
          ),
          BlocProvider<TransactionsCubit>(
            create: (_) => TransactionsCubit(WalletRepository()),
          ),
        ],
        child: const WalletScreen(),
      ),
    );
  }
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  TextEditingController? redeemableAmountTextEditingController;

  late final ScrollController _transactionsScrollController = ScrollController()
    ..addListener(hasMoreTransactionsScrollListener);

  late final String payoutRequestCurrency = context
      .read<SystemConfigCubit>()
      .payoutRequestCurrency;
  late final int minimumCoinLimit = context
      .read<SystemConfigCubit>()
      .minimumCoinLimit;

  // Pay Amount (Y) given per X Coins
  late final int coinAmount = context.read<SystemConfigCubit>().coinAmount;
  // No. of Coins (X) needed to Earn Pay Amount Y
  late final int perCoin = context.read<SystemConfigCubit>().perCoin;

  void hasMoreTransactionsScrollListener() {
    if (_transactionsScrollController.position.maxScrollExtent ==
        _transactionsScrollController.offset) {
      if (context.read<TransactionsCubit>().hasMoreTransactions()) {
        fetchMoreTransactions();
      } else {
        dev.log(name: 'Payout Transactions', 'No more transactions');
      }
    }
  }

  void fetchTransactions() {
    unawaited(context.read<TransactionsCubit>().getTransactions());
  }

  void fetchMoreTransactions() {
    unawaited(context.read<TransactionsCubit>().getMoreTransactions());
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this)
      ..addListener(() => FocusScope.of(context).unfocus());
    Future.delayed(Duration.zero, () {
      fetchTransactions();

      final userCoins = double.parse(
        context.read<UserDetailsCubit>().getCoins()!,
      ).toInt();

      redeemableAmountTextEditingController = TextEditingController(
        text: UiUtils.calculateAmountPerCoins(
          userCoins: userCoins,
          amount: coinAmount,
          coins: perCoin,
        ).toString(),
      );

      //InterstitialAds show
      Future.delayed(Duration.zero, () async {
        await context.read<InterstitialAdCubit>().showAd(context);
      });

      setState(() {});
    });
  }

  double _minimumRedeemableAmount() {
    return UiUtils.calculateAmountPerCoins(
      userCoins: minimumCoinLimit,
      amount: coinAmount,
      coins: perCoin,
    );
  }

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    _transactionsScrollController
      ..removeListener(hasMoreTransactionsScrollListener)
      ..dispose();
    tabController.dispose();
    super.dispose();
  }

  Future<void> showRedeemRequestAmountBottomSheet({
    required int deductedCoins,
    required double redeemableAmount,
  }) async {
    await showModalBottomSheet<bool>(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) {
        return RedeemAmountRequestBottomSheetContainer(
          paymentRequestCubit: context.read<PaymentRequestCubit>(),
          deductedCoins: deductedCoins,
          redeemableAmount: redeemableAmount,
        );
      },
    ).then((value) {
      if (value != null && value) {
        context.read<PaymentRequestCubit>().reset();
        fetchTransactions();
        redeemableAmountTextEditingController
            ?.text = UiUtils.calculateAmountPerCoins(
          userCoins: int.parse(context.read<UserDetailsCubit>().getCoins()!),
          amount: coinAmount,
          coins: perCoin,
        ).toString();
        tabController.animateTo(1);
      }
    });
  }

  Widget _buildPayoutRequestNote(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: .6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              note,
              style: TextStyle(
                color: context.primaryTextColor.withValues(alpha: .6),
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: context.height * 0.02,
        left: context.width * 0.05,
        right: context.width * 0.05,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.primaryTextColor.withValues(alpha: .08),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Total Coins Section
                Text(
                  context.tr(totalCoinsKey)!,
                  style: TextStyle(
                    color: context.primaryTextColor.withValues(alpha: .6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                BlocSelector<UserDetailsCubit, UserDetailsState, String?>(
                  selector: (state) {
                    if (state is UserDetailsFetchSuccess) {
                      return state.userProfile.coins;
                    }
                    return null;
                  },
                  builder: (context, coins) {
                    if (coins == null) return const SizedBox.shrink();

                    return AnimatedCoinDisplay(coins: coins);
                  },
                ),

                // divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    color: context.primaryTextColor.withValues(alpha: .08),
                    height: 1,
                  ),
                ),

                /// Redeemable Amount Label
                Row(
                  children: [
                    Text(
                      context.tr(redeemableAmountKey)!,
                      style: TextStyle(
                        color: context.primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Amount Input Field
                Container(
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor.withValues(
                      alpha: .8,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.primaryColor.withValues(alpha: .2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Currency symbol
                      Text(
                        payoutRequestCurrency,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                            letterSpacing: 0.5,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          controller: redeemableAmountTextEditingController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(
                              color: context.primaryTextColor.withValues(
                                alpha: .25,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Edit indicator
                      Icon(
                        Icons.edit_outlined,
                        color: context.primaryColor.withValues(alpha: .6),
                        size: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Payout Notes
                ...payoutRequestNotes(
                  payoutRequestCurrency,
                  (minimumCoinLimit / perCoin).toString(),
                  minimumCoinLimit.toString(),
                ).map(_buildPayoutRequestNote),
              ],
            ),
          ),

          SizedBox(height: context.height * 0.03),

          /// Redeem Now Btn
          CustomRoundedButton(
            widthPercentage: 1,
            backgroundColor: context.primaryColor,
            buttonTitle: context.tr(redeemNowKey),
            radius: 12,
            showBorder: false,
            height: 56,
            titleColor: context.surfaceColor,
            fontWeight: FontWeight.bold,
            textSize: 18,
            onTap: () {
              unawaited(HapticFeedback.mediumImpact());
              final enteredRedeemAmount =
                  double.tryParse(
                    redeemableAmountTextEditingController!.text.trim(),
                  ) ??
                  0;

              if (enteredRedeemAmount < _minimumRedeemableAmount()) {
                context.showSnack(
                  '${context.tr(minimumRedeemableAmountKey)} $payoutRequestCurrency${_minimumRedeemableAmount()} ',
                );
                return;
              }

              final userCoins = int.parse(
                context.read<UserDetailsCubit>().getCoins()!,
              );

              final maxRedeemableAmount = UiUtils.calculateAmountPerCoins(
                userCoins: userCoins,
                amount: coinAmount,
                coins: perCoin,
              );

              if (enteredRedeemAmount > maxRedeemableAmount) {
                context.showSnack(
                  context.tr(notEnoughCoinsToRedeemAmountKey)!,
                );
                return;
              }

              showRedeemRequestAmountBottomSheet(
                deductedCoins:
                    UiUtils.calculateDeductedCoinsForRedeemableAmount(
                      amount: coinAmount,
                      coins: perCoin,
                      userEnteredAmount: enteredRedeemAmount,
                    ),
                redeemableAmount: enteredRedeemAmount,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContainer({
    required PaymentRequest paymentRequest,
    required int index,
    required int totalTransactions,
    required bool hasMoreTransactionsFetchError,
    required bool hasMore,
  }) {
    if (index == totalTransactions - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreTransactionsFetchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: IconButton(
                onPressed: fetchMoreTransactions,
                icon: Icon(Icons.error, color: context.primaryColor),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: CircularProgressContainer(),
            ),
          );
        }
      }
    }

    final (statusColor, paymentStatus) = switch (paymentRequest.status) {
      '0' => (kPendingColor, pendingKey),
      '1' => (kAddCoinColor, completedKey),
      _ => (kHurryUpTimerColor, wrongDetailsKey),
    };

    final paymentMethod = kPayoutMethods
        .where(
          (e) =>
              e.type.toLowerCase() == paymentRequest.paymentType.toLowerCase(),
        )
        .firstOrNull;

    final paymentLogo = paymentMethod?.image ?? '';

    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Text(
                      context.tr(paymentStatus)!,
                      maxLines: 1,
                      style: context.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime.parse(paymentRequest.date)),
                    style: context.labelMedium?.copyWith(
                      color: context.primaryTextColor.withValues(alpha: .4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paymentRequest.details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleLarge?.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraint.maxWidth * 0.23,
                    child: Text(
                      NumberFormat.compactCurrency(
                        symbol: payoutRequestCurrency,
                      ).format(double.parse(paymentRequest.paymentAmount)),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: context.titleLarge?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (paymentLogo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: QImage(
                        imageUrl: paymentLogo,
                        width: 40,
                        height: 40,
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        "${context.tr("payment")!}: ${paymentRequest.paymentType}",
                        style: context.labelLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                  if (paymentRequest.status == '0')
                    GestureDetector(
                      onTap: () async {
                        await showCancelRequestDialog(
                          paymentId: paymentRequest.id,
                          context: context,
                        ).then((canceled) {
                          if (canceled != null && canceled) {
                            fetchTransactions();

                            final userCoins = int.parse(
                              context.read<UserDetailsCubit>().getCoins()!,
                            );

                            redeemableAmountTextEditingController?.text =
                                UiUtils.calculateAmountPerCoins(
                                  userCoins: userCoins,
                                  amount: coinAmount,
                                  coins: perCoin,
                                ).toString();
                          }
                        });
                      },
                      child: Text(
                        context.tr('cancel')!,
                        style: context.titleMedium?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionListContainer() {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listener: (context, state) async {
        if (state is TransactionsFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            await showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is TransactionsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: fetchTransactions,
              showErrorImage: true,
            ),
          );
        }

        if (state is TransactionsFetchSuccess) {
          final totalReqs = state.paymentRequests.length;

          return SingleChildScrollView(
            controller: _transactionsScrollController,
            padding: EdgeInsets.only(
              bottom: 20,
              top: context.height * 0.02,
              left: context.width * 0.05,
              right: context.width * 0.05,
            ),
            child: Column(
              children: [
                /// Total Earnings
                Container(
                  alignment: Alignment.center,
                  width: context.width,
                  height: context.height * 0.1,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr(totalEarningsKey)!,
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$payoutRequestCurrency ${context.read<TransactionsCubit>().calculateTotalEarnings()}',
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.height * 0.015),

                /// List of Redeem Requests
                for (var i = 0; i < totalReqs; i++) ...[
                  _buildTransactionContainer(
                    paymentRequest: state.paymentRequests[i],
                    index: i,
                    totalTransactions: state.paymentRequests.length,
                    hasMoreTransactionsFetchError: state.hasMoreFetchError,
                    hasMore: state.hasMore,
                  ),
                ],
              ],
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr(walletKey)!),
        bottom: TabBar(
          onTap: (_) => HapticFeedback.lightImpact(),
          tabAlignment: TabAlignment.fill,
          controller: tabController,
          tabs: [
            Tab(text: context.tr(requestKey)),
            Tab(text: context.tr(transactionKey)),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildRequestContainer(),
          _buildTransactionListContainer(),
        ],
      ),
    );
  }
}
