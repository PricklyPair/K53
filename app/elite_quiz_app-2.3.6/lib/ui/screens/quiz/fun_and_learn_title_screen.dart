import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/ads/widgets/banner_ad_container.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehension_cubit.dart';
import 'package:flutterquiz/ui/screens/quiz/fun_and_learn_screen.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class FunAndLearnTitleScreen extends StatefulWidget {
  const FunAndLearnTitleScreen({
    required this.categoryId,
    required this.title,
    required this.isPremiumCategory,
    this.subcategoryId,
    super.key,
  });

  final String categoryId;
  final String? subcategoryId;
  final String title;
  final bool isPremiumCategory;

  @override
  State<FunAndLearnTitleScreen> createState() => _FunAndLearnTitleScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) => FunAndLearnTitleScreen(
        categoryId: arguments['categoryId'] as String,
        subcategoryId: arguments['subcategoryId'] as String?,
        title: arguments['title'] as String? ?? '',
        isPremiumCategory: arguments['isPremiumCategory'] as bool? ?? false,
      ),
    );
  }
}

class _FunAndLearnTitleScreen extends State<FunAndLearnTitleScreen> {
  @override
  void initState() {
    super.initState();
    getComprehension();
  }

  void getComprehension() {
    Future.delayed(Duration.zero, () {
      unawaited(
        context.read<ComprehensionCubit>().getComprehension(
          languageId: UiUtils.getCurrentQuizLanguageId(context),
          type: widget.subcategoryId != null ? 'subcategory' : 'category',
          typeId: widget.subcategoryId ?? widget.categoryId,
        ),
      );
    });
  }

  Widget _buildComprehensionList() {
    return BlocConsumer<ComprehensionCubit, ComprehensionState>(
      bloc: context.read<ComprehensionCubit>(),
      listener: (context, state) {
        if (state is ComprehensionFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            unawaited(showAlreadyLoggedInDialog(context));
          }
        }
      },
      builder: (context, state) {
        if (state is ComprehensionProgress || state is ComprehensionInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is ComprehensionFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: getComprehension,
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
          );
        }

        final comprehensions = (state as ComprehensionSuccess).getComprehension;

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: context.height * UiUtils.vtMarginPct,
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          itemCount: comprehensions.length,
          separatorBuilder: (_, i) =>
              const SizedBox(height: UiUtils.listTileGap),
          itemBuilder: (_, index) {
            return GestureDetector(
              onTap: () async {
                await context.pushNamed(
                  Routes.funAndLearn,
                  arguments: FunAndLearnScreenArgs(
                    categoryId: widget.categoryId,
                    subcategoryId: widget.subcategoryId,
                    isPremiumCategory: widget.isPremiumCategory,
                    comprehension: comprehensions[index],
                  ),
                );
              },
              child: LayoutBuilder(
                builder: (_, boxConstraints) {
                  final colorScheme = Theme.of(context).colorScheme;

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
                          height: 45,
                        ),
                      ),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(12),
                          width: boxConstraints.maxWidth,
                          child: Row(
                            children: [
                              /// title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comprehensions[index].title,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: colorScheme.onTertiary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${context.tr('questionLbl')}: ${comprehensions[index].noOfQue}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onTertiary
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
                                    color: colorScheme.onTertiary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  context.isRTL
                                      ? Icons.keyboard_arrow_left_rounded
                                      : Icons.keyboard_arrow_right_rounded,
                                  size: 30,
                                  color: colorScheme.onTertiary,
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
      appBar: QAppBar(roundedAppBar: false, title: Text(widget.title)),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bannerAdLoaded ? 60 : 0),
            child: _buildComprehensionList(),
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
