import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

final class SubCategoryScreenArgs extends RouteArgs {
  const SubCategoryScreenArgs({
    required this.quizType,
    required this.category,
    required this.categoryCubit,
  });

  final QuizTypes quizType;
  final Category category;
  final QuizCategoryCubit categoryCubit;
}

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({required this.args, super.key});

  final SubCategoryScreenArgs args;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<SubCategoryScreenArgs>();

    return CupertinoPageRoute(builder: (_) => SubCategoryScreen(args: args));
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late final Category _category = widget.args.category;

  void getSubCategory() {
    Future.delayed(Duration.zero, () {
      context.read<SubCategoryCubit>().fetchSubCategory(_category.id!);
    });
  }

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  late bool locked = _category.isPremium && !_category.hasUnlocked;

  void handleListTileTap(Subcategory subCategory) {
    if (locked) {
      showUnlockPremiumCategoryDialog(
        context,
        categoryId: _category.id!,
        categoryName: _category.categoryName!,
        requiredCoins: _category.requiredCoins,
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

    if (widget.args.quizType == QuizTypes.guessTheWord) {
      context.pushNamed(
        Routes.guessTheWord,
        arguments: GuessTheWordQuizScreenArgs(
          categoryId: _category.id!,
          subcategoryId: subCategory.id,
          isPlayed: subCategory.isPlayed,
          isPremiumCategory: _category.isPremium,
        ),
      );
    } else if (widget.args.quizType == QuizTypes.funAndLearn) {
      Navigator.of(context).pushNamed(
        Routes.funAndLearnTitle,
        arguments: {
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'title': subCategory.subcategoryName,
          'isPremiumCategory': _category.isPremium,
        },
      );
    } else if (widget.args.quizType == QuizTypes.audioQuestions) {
      Navigator.of(context).pushNamed(
        Routes.quiz,
        arguments: {
          'quizType': QuizTypes.audioQuestions,
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'isPlayed': subCategory.isPlayed,
          'isPremiumCategory': _category.isPremium,
        },
      );
    } else if (widget.args.quizType == QuizTypes.mathMania) {
      Navigator.of(context).pushNamed(
        Routes.quiz,
        arguments: {
          'quizType': QuizTypes.mathMania,
          'categoryId': _category.id,
          'subcategoryId': subCategory.id,
          'isPlayed': subCategory.isPlayed,
          'isPremiumCategory': _category.isPremium,
        },
      );
    }
  }

  Widget _buildSubCategory() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
      bloc: context.read<SubCategoryCubit>(),
      listener: (context, state) {
        if (state is SubCategoryFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is SubCategoryFetchInProgress ||
            state is SubCategoryInitial) {
          return const Center(child: CircularProgressContainer());
        }

        if (state is SubCategoryFetchFailure) {
          return Center(
            child: ErrorContainer(
              showBackButton: false,
              showErrorImage: true,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: getSubCategory,
            ),
          );
        }

        final subcategories =
            (state as SubCategoryFetchSuccess).subcategoryList;
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: context.height * UiUtils.vtMarginPct,
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          itemCount: subcategories.length,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, i) =>
              const SizedBox(height: UiUtils.listTileGap),
          itemBuilder: (BuildContext context, int index) {
            final subcategory = subcategories[index];

            return GestureDetector(
              onTap: () => handleListTileTap(subcategory),
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
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
                              bottom: Radius.circular(
                                boxConstraints.maxWidth * .525,
                              ),
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
                              Container(
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
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    memCacheWidth: 50,
                                    memCacheHeight: 50,
                                    placeholder: (_, _) => const SizedBox(),
                                    imageUrl: subcategory.image!,
                                    errorWidget: (_, i, e) => const Image(
                                      image: AssetImage(Assets.placeholder),
                                    ),
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
                                      subcategory.subcategoryName!,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: context.primaryTextColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "${context.tr(widget.args.quizType == QuizTypes.funAndLearn ? "comprehensiveLbl" : "questions")!}: ${subcategory.noOfQue!}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.primaryTextColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              /// right arrow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  context.isRTL
                                      ? Icons.keyboard_arrow_left_rounded
                                      : Icons.keyboard_arrow_right_rounded,
                                  size: 30,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiary,
                                ),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerAdLoaded =
        context.watch<BannerAdCubit>().bannerAdLoaded &&
        !context.read<UserDetailsCubit>().removeAds();

    return Scaffold(
      appBar: QAppBar(
        title: Text(_category.categoryName!),
        roundedAppBar: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bannerAdLoaded ? 60 : 0),
            child: _buildSubCategory(),
          ),

          /// Banner Ad
          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}
