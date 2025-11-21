import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/ads.dart';
import 'package:flutterquiz/features/coin_history/blocs/coin_history_cubit.dart';
import 'package:flutterquiz/features/coin_history/models/coin_history.dart';
import 'package:flutterquiz/features/coin_history/repos/coin_history_repository.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<CoinHistoryCubit>(
        create: (_) => CoinHistoryCubit(CoinHistoryRepository()),
        child: const CoinHistoryScreen(),
      ),
    );
  }
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  late final ScrollController _scrollController;
  late final CoinHistoryCubit _coinHistoryCubit;
  late final UserDetailsCubit _userDetailsCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _coinHistoryCubit = context.read<CoinHistoryCubit>();
    _userDetailsCubit = context.read<UserDetailsCubit>();
    _fetchInitialHistory();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _fetchInitialHistory() {
    unawaited(_coinHistoryCubit.fetchInitialHistory());
  }

  void _onScroll() {
    if (!_isScrolledToBottom) return;

    if (_coinHistoryCubit.hasMoreHistory) {
      unawaited(
        _coinHistoryCubit.fetchMoreHistory(userId: _userDetailsCubit.userId()),
      );
    }
  }

  bool get _isScrolledToBottom =>
      _scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent;

  Widget _buildListItem({
    required CoinHistory transaction,
    required int index,
    required int totalItems,
    required bool hasMoreError,
    required bool hasMore,
  }) {
    final isLastItem = index == totalItems - 1;

    if (isLastItem && hasMore) {
      return _buildLoadMoreIndicator(hasError: hasMoreError);
    }

    return _CoinHistoryItem(transaction: transaction);
  }

  Widget _buildLoadMoreIndicator({required bool hasError}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: hasError
            ? IconButton(
                onPressed: () => unawaited(
                  _coinHistoryCubit.fetchMoreHistory(
                    userId: _userDetailsCubit.userId(),
                  ),
                ),
                icon: Icon(Icons.error, color: context.primaryColor),
              )
            : const CircularProgressContainer(),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<CoinHistoryCubit, CoinHistoryState>(
      bloc: _coinHistoryCubit,
      listenWhen: (previous, current) =>
          current is CoinHistoryFetchFailure &&
          current.errorMessage == errorCodeUnauthorizedAccess,
      listener: _handleStateChanges,
      buildWhen: (previous, current) =>
          // Only rebuild when state type changes, not on pagination updates
          previous.runtimeType != current.runtimeType ||
          (current is CoinHistoryFetchSuccess &&
              previous is CoinHistoryFetchSuccess &&
              (current.coinHistory.length != previous.coinHistory.length ||
                  current.hasMoreFetchError != previous.hasMoreFetchError)),
      builder: (context, state) {
        return switch (state) {
          CoinHistoryFetchFailure() => _buildErrorState(state),
          CoinHistoryFetchSuccess() => _buildHistoryList(state),
          _ => const Center(child: CircularProgressContainer()),
        };
      },
    );
  }

  void _handleStateChanges(BuildContext context, CoinHistoryState state) {
    if (state is CoinHistoryFetchFailure &&
        state.errorMessage == errorCodeUnauthorizedAccess) {
      unawaited(showAlreadyLoggedInDialog(context));
    }
  }

  Widget _buildErrorState(CoinHistoryFetchFailure state) {
    return Center(
      child: ErrorContainer(
        errorMessageColor: context.primaryColor,
        errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
        onTapRetry: _fetchInitialHistory,
        showErrorImage: true,
      ),
    );
  }

  Widget _buildHistoryList(CoinHistoryFetchSuccess state) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        vertical: context.height * UiUtils.vtMarginPct,
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      itemCount: state.coinHistory.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildListItem(
        transaction: state.coinHistory[index],
        index: index,
        totalItems: state.coinHistory.length,
        hasMoreError: state.hasMoreFetchError,
        hasMore: state.hasMore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBannerAd = context.watch<BannerAdCubit>().bannerAdLoaded &&
        !_userDetailsCubit.removeAds();

    return Scaffold(
      appBar: QAppBar(title: Text(context.tr(coinHistoryKey)!)),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: showBannerAd ? 60 : 0),
            child: _buildContent(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}

/// Individual coin history transaction item widget
class _CoinHistoryItem extends StatelessWidget {
  const _CoinHistoryItem({required this.transaction});

  final CoinHistory transaction;

  static const double _borderRadius = 12;
  static const double _shadowBlurRadius = 8;
  static const double _shadowAlpha = 0.08;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(transaction.date),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: _shadowAlpha),
            blurRadius: _shadowBlurRadius,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TransactionDetails(
              type: context.tr(transaction.type) ?? transaction.type,
              date: formattedDate,
            ),
          ),
          const SizedBox(width: 12),
          _CoinBadge(
            points: transaction.pointsValue,
            isDeduction: transaction.isDeduction,
          ),
        ],
      ),
    );
  }
}

/// Transaction type and date display
class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({
    required this.type,
    required this.date,
  });

  final String type;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 12,
              color: context.primaryTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              date,
              style: TextStyle(
                color: context.primaryTextColor.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Coin points badge with gradient and shadow
class _CoinBadge extends StatelessWidget {
  const _CoinBadge({
    required this.points,
    required this.isDeduction,
  });

  final int points;
  final bool isDeduction;

  static const double _borderRadius = 8;
  static const double _shadowBlurRadius = 8;
  static const double _gradientAlpha = 0.9;
  static const double _glowAlpha = 0.2;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isDeduction ? kHurryUpTimerColor : kAddCoinColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: _gradientAlpha),
            badgeColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: _glowAlpha),
            blurRadius: _shadowBlurRadius,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isDeduction
            ? UiUtils.formatNumber(points)
            : '+${UiUtils.formatNumber(points)}',
        style: TextStyle(
          color: context.surfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
