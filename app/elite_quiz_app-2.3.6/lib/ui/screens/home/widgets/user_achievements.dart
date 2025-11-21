import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class UserAchievements extends StatelessWidget {
  const UserAchievements({
    super.key,
    this.userRank = '0',
    this.userCoins = '0',
    this.userScore = '0',
  });

  final String userRank;
  final String userCoins;
  final String userScore;

  @override
  Widget build(BuildContext context) {
    final rank = context.tr('rankLbl')!;
    final coins = context.tr('coinsLbl')!;
    final score = context.tr('scoreLbl')!;

    final numberFormat = NumberFormat.decimalPattern();

    final verticalDivider = Container(
      height: 48,
      width: 2,
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(2),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 5,
            color: context.primaryColor.withValues(alpha: .3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(99999),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Achievement(
              title: rank,
              value: numberFormat.format(double.parse(userRank)),
            ),
            verticalDivider,
            _Achievement(
              title: coins,
              value: numberFormat.format(double.parse(userCoins)),
            ),
            verticalDivider,
            _Achievement(
              title: score,
              value: numberFormat.format(double.parse(userScore)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeights.regular,
            color: context.surfaceColor.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeights.bold,
            height: 1.136,
            color: context.surfaceColor,
          ),
        ),
      ],
    );
  }
}
