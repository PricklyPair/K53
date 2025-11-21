import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/ui/screens/rewards/widgets/unlocked_reward_content.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:scratcher/widgets.dart';

class ScratchRewardScreen extends StatefulWidget {
  const ScratchRewardScreen({required this.reward, super.key});

  final Badges reward;

  @override
  State<ScratchRewardScreen> createState() => _ScratchRewardScreenState();
}

class _ScratchRewardScreenState extends State<ScratchRewardScreen> {
  GlobalKey<ScratcherState> scratcherKey = GlobalKey<ScratcherState>();
  bool _showScratchHere = true;

  bool _goBack() {
    final currentState = scratcherKey.currentState;
    final isFinished = currentState?.isFinished ?? false;

    if (currentState?.progress != 0.0 && !isFinished) {
      currentState?.reveal(duration: const Duration(milliseconds: 250));

      return false;
    }

    return true;
  }

  void unlockReward() {
    if (context.read<BadgesCubit>().isRewardUnlocked(widget.reward.type)) {
      return;
    }

    context.read<BadgesCubit>().unlockReward(widget.reward.type);

    context.read<UpdateCoinsCubit>().updateCoins(
      coins: int.parse(widget.reward.badgeReward),
      addCoin: true,
      title: rewardByScratchingCardKey,
      type: widget.reward.type,
    );
    context.read<UserDetailsCubit>().updateCoins(
      addCoin: true,
      coins: int.parse(widget.reward.badgeReward),
    );
  }

  void _onThreshold() =>
      scratcherKey.currentState?.reveal(duration: Duration.zero);

  void _onChange(double value) {
    if (value > 0.0 && _showScratchHere) {
      setState(() => _showScratchHere = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.45),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;

            if (_goBack()) {
              unlockReward();

              Navigator.of(context).pop();
            }
          },
          child: IconButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (_goBack()) {
                unlockReward();
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
      ),
      body: Stack(
        children: [
          Align(
            child: Hero(
              tag: widget.reward.type,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  height: context.height * 0.4,
                  width: context.width * 0.8,
                  child: Scratcher(
                    onChange: _onChange,
                    onThreshold: _onThreshold,
                    key: scratcherKey,
                    brushSize: 35,
                    threshold: 50,
                    accuracy: ScratchAccuracy.medium,
                    color: Theme.of(context).primaryColor,
                    image: Image.asset(Assets.scratchCardCover),
                    child: UnlockedRewardContent(
                      reward: widget.reward,
                      increaseFont: true,
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///
          if (_showScratchHere)
            Align(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                  ),
                  height: context.height * 0.075,
                  width: context.width * 0.8,
                  child: Center(
                    child: Text(
                      context.tr(scratchHereKey)!,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
