import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/ui/screens/rewards/scratch_reward_screen.dart';
import 'package:flutterquiz/ui/screens/rewards/widgets/unlocked_reward_content.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<UpdateCoinsCubit>(
        child: const RewardsScreen(),
        create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
      ),
    );
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceAnimationController;

  @override
  void initState() {
    super.initState();

    _entranceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entranceAnimationController.dispose();
    super.dispose();
  }

  Widget _buildRewardContainer(Badges reward) {
    return GestureDetector(
      onTap: () {
        if (reward.status == BadgesStatus.unlocked) {
          Navigator.of(context).push(
            PageRouteBuilder<dynamic>(
              transitionDuration: const Duration(milliseconds: 400),
              opaque: false,
              pageBuilder: (context, firstAnimation, secondAnimation) {
                return FadeTransition(
                  opacity: firstAnimation,
                  child: BlocProvider<UpdateCoinsCubit>(
                    create: (context) =>
                        UpdateCoinsCubit(ProfileManagementRepository()),
                    child: ScratchRewardScreen(reward: reward),
                  ),
                );
              },
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: reward.status == BadgesStatus.rewardUnlocked
              ? context.colorScheme.surface
              : context.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: reward.status == BadgesStatus.rewardUnlocked
            ? UnlockedRewardContent(reward: reward, increaseFont: false)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(Assets.scratchCardCover, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildRewards() {
    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        if (state is BadgesFetchFailure) {
          return SliverToBoxAdapter(
            child: Center(
              child: ErrorContainer(
                errorMessage: convertErrorCodeToLanguageKey(
                  state.errorMessage,
                ),
                onTapRetry: () {
                  context.read<BadgesCubit>().getBadges();
                },
                showErrorImage: true,
              ),
            ),
          );
        }

        if (state is BadgesFetchSuccess) {
          final rewards = context.read<BadgesCubit>().getRewards();

          /// If there are no rewards
          if (rewards.isEmpty) {
            return Center(child: Text(context.tr(noRewardsKey)!));
          }

          //create grid count
          return GridView.builder(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: context.height * UiUtils.vtMarginPct,
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemCount: rewards.length,
            itemBuilder: (_, i) {
              final reward = rewards[i];

              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, .2),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceAnimationController,
                        curve: Interval(
                          .1 * i,
                          1,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                child: Hero(
                  tag: reward.type,
                  child: _buildRewardContainer(reward),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        shadowColor: context.surfaceColor.withValues(alpha: 0.4),
        backgroundColor: context.primaryColor,
        foregroundColor: context.surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        leading: QBackButton(
          removeSnackBars: false,
          color: context.surfaceColor,
        ),
        title: Text(
          context.tr(rewardsLbl)!,
          style: context.titleLarge?.copyWith(
            fontWeight: FontWeights.bold,
            color: context.colorScheme.onPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: BlocBuilder<BadgesCubit, BadgesState>(
              bloc: context.read<BadgesCubit>(),
              builder: (context, state) {
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${context.read<BadgesCubit>().getRewardedCoins()} ${context.tr(coinsLbl)!}',
                        style: context.headlineLarge?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '\n${context.tr(totalRewardsEarnedKey)!}',
                        style: context.bodyLarge?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: _buildRewards(),
    );
  }
}
