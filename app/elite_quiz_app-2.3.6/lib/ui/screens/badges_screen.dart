import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/features/statistic/cubits/statistics_cubit.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/badges_icon_container.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  static Route<BadgesScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const BadgesScreen());
  }

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    //Initial fetch and updates
    Future.delayed(Duration.zero, () {
      context.read<BadgesCubit>().getBadges();
      UiUtils.updateBadgesLocally(context);
      context.read<StatisticCubit>().getStatistic();
      context.read<InterstitialAdCubit>().showAd(context);
    });
  }

  void showBadgeDetails(BuildContext context, Badges badge) {
    showModalBottomSheet<void>(
      backgroundColor: context.scaffoldBackgroundColor,
      elevation: 5,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (_) => _BadgeDetailsSheet(badge: badge),
    );
  }

  List<Badges> _organizedBadges(List<Badges> badges) {
    final lockedBadges = badges
        .where((b) => b.status == BadgesStatus.locked)
        .toList();
    final unlockedBadges = badges
        .where((b) => b.status != BadgesStatus.locked)
        .toList();
    return [...unlockedBadges, ...lockedBadges];
  }

  Widget _buildBadges() {
    return BlocConsumer<BadgesCubit, BadgesState>(
      listener: (context, state) {
        if (state is BadgesFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is BadgesFetchInProgress || state is BadgesInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is BadgesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!,
              onTapRetry: context.read<BadgesCubit>().getBadges,
              showErrorImage: true,
            ),
          );
        }

        final badges = _organizedBadges((state as BadgesFetchSuccess).badges);
        return RefreshIndicator(
          color: context.primaryColor,
          onRefresh: () async => context.read<BadgesCubit>().getBadges(),
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return _AnimatedBadgeCard(
                index: index,
                badge: badges[index],
                onTap: () {
                  if (context.read<SettingsCubit>().getSettings().vibration) {
                    HapticFeedback.lightImpact();
                  }
                  showBadgeDetails(context, badges[index]);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(context.tr(badgesKey)!)),
      body: _buildBadges(),
    );
  }
}

class _AnimatedBadgeCard extends StatefulWidget {
  const _AnimatedBadgeCard({
    required this.index,
    required this.badge,
    required this.onTap,
  });

  final int index;
  final Badges badge;
  final VoidCallback onTap;

  @override
  State<_AnimatedBadgeCard> createState() => _AnimatedBadgeCardState();
}

class _AnimatedBadgeCardState extends State<_AnimatedBadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Stagger the animation based on grid index
    Future.delayed(Duration(milliseconds: widget.index * 75), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final isUnlocked = badge.status != BadgesStatus.locked;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.maxFinite,
                      height: constraints.maxHeight * 0.75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          colors: [
                            if (isUnlocked)
                              context.primaryColor.withValues(alpha: 0.01)
                            else
                              Colors.grey.withValues(alpha: 0.1),
                            context.surfaceColor.withValues(alpha: 1),
                          ],
                          focal: Alignment.topCenter,
                          focalRadius: -2,
                          radius: 0.6,
                          center: Alignment.topCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUnlocked
                                ? context.primaryColor.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: .1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              context.tr('${badge.type}_label') ?? badge.type,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isUnlocked
                                    ? context.primaryTextColor
                                    : kBadgeLockedColor,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.1),
                        ],
                      ),
                    ),
                  ),
                  // The icon container, which visually sits on top
                  BadgesIconContainer(
                    badge: badge,
                    constraints: constraints,
                    addTopPadding: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BadgeDetailsSheet extends StatefulWidget {
  const _BadgeDetailsSheet({required this.badge});

  final Badges badge;

  @override
  State<_BadgeDetailsSheet> createState() => _BadgeDetailsSheetState();
}

class _BadgeDetailsSheetState extends State<_BadgeDetailsSheet>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shineController;
  late Animation<double> _entranceScaleAnimation;

  Timer? _shineTimer;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _entranceScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0,
              end: 1.2,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 65,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.2,
              end: 1,
            ).chain(CurveTween(curve: Curves.easeIn)),
            weight: 35,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _entranceController,
            // The scale animation will occur in the first part of the entrance
            curve: const Interval(0, .8),
          ),
        );

    _entranceController.forward();

    // If the badge is unlocked, start a periodic timer to trigger the shine
    if (widget.badge.status != BadgesStatus.locked) {
      _shineTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          _shineController.forward(from: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shineController.dispose();
    _shineTimer?.cancel();
    super.dispose();
  }

  // Helper for the staggered entrance animation of text elements
  Widget _buildAnimatedItem(Widget child, {required double intervalStart}) {
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        intervalStart,
        (intervalStart + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regularTextStyle = TextStyle(
      fontWeight: FontWeights.regular,
      color: context.primaryTextColor.withValues(alpha: 0.8),
      fontSize: 16,
      height: 1.4,
    );
    final isUnlocked = widget.badge.status != BadgesStatus.locked;

    final badgeIcon = SizedBox(
      height: context.height * .2,
      width: context.width * .3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return BadgesIconContainer(
            badge: widget.badge,
            constraints: constraints,
            addTopPadding: false,
            showShadow: true,
          );
        },
      ),
    );

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _entranceScaleAnimation,
            child: AnimatedBuilder(
              animation: _shineController,
              builder: (context, child) {
                final gradient = LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: const [
                    Colors.white10,
                    Colors.white70,
                    Colors.white10,
                  ],
                  stops: const [0.4, 0.5, 0.6],
                  transform: GradientSlide(_shineController.value),
                );

                return isUnlocked
                    ? ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: gradient.createShader,
                        child: child,
                      )
                    : child!;
              },
              child: badgeIcon,
            ),
          ),
          const SizedBox(height: 20),

          // Staggered text animations
          _buildAnimatedItem(
            Text(
              context.tr('${widget.badge.type}_label') ?? widget.badge.type,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked
                    ? context.primaryTextColor
                    : kBadgeLockedColor,
                fontWeight: FontWeights.bold,
                fontSize: 22,
              ),
            ),
            intervalStart: 0.2,
          ),
          const SizedBox(height: 10),
          _buildAnimatedItem(
            Text(
              context.tr('${widget.badge.type}_note') ?? widget.badge.type,
              textAlign: TextAlign.center,
              style: regularTextStyle,
            ),
            intervalStart: 0.3,
          ),
          const SizedBox(height: 20),

          if (!isUnlocked) ...[
            if (widget.badge.type == 'big_thing') ...[
              _buildAnimatedItem(
                BlocBuilder<StatisticCubit, StatisticState>(
                  builder: (context, state) {
                    if (state is StatisticFetchSuccess) {
                      final correctAnswers = int.parse(
                        state.statisticModel.correctAnswers,
                      );
                      final requiredAnswers = int.parse(
                        widget.badge.badgeCounter,
                      );
                      final answerToGo = requiredAnswers - correctAnswers;

                      return Text(
                        '${context.tr(needMoreKey)} $answerToGo ${context.tr(correctAnswerToUnlockKey)}',
                        textAlign: TextAlign.center,
                        style: regularTextStyle,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                intervalStart: 0.4,
              ),
              const SizedBox(height: 4),
            ],
            _buildAnimatedItem(
              Text.rich(
                TextSpan(
                  style: regularTextStyle,
                  children: [
                    TextSpan(text: context.tr('unlockToEarn')),
                    TextSpan(
                      text:
                          ' ${widget.badge.badgeReward} ${context.tr('coinsExclaim')}',
                      style: regularTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              intervalStart: 0.5,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

// A custom GradientTransform to slide the gradient during the animation
class GradientSlide extends GradientTransform {
  const GradientSlide(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (progress * 2 - 1.1), // Move from left to right
      0,
      0,
    );
  }
}
