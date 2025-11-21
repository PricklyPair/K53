import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlocked_level_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/quiz/multi_match/screens/multi_match_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/subcategories_levels_chip.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

final class LevelsScreenArgs extends RouteArgs {
  const LevelsScreenArgs({
    required this.quizType,
    required this.category,
    required this.categoryCubit,
  });

  final QuizTypes quizType;
  final Category category;
  final QuizCategoryCubit categoryCubit;
}

/// Category Levels Screen
class LevelsScreen extends StatefulWidget {
  const LevelsScreen({required this.args, super.key});

  final LevelsScreenArgs args;

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<LevelsScreenArgs>();

    return CupertinoPageRoute(builder: (_) => LevelsScreen(args: args));
  }
}

class _LevelsScreenState extends State<LevelsScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  bool _isExpanded = false;
  bool _showAllLevels = false;
  late final int maxLevels;
  late AnimationController expandController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    getUnlockedLevelData();
    prepareAnimations();
    setRotation(45);
    maxLevels = int.parse(widget.args.category.maxLevel!);
    _showAllLevels = maxLevels < 6;
  }

  void setRotation(int degrees) {
    final angle = degrees * math.pi / 90;
    _rotationAnimation = Tween<double>(begin: 0, end: angle).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0, 0.4, curve: Curves.easeInOutCubic),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOutCubic),
      ),
    );
  }

  void getUnlockedLevelData() {
    Future.delayed(
      Duration.zero,
      () => context.read<UnlockedLevelCubit>().fetchUnlockLevel(
        widget.args.category.id!,
        '',
        quizType: widget.args.quizType,
      ),
    );
  }

  Widget _buildLevels() {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// subcategory
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;

                    if (_isExpanded) {
                      expandController.forward();
                    } else {
                      expandController.reverse();
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      /// subcategory Icon
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: CachedNetworkImage(
                          imageUrl: widget.args.category.image!,
                          errorWidget: (_, s, d) => Icon(
                            Icons.subject,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// subcategory details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// subcategory name
                            Text(
                              widget.args.category.categoryName!,
                              style: TextStyle(
                                color: colorScheme.onTertiary,
                                fontSize: 18,
                                fontWeight: FontWeights.semiBold,
                                height: 1.2,
                              ),
                            ),

                            /// subcategory levels, questions details
                            ///
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color: colorScheme.onTertiary.withValues(
                                      alpha: 0.3,
                                    ),
                                    fontWeight: FontWeights.regular,
                                    fontSize: 14,
                                  ),
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.args.category.maxLevel
                                        .toString(),
                                    style: TextStyle(
                                      color: colorScheme.onTertiary,
                                    ),
                                  ),
                                  const TextSpan(text: ' : '),
                                  TextSpan(text: context.tr('levels')),
                                  const WidgetSpan(child: SizedBox(width: 5)),
                                  WidgetSpan(
                                    child: Container(
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      height: 15,
                                      width: 1,
                                    ),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 5)),
                                  TextSpan(
                                    text: widget.args.category.questionsCount
                                        .toString(),
                                    style: TextStyle(
                                      color: colorScheme.onTertiary,
                                    ),
                                  ),
                                  const TextSpan(text: ' : '),
                                  TextSpan(text: context.tr('questions')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// subcategory show levels arrow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          child: Icon(
                            context.isRTL
                                ? Icons.keyboard_arrow_left_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            size: 25,
                            color: colorScheme.onTertiary,
                          ),
                          builder: (_, child) => Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// subcategory expanded levels
              /// _buildLevels
              _buildLevelSection(),
            ],
          ),
        ),
      ),
    );
  }

  late bool locked =
      widget.args.category.isPremium && !widget.args.category.hasUnlocked;
  Widget _buildLevelSection() {
    return BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
      bloc: context.read<UnlockedLevelCubit>(),
      listener: (context, state) {
        if (state is UnlockedLevelFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (_, state) {
        if (state is UnlockedLevelFetchInProgress ||
            state is UnlockedLevelInitial) {
          return const Center(child: CircularProgressContainer());
        }

        if (state is UnlockedLevelFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              topMargin: 0,
              onTapRetry: getUnlockedLevelData,
              showErrorImage: false,
            ),
          );
        }

        if (state is UnlockedLevelFetchSuccess) {
          return SizeTransition(
            axisAlignment: 1,
            sizeFactor: animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                paddedDivider(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_showAllLevels ? maxLevels : 6, (
                      i,
                    ) {
                      return GestureDetector(
                        onTap: () {
                          if (locked) {
                            showUnlockPremiumCategoryDialog(
                              context,
                              categoryId: widget.args.category.id!,
                              categoryName: widget.args.category.categoryName!,
                              requiredCoins: widget.args.category.requiredCoins,
                              categoryCubit: widget.args.categoryCubit,
                            ).then((result) {
                              if (result != null && result) {
                                setState(() {
                                  locked = false;
                                });
                              }
                            });
                            return;
                          }

                          if ((i + 1) <= state.unlockedLevel) {
                            if (widget.args.quizType == QuizTypes.multiMatch) {
                              context.pushNamed(
                                Routes.multiMatchQuiz,
                                arguments: MultiMatchQuizArgs(
                                  categoryId: widget.args.category.id!,
                                  isPremiumCategory:
                                      widget.args.category.isPremium,
                                  level: (i + 1).toString(),
                                  totalLevels: int.parse(
                                    widget.args.category.maxLevel ?? '0',
                                  ),
                                  unlockedLevel: state.unlockedLevel,
                                ),
                              );
                            } else {
                              /// Start level
                              Navigator.of(context).pushNamed(
                                Routes.quiz,
                                arguments: {
                                  'numberOfPlayer': 1,
                                  'quizType': QuizTypes.quizZone,
                                  'categoryId': widget.args.category.id,
                                  'subcategoryId': '',
                                  'level': (i + 1).toString(),
                                  'subcategoryMaxLevel':
                                      widget.args.category.maxLevel,
                                  'unlockedLevel': state.unlockedLevel,
                                  'contestId': '',
                                  'comprehensionId': '',
                                  'isPremiumCategory':
                                      widget.args.category.isPremium,
                                },
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            context.showSnack(
                              context.tr(
                                convertErrorCodeToLanguageKey(
                                  errorCodeLevelLocked,
                                ),
                              )!,
                            );
                          }
                        },
                        child: SubcategoriesLevelChip(
                          isLevelUnlocked: (i + 1) <= state.unlockedLevel,
                          isLevelPlayed: (i + 2) <= state.unlockedLevel,
                          currIndex: i,
                        ),
                      );
                    }),
                  ),
                ),
                paddedDivider(),

                /// View More/Less
                if (maxLevels > 6) ...[
                  GestureDetector(
                    onTap: () => setState(() {
                      _showAllLevels = !_showAllLevels;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      child: Text(
                        context.tr(!_showAllLevels ? 'viewMore' : 'showLess')!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return Text(context.tr('noLevelsLbl')!);
      },
    );
  }

  Padding paddedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Divider(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerAdLoaded =
        context.watch<BannerAdCubit>().bannerAdLoaded &&
        !context.read<UserDetailsCubit>().removeAds();

    return Scaffold(
      appBar: const QAppBar(title: SizedBox.shrink(), roundedAppBar: false),
      body: Stack(
        children: [
          ///
          Padding(
            padding: EdgeInsets.only(bottom: bannerAdLoaded ? 60 : 0),
            child: SingleChildScrollView(child: _buildLevels()),
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
