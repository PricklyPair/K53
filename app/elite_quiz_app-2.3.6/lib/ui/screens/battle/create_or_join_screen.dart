import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/room_code_char_type.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/battle_invite_card.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/top_curve_clipper.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CreateOrJoinRoomScreen extends StatefulWidget {
  const CreateOrJoinRoomScreen({
    required this.quizType,
    required this.title,
    super.key,
  });

  final QuizTypes quizType;
  final String title;

  @override
  State<CreateOrJoinRoomScreen> createState() => _CreateOrJoinRoomScreenState();
}

class _CreateOrJoinRoomScreenState extends State<CreateOrJoinRoomScreen> {
  late final bool isInAppPurchaseEnabled;

  String selectedCategory = selectCategoryKey;
  String selectedCategoryId = '0';
  String selectedCategoryImage = '';
  TextEditingController customEntryFee = TextEditingController(text: '');
  late final int minEntryCoins;
  late List<int> entryFees;
  late int entryFee = entryFees.first;

  /// Screen Dimensions
  double get scrWidth => context.width;

  double get scrHeight => context.height;

  /// --- for status bar and status bottom nav colors corrections
  late final SystemUiOverlayStyle systemUiOverlayStyle =
      (context.read<ThemeCubit>().state == Brightness.light
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.light);

  late final Brightness systemNavigationBarIconBrightness =
      context.read<ThemeCubit>().state == Brightness.light
      ? Brightness.dark
      : Brightness.light;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    isInAppPurchaseEnabled = context
        .read<SystemConfigCubit>()
        .isCoinStoreEnabled;
    minEntryCoins = widget.quizType == QuizTypes.oneVsOneBattle
        ? context.read<SystemConfigCubit>().oneVsOneBattleMinimumEntryFee
        : context.read<SystemConfigCubit>().groupBattleMinimumEntryFee;

    entryFees = [
      minEntryCoins,
      minEntryCoins * 2,
      minEntryCoins * 3,
      minEntryCoins * 4,
    ];

    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
      if (isCategoryEnabled()) {
        _getCategories();
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  void _getCategories() {
    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
      languageId: UiUtils.getCurrentQuizLanguageId(context),
      type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
      subType: UiUtils.subTypeFromQuizType(widget.quizType),
    );
  }

  bool isCategoryEnabled() {
    return widget.quizType == QuizTypes.oneVsOneBattle
        ? context.read<SystemConfigCubit>().isCategoryEnabledForOneVsOneBattle
        : context.read<SystemConfigCubit>().isCategoryEnabledForGroupBattle;
  }

  RoomCodeCharType get roomCodeCharType =>
      widget.quizType == QuizTypes.oneVsOneBattle
      ? context.read<SystemConfigCubit>().oneVsOneBattleRoomCodeCharType
      : context.read<SystemConfigCubit>().groupBattleRoomCodeCharType;

  Widget _buildDropDown({
    required List<Map<String, String?>> values,
    required String keyValue,
  }) {
    selectedCategoryId = values.map((e) => e['id']).toList().first!;
    selectedCategory = values.map((e) => e['name']).toList().first!;
    selectedCategoryImage = values.map((e) => e['image']).toList().first!;

    return StatefulBuilder(
      builder: (context, setState) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButton<String>(
            key: Key(keyValue),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: colorScheme.surface,
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontSize: 16,
              fontWeight: FontWeights.regular,
            ),
            isExpanded: true,
            alignment: Alignment.center,
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.onTertiary.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onTertiary,
              ),
            ),
            value: selectedCategoryId,
            hint: Text(
              context.tr(selectCategoryKey)!,
              style: TextStyle(
                color: colorScheme.onTertiary.withValues(alpha: 0.4),
                fontSize: 16,
                fontWeight: FontWeights.regular,
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value!;

                // set name and image for selected category
                final index = values.indexWhere((v) => v['id'] == value);
                if (index != -1) {
                  selectedCategory = values[index]['name']!;
                  selectedCategoryImage = values[index]['image']!;
                }
              });
            },
            items: values.map((e) {
              final name = e['name'];
              final id = e['id'];
              return DropdownMenuItem<String>(
                value: id,
                child: name == selectCategoryKey
                    ? Text(context.tr(selectCategoryKey)!)
                    : Text(name!),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  ///
  void showCreateRoomBottomSheet() {
    customEntryFee = TextEditingController(text: '');
    entryFee = entryFees.first;
    final title = context.tr(
      widget.quizType == QuizTypes.oneVsOneBattle ? 'randomLbl' : 'groupPlay',
    );

    context.read<MultiUserBattleRoomCubit>().updateState(
      MultiUserBattleRoomInitial(),
      cancelSubscription: true,
    );
    context.read<BattleRoomCubit>().updateState(
      BattleRoomInitial(),
      cancelSubscription: true,
    );

    showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;

        return AnnotatedRegion(
          value: systemUiOverlayStyle.copyWith(
            systemNavigationBarColor: context.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                systemNavigationBarIconBrightness,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  borderRadius: UiUtils.bottomSheetTopRadius,
                ),
                height: scrHeight * 0.75,
                margin: MediaQuery.of(context).viewInsets,
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Create Room title
                    Align(
                      child: Text(
                        "${context.tr("creatingLbl")} $title",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),

                    /// horizontal divider
                    const Divider(),
                    const SizedBox(height: 15),

                    /// select category text
                    if (isCategoryEnabled()) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.width * UiUtils.hzMarginPct,
                        ),
                        child: Text(
                          context.tr(selectCategoryKey)!,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// Select Category Drop Down
                      BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                        bloc: context.read<QuizCategoryCubit>(),
                        listener: (_, state) {
                          if (state is QuizCategorySuccess) {
                            selectedCategoryId = state.categories.first.id!;
                            selectedCategory =
                                state.categories.first.categoryName!;
                          }
                        },
                        builder: (_, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: state is QuizCategorySuccess
                                ? _buildDropDown(
                                    values: state.categories
                                        .where((c) => !c.isPremium)
                                        .map(
                                          (e) => {
                                            'name': e.categoryName,
                                            'image': e.image,
                                            'id': e.id,
                                          },
                                        )
                                        .toList(),
                                    keyValue: 'selectCategorySuccess',
                                  )
                                : Opacity(
                                    opacity: 0.65,
                                    child: _buildDropDown(
                                      values: [
                                        {
                                          'name': selectCategoryKey,
                                          'id': '0',
                                          'image': '',
                                        },
                                      ],
                                      keyValue: selectCategoryKey,
                                    ),
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],

                    ///
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.width * UiUtils.hzMarginPct,
                      ),
                      child: Text(
                        context.tr('entryCoinsForBattle')!,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.width * UiUtils.hzMarginPct,
                      ),
                      child: StatefulBuilder(
                        builder: (context, state) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: entryFees
                                .map((e) => _coinCard(e, state))
                                .toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.width * UiUtils.hzMarginPct,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: customEntryFee,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeights.regular,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.tr('plsEnterTheCoins'),
                          hintStyle: TextStyle(
                            color: colorScheme.onTertiary.withValues(alpha: .4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.width * UiUtils.hzMarginPct,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('yourCoins')!,
                                style: TextStyle(
                                  color: colorScheme.onTertiary.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeights.regular,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${context.watch<UserDetailsCubit>().getCoins()} ${context.tr(coinsLbl)}',
                                style: TextStyle(
                                  color: colorScheme.onTertiary,
                                  fontWeight: FontWeights.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          if (isInAppPurchaseEnabled)
                            if (widget.quizType == QuizTypes.oneVsOneBattle)
                              BlocBuilder<BattleRoomCubit, BattleRoomState>(
                                builder: (context, state) {
                                  return TextButton(
                                    onPressed: () {
                                      if (state is BattleRoomCreating) return;

                                      Navigator.of(
                                        context,
                                      ).pushNamed(Routes.coinStore);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: colorScheme.surface,
                                      padding: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      context.tr('buyCoins')!,
                                      style: TextStyle(
                                        color: state is BattleRoomCreating
                                            ? Theme.of(context).disabledColor
                                            : Theme.of(context).primaryColor,
                                        fontSize: 14,
                                        height: 1.2,
                                        fontWeight: FontWeights.medium,
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              BlocBuilder<
                                MultiUserBattleRoomCubit,
                                MultiUserBattleRoomState
                              >(
                                builder: (context, state) {
                                  return TextButton(
                                    onPressed: () {
                                      if (state
                                          is MultiUserBattleRoomInProgress) {
                                        return;
                                      }

                                      Navigator.of(
                                        context,
                                      ).pushNamed(Routes.coinStore);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: colorScheme.surface,
                                      padding: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      context.tr('buyCoins')!,
                                      style: TextStyle(
                                        color:
                                            state
                                                is MultiUserBattleRoomInProgress
                                            ? Theme.of(context).disabledColor
                                            : Theme.of(context).primaryColor,
                                        fontSize: 14,
                                        height: 1.2,
                                        fontWeight: FontWeights.medium,
                                      ),
                                    ),
                                  );
                                },
                              )
                          else
                            const SizedBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (widget.quizType == QuizTypes.oneVsOneBattle)
                      BlocConsumer<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        listener: (context, state) {
                          if (state is BattleRoomFailure) {
                            if (state.errorMessageCode ==
                                errorCodeUnauthorizedAccess) {
                              showAlreadyLoggedInDialog(context);
                              return;
                            }
                            context.showErrorDialog(
                              context.tr(
                                convertErrorCodeToLanguageKey(
                                  state.errorMessageCode,
                                ),
                              )!,
                            );
                          } else if (state is BattleRoomCreated) {
                            //wait for others
                            Navigator.of(context).pop();
                            inviteToRoomBottomSheet();
                          }
                        },
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.width * UiUtils.hzMarginPct,
                            ),
                            child: state is BattleRoomCreating
                                ? const CircularProgressContainer()
                                : CustomRoundedButton(
                                    widthPercentage: context.width,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    radius: 10,
                                    showBorder: false,
                                    height: 50,
                                    onTap: () {
                                      if (state is BattleRoomCreating) {
                                        return;
                                      }

                                      if (customEntryFee.text != '') {
                                        entryFee = int.parse(
                                          customEntryFee.text,
                                        );
                                      }

                                      if (entryFee < 0) {
                                        context.showErrorDialog(
                                          context.tr(moreThanZeroCoinsKey)!,
                                        );
                                        return;
                                      }

                                      final userProfile = context
                                          .read<UserDetailsCubit>()
                                          .getUserProfile();

                                      if (int.parse(userProfile.coins!) <
                                          entryFee) {
                                        showNotEnoughCoinsDialog(context);
                                        return;
                                      }

                                      /// Create Room
                                      context.read<BattleRoomCubit>().createRoom(
                                        categoryId: selectedCategoryId,
                                        categoryName: selectedCategory,
                                        categoryImage: selectedCategoryImage,
                                        entryFee: entryFee,
                                        name: userProfile.name,
                                        profileUrl: userProfile.profileUrl,
                                        uid: userProfile.userId,
                                        questionLanguageId:
                                            UiUtils.getCurrentQuizLanguageId(
                                              context,
                                            ),
                                        charType: context
                                            .read<SystemConfigCubit>()
                                            .oneVsOneBattleRoomCodeCharType,
                                      );
                                    },
                                    buttonTitle: context.tr('createRoom'),
                                  ),
                          );
                        },
                      )
                    else
                      BlocConsumer<
                        MultiUserBattleRoomCubit,
                        MultiUserBattleRoomState
                      >(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        listener: (_, state) {
                          if (state is MultiUserBattleRoomFailure) {
                            if (state.errorMessageCode ==
                                errorCodeUnauthorizedAccess) {
                              showAlreadyLoggedInDialog(context);
                              return;
                            }
                            context.showErrorDialog(
                              context.tr(
                                convertErrorCodeToLanguageKey(
                                  state.errorMessageCode,
                                ),
                              )!,
                            );
                          } else if (state is MultiUserBattleRoomSuccess) {
                            //wait for others
                            Navigator.of(context).pop();
                            inviteToRoomBottomSheet();
                          }
                        },
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.width * UiUtils.hzMarginPct,
                            ),
                            child: state is MultiUserBattleRoomInProgress
                                ? const CircularProgressContainer()
                                : CustomRoundedButton(
                                    widthPercentage: context.width,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    radius: 10,
                                    showBorder: false,
                                    height: 50,
                                    onTap: () {
                                      if (state
                                          is MultiUserBattleRoomInProgress) {
                                        return;
                                      }

                                      final userProfile = context
                                          .read<UserDetailsCubit>()
                                          .getUserProfile();

                                      if (customEntryFee.text != '') {
                                        entryFee = int.parse(
                                          customEntryFee.text,
                                        );
                                      }

                                      ///
                                      if (entryFee < 0) {
                                        context.showErrorDialog(
                                          context.tr(moreThanZeroCoinsKey)!,
                                        );
                                        return;
                                      }

                                      if (int.parse(userProfile.coins!) <
                                          entryFee) {
                                        showNotEnoughCoinsDialog(context);
                                        return;
                                      }

                                      /// Create Room
                                      context
                                          .read<MultiUserBattleRoomCubit>()
                                          .createRoom(
                                            categoryId: selectedCategoryId,
                                            categoryName: selectedCategory,
                                            categoryImage:
                                                selectedCategoryImage,
                                            charType: context
                                                .read<SystemConfigCubit>()
                                                .groupBattleRoomCodeCharType,
                                            entryFee: entryFee,
                                            name: userProfile.name,
                                            profileUrl: userProfile.profileUrl,
                                            roomType: 'public',
                                            uid: userProfile.userId,
                                            questionLanguageId:
                                                UiUtils.getCurrentQuizLanguageId(
                                                  context,
                                                ),
                                          );
                                    },
                                    buttonTitle: context.tr('createRoom'),
                                  ),
                          );
                        },
                      ),
                    const SizedBox(height: 19),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showRoomDestroyed(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shadowColor: Colors.transparent,
          content: Text(
            context.tr('roomDeletedOwnerLbl')!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                context.tr('okayLbl')!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareRoomCode({
    required BuildContext context,
    required String roomCode,
    required String categoryName,
    required int entryFee,
  }) {
    try {
      final msgIntro = context.tr('battleInviteMessageIntro');
      final msgJoin = context.tr('battleInviteMessageJoin');
      final msgEnd = context.tr('battleInviteMessageEnd');

      final inviteMessage =
          '$msgIntro $kAppName, $msgJoin $roomCode \n'
          '${context.tr('categoryLbl')} : $categoryName, '
          '${context.tr('just')} $entryFee ${context.tr('coinsLbl')} $msgEnd';

      UiUtils.share(inviteMessage, context: context);
    } on Exception catch (_) {
      context.showSnack(context.tr(defaultErrorMessageKey)!);
    }
  }

  void inviteToRoomBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;

        if (widget.quizType == QuizTypes.oneVsOneBattle) {
          var shareText = context.tr('shareRoomCodeRndLbl')!;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiOverlayStyle.copyWith(
              systemNavigationBarColor: context.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness:
                  systemNavigationBarIconBrightness,
            ),
            child: BlocConsumer<BattleRoomCubit, BattleRoomState>(
              listener: (context, state) {
                if (state is BattleRoomUserFound) {
                  //if game is ready to play
                  if (state.battleRoom.readyToPlay!) {
                    //if user has joined room then navigate to quiz screen
                    if (state.battleRoom.user1!.uid !=
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId) {
                      Navigator.of(context).pushReplacementNamed(
                        Routes.battleRoomQuiz,
                        arguments: {
                          'quiz_type': QuizTypes.oneVsOneBattle,
                          'play_with_bot': false,
                        },
                      );
                    }
                  }

                  //if owner deleted the room then show this dialog
                  if (!state.isRoomExist) {
                    if (context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId !=
                        state.battleRoom.user1!.uid) {
                      //Room destroyed by owner
                      showRoomDestroyed(context);
                    }
                  }
                }
              },
              builder: (context, battleState) {
                var showShareIcon = true;
                if (battleState is BattleRoomUserFound) {
                  shareText =
                      battleState.battleRoom.user2!.uid ==
                          context.read<UserDetailsCubit>().userId()
                      ? context.tr('waitGameWillStartLbl')!
                      : shareText;
                  showShareIcon =
                      battleState.battleRoom.user2!.uid !=
                      context.read<UserDetailsCubit>().userId();
                }

                return StatefulBuilder(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: UiUtils.bottomSheetTopRadius,
                      ),
                      height: scrHeight * 0.85,
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * UiUtils.hzMarginPct,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopScope(
                                  canPop:
                                      battleState is! BattleRoomCreated &&
                                      battleState is! BattleRoomUserFound,
                                  onPopInvokedWithResult: (didPop, _) {
                                    if (didPop) return;

                                    showExitOrDeleteRoomDialog();
                                  },
                                  child: InkWell(
                                    onTap: showExitOrDeleteRoomDialog,
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onTertiary,
                                    ),
                                  ),
                                ),
                                Text(
                                  context.tr('joinRoom')!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                if (showShareIcon)
                                  Builder(
                                    builder: (context) {
                                      return InkWell(
                                        onTap: () => _shareRoomCode(
                                          context: context,
                                          roomCode: context
                                              .read<BattleRoomCubit>()
                                              .getRoomCode(),
                                          categoryName: context
                                              .read<BattleRoomCubit>()
                                              .categoryName,
                                          entryFee: context
                                              .read<BattleRoomCubit>()
                                              .getEntryFee(),
                                        ),
                                        child: Icon(
                                          Icons.share,
                                          size: 20,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onTertiary,
                                        ),
                                      );
                                    },
                                  )
                                else
                                  const SizedBox(),
                              ],
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),

                          /// Invite Code
                          BattleInviteCard(
                            categoryImage: context
                                .read<BattleRoomCubit>()
                                .categoryImage,
                            categoryName: context
                                .read<BattleRoomCubit>()
                                .categoryName,
                            entryFee: context
                                .read<BattleRoomCubit>()
                                .getEntryFee(),
                            roomCode: context
                                .read<BattleRoomCubit>()
                                .getRoomCode(),
                            shareText: shareText,
                            categoryEnabled: context
                                .read<SystemConfigCubit>()
                                .isCategoryEnabledForOneVsOneBattle,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child:
                                BlocBuilder<BattleRoomCubit, BattleRoomState>(
                                  builder: (_, state) {
                                    if (state is BattleRoomCreated) {
                                      return GridView.count(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              scrWidth * UiUtils.hzMarginPct,
                                        ),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        children: [
                                          inviteRoomUserCard(
                                            state.battleRoom.user1!.name,
                                            state.battleRoom.user1!.profileUrl,
                                            isCreator: true,
                                          ),
                                          inviteRoomUserCard(
                                            state.battleRoom.user2!.name.isEmpty
                                                ? context.tr('player2')!
                                                : state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            isCreator: false,
                                          ),
                                        ],
                                      );
                                    }
                                    if (state is BattleRoomUserFound) {
                                      return GridView.count(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              scrWidth * UiUtils.hzMarginPct,
                                        ),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        children: [
                                          inviteRoomUserCard(
                                            state.battleRoom.user1!.name,
                                            state.battleRoom.user1!.profileUrl,
                                            isCreator: true,
                                          ),
                                          inviteRoomUserCard(
                                            state.battleRoom.user2!.name.isEmpty
                                                ? context.tr('player2')!
                                                : state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            isCreator: false,
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                          ),

                          BlocBuilder<BattleRoomCubit, BattleRoomState>(
                            bloc: context.read<BattleRoomCubit>(),
                            builder: (context, state) {
                              if (state is BattleRoomCreated) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        await context.showErrorDialog(
                                          context.tr(
                                            convertErrorCodeToLanguageKey(
                                              errorCodeCanNotStartGame,
                                            ),
                                          )!,
                                        );
                                      } else {
                                        context
                                            .read<BattleRoomCubit>()
                                            .startGame();
                                        await Future<void>.delayed(
                                          const Duration(milliseconds: 500),
                                        );
                                        //navigate to quiz screen
                                        await Navigator.of(
                                          context,
                                        ).pushReplacementNamed(
                                          Routes.battleRoomQuiz,
                                          arguments: {
                                            'quiz_type':
                                                QuizTypes.oneVsOneBattle,
                                            'play_with_bot': false,
                                          },
                                        );
                                      }
                                    },
                                    child: Text(
                                      context.tr('startLbl')!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (state is BattleRoomUserFound) {
                                if (state.battleRoom.user1!.uid !=
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserProfile()
                                        .userId) {
                                  return Container();
                                }

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        await context.showErrorDialog(
                                          context.tr(
                                            convertErrorCodeToLanguageKey(
                                              errorCodeCanNotStartGame,
                                            ),
                                          )!,
                                        );
                                      } else {
                                        context
                                            .read<BattleRoomCubit>()
                                            .startGame();
                                        await Future<void>.delayed(
                                          const Duration(milliseconds: 500),
                                        );
                                        //navigate to quiz screen
                                        await Navigator.of(
                                          context,
                                        ).pushReplacementNamed(
                                          Routes.battleRoomQuiz,
                                          arguments: {
                                            'quiz_type':
                                                QuizTypes.oneVsOneBattle,
                                            'play_with_bot': false,
                                          },
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      context.tr('startLbl')!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else {
          return AnnotatedRegion(
            value: systemUiOverlayStyle.copyWith(
              systemNavigationBarColor: context.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness:
                  systemNavigationBarIconBrightness,
            ),
            child: BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
              listener: (context, state) {
                if (state is MultiUserBattleRoomSuccess) {
                  //if game is ready to play
                  if (state.battleRoom.readyToPlay!) {
                    //if user has joined room then navigate to quiz screen
                    if (state.battleRoom.user1!.uid !=
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(Routes.multiUserBattleRoomQuiz);
                    }
                  }

                  //if owner deleted the room then show this dialog
                  if (!state.isRoomExist) {
                    if (context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId !=
                        state.battleRoom.user1!.uid) {
                      //Room destroyed by owner
                      showRoomDestroyed(context);
                    }
                  }
                }
              },
              builder: (context, battleState) {
                return StatefulBuilder(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: UiUtils.bottomSheetTopRadius,
                      ),
                      height: scrHeight * 0.85,
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * UiUtils.hzMarginPct,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopScope(
                                  canPop:
                                      battleState
                                          is! MultiUserBattleRoomSuccess,
                                  onPopInvokedWithResult: (didPop, _) {
                                    if (didPop) return;

                                    showExitOrDeleteRoomDialog();
                                  },
                                  child: InkWell(
                                    onTap: showExitOrDeleteRoomDialog,
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onTertiary,
                                    ),
                                  ),
                                ),
                                Text(
                                  context.tr('joinRoom')!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    return InkWell(
                                      onTap: () => _shareRoomCode(
                                        context: context,
                                        roomCode: context
                                            .read<MultiUserBattleRoomCubit>()
                                            .getRoomCode(),
                                        categoryName: context
                                            .read<MultiUserBattleRoomCubit>()
                                            .categoryName,
                                        entryFee: context
                                            .read<MultiUserBattleRoomCubit>()
                                            .getEntryFee(),
                                      ),
                                      child: Icon(
                                        Icons.share,
                                        size: 20,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiary,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 15),

                          /// Invite Code
                          BattleInviteCard(
                            categoryImage: context
                                .read<MultiUserBattleRoomCubit>()
                                .categoryImage,
                            categoryName: context
                                .read<MultiUserBattleRoomCubit>()
                                .categoryName,
                            entryFee: context
                                .read<MultiUserBattleRoomCubit>()
                                .getEntryFee(),
                            roomCode: context
                                .read<MultiUserBattleRoomCubit>()
                                .getRoomCode(),
                            shareText: context.tr('shareRoomCodeLbl')!,
                            categoryEnabled: context
                                .read<SystemConfigCubit>()
                                .isCategoryEnabledForGroupBattle,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child:
                                BlocBuilder<
                                  MultiUserBattleRoomCubit,
                                  MultiUserBattleRoomState
                                >(
                                  builder: (_, state) {
                                    if (state is MultiUserBattleRoomSuccess) {
                                      return GridView.count(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              scrWidth * UiUtils.hzMarginPct,
                                        ),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        children: [
                                          inviteRoomUserCard(
                                            state.battleRoom.user1!.name,
                                            state.battleRoom.user1!.profileUrl,
                                            isCreator: true,
                                          ),
                                          inviteRoomUserCard(
                                            state.battleRoom.user2!.name.isEmpty
                                                ? context.tr('player2')!
                                                : state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            isCreator: false,
                                          ),
                                          inviteRoomUserCard(
                                            state.battleRoom.user3!.name.isEmpty
                                                ? context.tr('player3')!
                                                : state.battleRoom.user3!.name,
                                            state.battleRoom.user3!.profileUrl,
                                            isCreator: false,
                                          ),
                                          inviteRoomUserCard(
                                            state.battleRoom.user4!.name.isEmpty
                                                ? context.tr('player4')!
                                                : state.battleRoom.user4!.name,
                                            state.battleRoom.user4!.profileUrl,
                                            isCreator: false,
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                          ),
                          const SizedBox(height: 20),

                          /// Start
                          BlocBuilder<
                            MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState
                          >(
                            builder: (context, state) {
                              if (state is MultiUserBattleRoomSuccess) {
                                if (state.battleRoom.user1!.uid !=
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserProfile()
                                        .userId) {
                                  return Container();
                                }
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        context.showErrorDialog(
                                          context.tr(
                                            convertErrorCodeToLanguageKey(
                                              errorCodeCanNotStartGame,
                                            ),
                                          )!,
                                        );
                                      } else {
                                        //start quiz
                                        /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/
                                        context
                                            .read<MultiUserBattleRoomCubit>()
                                            .startGame();
                                        //navigate to quiz screen
                                        widget.quizType ==
                                                QuizTypes.oneVsOneBattle
                                            ? Navigator.of(
                                                context,
                                              ).pushReplacementNamed(
                                                Routes.battleRoomQuiz,
                                                arguments: {
                                                  'quiz_type':
                                                      QuizTypes.oneVsOneBattle,
                                                  'play_with_bot': false,
                                                },
                                              )
                                            : Navigator.of(
                                                context,
                                              ).pushReplacementNamed(
                                                Routes.multiUserBattleRoomQuiz,
                                              );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      context.tr('startLbl')!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  /// Delete room if user is creator, otherwise remove user from the room.
  Future<void> showExitOrDeleteRoomDialog() {
    void onTapYes() {
      final userId = context.read<UserDetailsCubit>().getUserProfile().userId;

      if (widget.quizType == QuizTypes.oneVsOneBattle) {
        var isCreator = false;
        final battleCubit = context.read<BattleRoomCubit>();

        if (battleCubit.state is BattleRoomUserFound) {
          isCreator =
              (battleCubit.state as BattleRoomUserFound)
                  .battleRoom
                  .user1!
                  .uid ==
              userId;
        } else {
          isCreator =
              (battleCubit.state as BattleRoomCreated).battleRoom.user1!.uid ==
              userId;
        }

        if (isCreator) {
          battleCubit.deleteBattleRoom();
        } else {
          battleCubit.deleteUserFromRoom(userId!);
        }
      } else {
        final multiUserCubit = context.read<MultiUserBattleRoomCubit>();

        final isCreator =
            (multiUserCubit.state as MultiUserBattleRoomSuccess)
                .battleRoom
                .user1!
                .uid ==
            userId;

        if (isCreator) {
          multiUserCubit.deleteMultiUserBattleRoom();
        } else {
          multiUserCubit.deleteUserFromRoom(userId!);
        }
      }

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }

    final textStyle = GoogleFonts.nunito(
      textStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
    );

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titleTextStyle: textStyle,
          contentTextStyle: textStyle,
          content: Text(context.tr('roomDelete')!),
          actions: [
            CupertinoButton(
              onPressed: onTapYes,
              child: Text(
                context.tr('yesBtn')!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            CupertinoButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                context.tr('noBtn')!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget inviteRoomUserCard(
    String userName,
    String img, {
    required bool isCreator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surface,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: QImage.circular(
              imageUrl: img.isNotEmpty ? img : Assets.friendImg,
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.regular,
              color: colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 9),
          if (isCreator)
            Text(
              context.tr('creator')!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeights.regular,
                color: colorScheme.onTertiary.withValues(alpha: 0.4),
              ),
            )
          else
            Text(
              context.tr('addPlayer')!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeights.regular,
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _coinCard(int coins, void Function(void Function()) state) {
    return GestureDetector(
      onTap: () => state(() => entryFee = coins),
      child: Container(
        width: 66,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: entryFee == coins
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 43,
              child: Center(
                child: Text(
                  coins.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeights.regular,
                    color: entryFee == coins
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 43,
              child: Center(child: SvgPicture.asset(Assets.coin)),
            ),
          ],
        ),
      ),
    );
  }

  void showJoinRoomBottomSheet() {
    final joinRoomCode = TextEditingController(text: '');
    // Reset Battle State to Initial.
    context.read<MultiUserBattleRoomCubit>().updateState(
      MultiUserBattleRoomInitial(),
      cancelSubscription: true,
    );
    context.read<BattleRoomCubit>().updateState(
      BattleRoomInitial(),
      cancelSubscription: true,
    );

    showModalBottomSheet<bool?>(
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      enableDrag: false,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        return AnnotatedRegion(
          value: systemUiOverlayStyle.copyWith(
            systemNavigationBarColor: context.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                systemNavigationBarIconBrightness,
          ),
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: UiUtils.bottomSheetTopRadius,
            ),
            height: scrHeight * 0.7,
            padding: const EdgeInsets.only(top: 20),
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Join Room title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scrWidth * UiUtils.hzMarginPct,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: onBackTapJoinRoom,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      Align(
                        child: Text(
                          context.tr('joinRoom')!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onTertiary,
                          ),
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                // horizontal divider
                const Divider(),
                const SizedBox(height: 30),

                Align(
                  child: Text(
                    context.tr(enterRoomCodeHereKey)!,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    keyboardType:
                        roomCodeCharType == RoomCodeCharType.onlyNumbers
                        ? TextInputType.number
                        : TextInputType.text,
                    textStyle: TextStyle(color: colorScheme.onTertiary),
                    pinTheme: PinTheme(
                      selectedFillColor: colorScheme.onTertiary.withValues(
                        alpha: 0.1,
                      ),
                      inactiveColor: colorScheme.onTertiary.withValues(
                        alpha: 0.1,
                      ),
                      activeColor: colorScheme.onTertiary.withValues(
                        alpha: 0.1,
                      ),
                      inactiveFillColor: colorScheme.onTertiary.withValues(
                        alpha: 0.1,
                      ),
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 45,
                      fieldWidth: 45,
                      activeFillColor: colorScheme.onTertiary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    cursorColor: colorScheme.onTertiary,
                    animationDuration: const Duration(milliseconds: 200),
                    enableActiveFill: true,
                    onChanged: (v) {},
                    controller: joinRoomCode,
                  ),
                ),
                const SizedBox(height: 40),

                if (widget.quizType == QuizTypes.oneVsOneBattle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: BlocConsumer<BattleRoomCubit, BattleRoomState>(
                      bloc: context.read<BattleRoomCubit>(),
                      listener: (context, state) {
                        if (state is BattleRoomUserFound) {
                          context.shouldPop();
                          inviteToRoomBottomSheet();
                        } else if (state is BattleRoomFailure) {
                          if (state.errorMessageCode ==
                              errorCodeUnauthorizedAccess) {
                            showAlreadyLoggedInDialog(context);
                            return;
                          } else if (state.errorMessageCode ==
                              errorCodeNotEnoughCoins) {
                            showNotEnoughCoinsDialog(context);
                            return;
                          } else {
                            context.showErrorDialog(
                              context.tr(
                                convertErrorCodeToLanguageKey(
                                  state.errorMessageCode,
                                ),
                              )!,
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is BattleRoomJoining) {
                          return const PopScope(
                            canPop: false,
                            child: CircularProgressContainer(),
                          );
                        }

                        return CustomRoundedButton(
                          widthPercentage: context.width,
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 10,
                          showBorder: false,
                          height: 50,
                          onTap: () {
                            // Close the Sheet if roomCode is Empty.
                            final roomCode = joinRoomCode.text.trim();
                            if (roomCode.isEmpty) {
                              Navigator.of(context).pop(true);
                              return;
                            }

                            final user = context
                                .read<UserDetailsCubit>()
                                .getUserProfile();

                            context.read<BattleRoomCubit>().joinRoom(
                              currentCoin: user.coins!,
                              name: user.name,
                              uid: user.userId,
                              profileUrl: user.profileUrl,
                              roomCode: roomCode,
                            );
                          },
                          buttonTitle: context.tr('joinRoom'),
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child:
                        BlocConsumer<
                          MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState
                        >(
                          listener: (context, state) {
                            if (state is MultiUserBattleRoomSuccess) {
                              context.shouldPop();
                              inviteToRoomBottomSheet();
                            } else if (state is MultiUserBattleRoomFailure) {
                              if (state.errorMessageCode ==
                                  errorCodeUnauthorizedAccess) {
                                showAlreadyLoggedInDialog(context);
                                return;
                              } else if (state.errorMessageCode ==
                                  errorCodeNotEnoughCoins) {
                                showNotEnoughCoinsDialog(context);
                                return;
                              } else {
                                context.showErrorDialog(
                                  context.tr(
                                    convertErrorCodeToLanguageKey(
                                      state.errorMessageCode,
                                    ),
                                  )!,
                                );
                              }
                            }
                          },
                          bloc: context.read<MultiUserBattleRoomCubit>(),
                          builder: (_, state) {
                            if (state is MultiUserBattleRoomInProgress) {
                              return const PopScope(
                                canPop: false,
                                child: CircularProgressContainer(),
                              );
                            }

                            return CustomRoundedButton(
                              widthPercentage: context.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: () {
                                // Close Sheet if roomCode is Empty.
                                final roomCode = joinRoomCode.text.trim();
                                if (roomCode.isEmpty) {
                                  Navigator.of(context).pop(true);
                                  return;
                                }

                                final user = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();

                                context
                                    .read<MultiUserBattleRoomCubit>()
                                    .joinRoom(
                                      currentCoin: user.coins!,
                                      name: user.name,
                                      uid: user.userId,
                                      profileUrl: user.profileUrl,
                                      roomCode: roomCode,
                                    );
                              },
                              buttonTitle: context.tr('joinRoom'),
                            );
                          },
                        ),
                  ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        return context.showSnack(context.tr(enterRoomCodeMsg)!);
      }
    });
  }

  void onBackTapJoinRoom() {
    if (widget.quizType == QuizTypes.oneVsOneBattle) {
      if (context.read<BattleRoomCubit>().state is! BattleRoomJoining) {
        Navigator.pop(context);
      }
    } else {
      if (context.read<MultiUserBattleRoomCubit>().state
          is! MultiUserBattleRoomInProgress) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = context;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle.copyWith(
        systemNavigationBarColor: context.surfaceColor,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      ),
      child: BlocListener<QuizCategoryCubit, QuizCategoryState>(
        listener: (context, state) {
          if (state is QuizCategoryFailure) {
            if (state.errorMessage == errorCodeUnauthorizedAccess) {
              showAlreadyLoggedInDialog(context);
              return;
            }

            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shadowColor: Colors.transparent,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      context.tr(retryLbl)!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
                content: Text(
                  context.tr(
                    convertErrorCodeToLanguageKey(state.errorMessage),
                  )!,
                ),
              ),
            ).then((value) {
              if (value != null && value) {
                _getCategories();
              }
            });
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Stack(
                children: [
                  /// Title & Back Btn
                  Container(
                    width: size.width,
                    height: size.height * 0.65,
                    color: Theme.of(context).primaryColor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// BG
                        SvgPicture.asset(
                          Assets.battleDesignImg,
                          fit: BoxFit.cover,
                          width: size.width,
                          height: size.height,
                        ),

                        /// VS
                        Padding(
                          padding: const EdgeInsets.only(top: 75, left: 3),
                          child: SvgPicture.asset(
                            Assets.vsImg,
                            width: 247.177,
                            height: 126.416,
                          ),
                        ),

                        /// Title & Back Button
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: scrHeight * .07,
                              left: scrWidth * UiUtils.hzMarginPct,
                              right: scrWidth * UiUtils.hzMarginPct,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: Navigator.of(context).pop,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 24.5,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                ),
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Bottom - Create/Join Container
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: ClipPath(
                      clipper: TopCurveClipper(),
                      child: Container(
                        width: size.width,
                        height: size.height * 0.4,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        color: Theme.of(context).colorScheme.surface,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Create Room Btn
                            CustomRoundedButton(
                              widthPercentage: context.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: showCreateRoomBottomSheet,
                              buttonTitle: context.tr('createRoom'),
                            ),
                            SizedBox(height: size.height * 0.025),

                            /// Join Room Btn
                            CustomRoundedButton(
                              widthPercentage: context.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: showJoinRoomBottomSheet,
                              buttonTitle: context.tr('joinRoom'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
