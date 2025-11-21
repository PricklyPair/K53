import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/bookmark/bookmark_repository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/update_bookmark_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const BookmarkScreen());
  }
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late List<(String, Widget)> tabs = <(String, Widget)>[
    (quizZone, _buildQuizZoneQuestions()),
    (guessTheWord, _buildGuessTheWordQuestions()),
    (audioQuestionsKey, _buildAudioQuestions()),
  ];

  late final bool isLatexModeEnabled = context
      .read<SystemConfigCubit>()
      .isLatexEnabled(QuizTypes.quizZone);

  @override
  void initState() {
    super.initState();

    // Remove disabled quizzes
    final sysConfig = context.read<SystemConfigCubit>();
    if (!sysConfig.isQuizZoneEnabled) {
      tabs.removeWhere((t) => t.$1 == quizZone);
    }
    if (!sysConfig.isGuessTheWordEnabled) {
      tabs.removeWhere((t) => t.$1 == guessTheWord);
    }
    if (!sysConfig.isAudioQuizEnabled) {
      tabs.removeWhere((t) => t.$1 == audioQuestionsKey);
    }

    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void openBottomSheet({
    required String question,
    required String? imageUrl,
    bool isLatex = false,
  }) {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          height: context.height * .7,
          margin: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),

              /// Title
              Text(
                context.tr(tabs[tabController.index].$1)!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const Divider(),

              if (isLatex) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: TeXView(
                      child: TeXViewColumn(
                        children: [
                          TeXViewDocument(
                            question,
                            style: TeXViewStyle(
                              fontStyle: TeXViewFontStyle(
                                sizeUnit: TeXViewSizeUnit.pixels,
                                fontSize: 18,
                                fontWeight: TeXViewFontWeight.bold,
                              ),
                              margin: const TeXViewMargin.only(
                                bottom: 30,
                                sizeUnit: TeXViewSizeUnit.pixels,
                              ),
                            ),
                          ),
                          if (imageUrl != null && imageUrl != '') ...[
                            TeXViewContainer(
                              child: TeXViewImage.network(imageUrl),
                              style: const TeXViewStyle(
                                margin: TeXViewMargin.only(
                                  bottom: 15,
                                  sizeUnit: TeXViewSizeUnit.pixels,
                                ),
                                borderRadius: TeXViewBorderRadius.all(
                                  10,
                                  sizeUnit: TeXViewSizeUnit.pixels,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      style: TeXViewStyle(
                        margin: const TeXViewMargin.all(
                          20,
                          sizeUnit: TeXViewSizeUnit.pixels,
                        ),
                        contentColor: Theme.of(context).colorScheme.onTertiary,
                        fontStyle: TeXViewFontStyle(
                          sizeUnit: TeXViewSizeUnit.pixels,
                          fontSize: 16,
                          fontWeight: TeXViewFontWeight.normal,
                        ),
                      ),
                      renderingEngine: const TeXViewRenderingEngine.katex(),
                    ),
                  ),
                ),
              ] else ...[
                Flexible(
                  fit: FlexFit.tight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.width * UiUtils.hzMarginPct,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),

                        Text(
                          question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeights.regular,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),

                        /// Image
                        if (imageUrl != null && imageUrl != '') ...[
                          const SizedBox(height: 30),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: context.width * .9,
                              height: context.width * .5,
                              alignment: Alignment.center,
                              child: CachedNetworkImage(
                                placeholder: (_, _) => const Center(
                                  child: CircularProgressContainer(),
                                ),
                                imageUrl: imageUrl,
                                imageBuilder: (context, imageProvider) {
                                  return InteractiveViewer(
                                    boundaryMargin: const EdgeInsets.all(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (_, i, e) {
                                  return Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizZoneQuestions() {
    final bookmarkCubit = context.read<BookmarkCubit>();
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: context.height * .65,
                  child: ListView.separated(
                    itemBuilder: (_, index) {
                      final question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarked question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) =>
                              BlocConsumer<
                                UpdateBookmarkCubit,
                                UpdateBookmarkState
                              >(
                                bloc: context.read<UpdateBookmarkCubit>(),
                                listener: (_, state) {
                                  if (state is UpdateBookmarkSuccess) {
                                    bookmarkCubit.removeBookmarkQuestion(
                                      question.id!,
                                    );
                                  }
                                  if (state is UpdateBookmarkFailure) {
                                    context.showSnack(
                                      context.tr(
                                        convertErrorCodeToLanguageKey(
                                          errorCodeUpdateBookmarkFailure,
                                        ),
                                      )!,
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return BookmarkCard(
                                    queId: question.id!,
                                    index: '${index + 1}',
                                    title: question.question!,
                                    type: '1',
                                    // type QuizZone
                                    isLatex: isLatexModeEnabled,
                                    onTap: () {
                                      openBottomSheet(
                                        question: question.question!,
                                        imageUrl: question.imageUrl,
                                        isLatex: isLatexModeEnabled,
                                      );
                                    },
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: UiUtils.listTileGap),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      if (state is BookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('playBookmarkBtn'),
                          radius: 8,
                          showBorder: false,
                          fontWeight: FontWeights.semiBold,
                          height: 58,
                          titleColor: Theme.of(context).colorScheme.surface,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.quizZone,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is BookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<BookmarkCubit>().getBookmark();
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAudioQuestions() {
    final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
    return BlocBuilder<AudioQuestionBookmarkCubit, AudioQuestionBookMarkState>(
      bloc: bookmarkCubit,
      builder: (context, state) {
        if (state is AudioQuestionBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: context.height * .65,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarekd question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) =>
                              BlocConsumer<
                                UpdateBookmarkCubit,
                                UpdateBookmarkState
                              >(
                                bloc: context.read<UpdateBookmarkCubit>(),
                                listener: (context, state) {
                                  if (state is UpdateBookmarkSuccess) {
                                    bookmarkCubit.removeBookmarkQuestion(
                                      question.id!,
                                    );
                                  }
                                  if (state is UpdateBookmarkFailure) {
                                    context.showSnack(
                                      context.tr(
                                        convertErrorCodeToLanguageKey(
                                          errorCodeUpdateBookmarkFailure,
                                        ),
                                      )!,
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return BookmarkCard(
                                    queId: question.id!,
                                    index: '${index + 1}',
                                    title: question.question!,
                                    type: '4',
                                    onTap: state is UpdateBookmarkInProgress
                                        ? () {}
                                        : () {
                                            openBottomSheet(
                                              question: question.question!,
                                              imageUrl: '',
                                            );
                                          }, // type Audio Quiz
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) =>
                        SizedBox(height: context.height * 0.015),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child:
                      BlocBuilder<
                        AudioQuestionBookmarkCubit,
                        AudioQuestionBookMarkState
                      >(
                        builder: (context, state) {
                          if (state is AudioQuestionBookmarkFetchSuccess &&
                              state.questions.isNotEmpty) {
                            return CustomRoundedButton(
                              widthPercentage: 1,
                              backgroundColor: Theme.of(context).primaryColor,
                              buttonTitle: context.tr('playBookmarkBtn'),
                              radius: 8,
                              showBorder: false,
                              fontWeight: FontWeight.w500,
                              height: 58,
                              titleColor: Theme.of(context).colorScheme.surface,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.bookmarkQuiz,
                                  arguments: QuizTypes.audioQuestions,
                                );
                              },
                              elevation: 6.5,
                              textSize: 18,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                ),
              ),
            ],
          );
        }
        if (state is AudioQuestionBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<AudioQuestionBookmarkCubit>().getBookmark();
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Center noBookmarksFound() => Center(
    child: Text(
      context.tr('noBookmarkQueLbl')!,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 20,
      ),
    ),
  );

  Widget _buildGuessTheWordQuestions() {
    final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
    return BlocBuilder<GuessTheWordBookmarkCubit, GuessTheWordBookmarkState>(
      bloc: context.read<GuessTheWordBookmarkCubit>(),
      builder: (context, state) {
        if (state is GuessTheWordBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              SizedBox(
                height: context.height * .65,
                child: ListView.separated(
                  separatorBuilder: (_, i) =>
                      SizedBox(height: context.height * 0.015),
                  itemBuilder: (context, index) {
                    final question = state.questions[index];

                    //providing updateBookmarkCubit to every bookmarked question
                    return BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository()),
                      //using builder so we can access the recently provided cubit
                      child: Builder(
                        builder: (context) =>
                            BlocConsumer<
                              UpdateBookmarkCubit,
                              UpdateBookmarkState
                            >(
                              bloc: context.read<UpdateBookmarkCubit>(),
                              listener: (context, state) {
                                if (state is UpdateBookmarkSuccess) {
                                  bookmarkCubit.removeBookmarkQuestion(
                                    question.id,
                                  );
                                }
                                if (state is UpdateBookmarkFailure) {
                                  context.showSnack(
                                    context.tr(
                                      convertErrorCodeToLanguageKey(
                                        errorCodeUpdateBookmarkFailure,
                                      ),
                                    )!,
                                  );
                                }
                              },
                              builder: (context, state) {
                                return BookmarkCard(
                                  queId: question.id,
                                  index: '${index + 1}',
                                  title: question.question,
                                  type: '3',
                                  onTap: () {
                                    openBottomSheet(
                                      question: question.question,
                                      imageUrl: question.image,
                                    );
                                  },
                                );
                              },
                            ),
                      ),
                    );
                  },
                  itemCount: state.questions.length,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child:
                      BlocBuilder<
                        GuessTheWordBookmarkCubit,
                        GuessTheWordBookmarkState
                      >(
                        builder: (context, state) {
                          if (state is GuessTheWordBookmarkFetchSuccess &&
                              state.questions.isNotEmpty) {
                            return CustomRoundedButton(
                              widthPercentage: 1,
                              backgroundColor: Theme.of(context).primaryColor,
                              buttonTitle: context.tr('playBookmarkBtn'),
                              radius: 8,
                              showBorder: false,
                              fontWeight: FontWeight.w500,
                              height: 58,
                              titleColor: Theme.of(context).colorScheme.surface,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.bookmarkQuiz,
                                  arguments: QuizTypes.guessTheWord,
                                );
                              },
                              elevation: 6.5,
                              textSize: 18,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                ),
              ),
            ],
          );
        }
        if (state is GuessTheWordBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () =>
                context.read<GuessTheWordBookmarkCubit>().getBookmark(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr(bookmarkLbl)!),
        bottom: TabBar(
          isScrollable: true,
          controller: tabController,
          tabs: tabs.map((tab) => Tab(text: context.tr(tab.$1))).toList(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.height * UiUtils.vtMarginPct,
          horizontal: context.width * UiUtils.hzMarginPct,
        ),
        child: TabBarView(
          controller: tabController,
          children: tabs.map((tab) => tab.$2).toList(),
        ),
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    required this.index,
    required this.title,
    required this.queId,
    required this.type,
    required this.onTap,
    super.key,
    this.isLatex = false,
  });

  final String index;
  final String title;
  final String queId;
  final String type;
  final bool isLatex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.height * .1,
        width: context.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffFFD7E5),
                  ),
                  width: constraints.maxWidth * .13,
                  height: constraints.maxWidth * .13,
                  child: Center(
                    child: Text(
                      index,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                SizedBox(
                  width: constraints.maxWidth * .722,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      if (isLatex) ...[
                        Expanded(
                          child: TeXView(
                            child: TeXViewGroup(
                              children: [
                                TeXViewGroupItem(
                                  id: '-',
                                  child: TeXViewDocument(
                                    title,
                                    style: TeXViewStyle(
                                      contentColor: Theme.of(
                                        context,
                                      ).colorScheme.onTertiary,
                                      fontStyle: TeXViewFontStyle(
                                        sizeUnit: TeXViewSizeUnit.pixels,
                                        fontSize: 16,
                                        fontWeight: TeXViewFontWeight.w500,
                                      ),
                                      margin: const TeXViewMargin.only(
                                        bottom: 10,
                                        sizeUnit: TeXViewSizeUnit.pixels,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onTap: (_) => onTap(),
                            ),
                            renderingEngine:
                                const TeXViewRenderingEngine.katex(),
                          ),
                        ),
                      ] else ...[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeights.bold,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                /// Close
                GestureDetector(
                  onTap: () {
                    context.read<UpdateBookmarkCubit>().updateBookmark(
                      queId,
                      '0',
                      type,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
