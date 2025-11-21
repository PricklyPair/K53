import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/subcategory_and_level_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/premium_category_access_badge.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class QuizZoneTabScreen extends StatefulWidget {
  const QuizZoneTabScreen({super.key});

  @override
  State<QuizZoneTabScreen> createState() => QuizZoneTabScreenState();
}

class QuizZoneTabScreenState extends State<QuizZoneTabScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      refreshKey.currentState?.show();
    }
  }

  Future<void> _fetchCategories() async {
    /// Fetch the quiz zone categories, if logged in, fetch categories with user data, otherwise without it.
    if (context.read<AuthCubit>().isGuest) {
      await context.read<QuizCategoryCubit>().getQuizCategory(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: QuizTypes.quizZone.typeValue!,
      );
    } else {
      await context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
        languageId: UiUtils.getCurrentQuizLanguageId(context),
        type: QuizTypes.quizZone.typeValue!,
      );
    }
  }

  void _onTapCategory(BuildContext context, Category category) {
    // Check if the user is a guest, Show login required dialog for guest users
    if (context.read<AuthCubit>().isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    // Check if the category is premium and locked, prompt user to unlock it
    if (category.isPremium &&
        !category.hasUnlocked &&
        !category.hasSubcategories &&
        !category.hasLevels) {
      showUnlockPremiumCategoryDialog(
        context,
        categoryId: category.id!,
        categoryName: category.categoryName!,
        requiredCoins: category.requiredCoins,
        categoryCubit: context.read<QuizCategoryCubit>(),
      );
      return;
    }

    // check if Category has subcategories
    if (category.hasSubcategories) {
      // redirect to Subcategories list screen
      globalCtx.pushNamed(
        Routes.subcategoryAndLevel,
        arguments: SubCategoryAndLevelScreenArgs(
          quizType: QuizTypes.quizZone,
          category: category,
          categoryCubit: context.read<QuizCategoryCubit>(),
        ),
      );
    } else {
      // otherwise check if Category has levels
      if (category.hasLevels) {
        // redirect to Levels screen
        globalCtx.pushNamed(
          Routes.levels,
          arguments: LevelsScreenArgs(
            quizType: QuizTypes.quizZone,
            category: category,
            categoryCubit: context.read<QuizCategoryCubit>(),
          ),
        );
      } else {
        // Start the Quiz
        Navigator.of(globalCtx).pushNamed(
          Routes.quiz,
          arguments: {
            'numberOfPlayer': 1,
            'quizType': QuizTypes.quizZone,
            'categoryId': category.id,
            'subcategoryId': '',
            'level': '0',
            'subcategoryMaxLevel': category.maxLevel,
            'unlockedLevel': 0,
            'contestId': '',
            'comprehensionId': '',
            'showRetryButton': category.hasQuestions,
            'isPremiumCategory': category.isPremium,
            'isPlayed': category.isPlayed,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<QuizLanguageCubit, QuizLanguageState>(
      listenWhen: (prev, curr) => prev.languageId != curr.languageId,
      listener: (_, _) => _fetchCategories(),
      child: Scaffold(
        appBar: QAppBar(
          title: Text(context.tr('quizZone')!),
          automaticallyImplyLeading: false,
        ),
        body: _buildCategoriesListView(),
      ),
    );
  }

  Widget _buildCategoriesListView() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
      builder: (context, state) {
        if (state is QuizCategoryFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessageColor: context.primaryColor,
            showErrorImage: true,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: _fetchCategories,
          );
        }

        if (state is QuizCategorySuccess) {
          return RefreshIndicator(
            key: refreshKey,
            color: context.primaryColor,
            backgroundColor: context.scaffoldBackgroundColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1), () async {
                await _fetchCategories();
              });
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (_, i) =>
                  _buildCategoryItem(context, state.categories[i]),
              separatorBuilder: (_, i) =>
                  const SizedBox(height: UiUtils.listTileGap),
              itemCount: state.categories.length,
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
      listener: (context, state) {
        if (state is QuizCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => _onTapCategory(context, category),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          final imageUrl = category.image ?? '';

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: boxConstraints.maxWidth * 0.1,
                right: boxConstraints.maxWidth * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 25),
                        blurRadius: 5,
                        spreadRadius: 2,
                        color: Color(0x40808080),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(boxConstraints.maxWidth * .525),
                    ),
                  ),
                  width: boxConstraints.maxWidth,
                  height: 50,
                ),
              ),
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                  width: boxConstraints.maxWidth,
                  child: Row(
                    children: [
                      /// Leading Image
                      Align(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: context.primaryTextColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1),
                            child: QImage(imageUrl: imageUrl, fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.categoryName!,
                              maxLines: 1,
                              style: TextStyle(
                                color: context.primaryTextColor,
                                fontSize: 18,
                                fontWeight: FontWeights.semiBold,
                              ),
                            ),
                            Text(
                              category.hasSubcategories
                                  ? "${context.tr("subCategoriesLbl")!}: ${category.subcategoriesCount}"
                                  : "${context.tr("questions")!}: ${category.questionsCount}",
                              style: TextStyle(
                                fontSize: 14,
                                color: context.primaryTextColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// right arrow
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PremiumCategoryAccessBadge(
                            hasUnlocked: category.hasUnlocked,
                            isPremium: category.isPremium,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: context.primaryTextColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: context.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
