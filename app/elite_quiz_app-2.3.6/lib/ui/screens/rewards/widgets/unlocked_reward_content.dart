import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/badges/badge.dart';

class UnlockedRewardContent extends StatelessWidget {
  const UnlockedRewardContent({
    required this.reward,
    required this.increaseFont,
    super.key,
  });

  final Badges reward;
  final bool increaseFont;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 14, start: 14),
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${reward.badgeReward} ${context.tr(coinsLbl)!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: increaseFont ? 20 : 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 14),
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${context.tr(byUnlockingKey)!} ${context.tr('${reward.type}_label')}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onTertiary.withValues(alpha: 0.9),
                      fontSize: increaseFont ? 16 : 14,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              /// Reward Confetti
              Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset(
                  Assets.rewardConfetti,
                  width: constraints.maxWidth,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
