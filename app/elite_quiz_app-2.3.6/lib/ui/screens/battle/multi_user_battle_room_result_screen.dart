import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/models/user_battle_room_details.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

final class MultiUserBattleRoomResultArgs extends RouteArgs {
  MultiUserBattleRoomResultArgs({required this.joinedUsersCount});

  final int joinedUsersCount;
}

class MultiUserBattleRoomResultScreen extends StatefulWidget {
  const MultiUserBattleRoomResultScreen({
    required this.args,
    super.key,
  });

  final MultiUserBattleRoomResultArgs args;

  @override
  State<MultiUserBattleRoomResultScreen> createState() =>
      _MultiUserBattleRoomResultScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<MultiUserBattleRoomResultArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SetCoinScoreCubit(),
        child: MultiUserBattleRoomResultScreen(args: args),
      ),
    );
  }
}

class _MultiUserBattleRoomResultScreenState
    extends State<MultiUserBattleRoomResultScreen> {
  List<Map<String, dynamic>> usersWithRank = [];

  late final BattleRoom battleRoom = context
      .read<MultiUserBattleRoomCubit>()
      .battleRoom!;
  late final int totalQuestions = context
      .read<MultiUserBattleRoomCubit>()
      .getQuestions()
      .length;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
    _updateResult();
  }

  Future<void> _updateResult() async {
    await context.read<SetCoinScoreCubit>().setCoinScore(
      quizType: '1.5', // quiz type is 1.5 for group battle
      playedQuestions: {
        'user1_id': ?battleRoom.user1!.uid.isEmpty
            ? '0'
            : battleRoom.user1?.uid,
        'user2_id': ?battleRoom.user2!.uid.isEmpty
            ? '0'
            : battleRoom.user2?.uid,
        'user3_id': ?battleRoom.user3!.uid.isEmpty
            ? '0'
            : battleRoom.user3?.uid,
        'user4_id': battleRoom.user4!.uid.isEmpty ? '0' : battleRoom.user4?.uid,
        'user1_data': ?battleRoom.user1?.answers,
        'user2_data': ?battleRoom.user2?.answers,
        'user3_data': ?battleRoom.user3?.answers,
        'user4_data': ?battleRoom.user4?.answers,
      },
      joinedUsersCount: widget.args.joinedUsersCount,
      matchId: battleRoom.roomCode,
    );
  }

  final _rankImages = <String>[
    Assets.rank1,
    Assets.rank2,
    Assets.rank3,
    Assets.rank4,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        roundedAppBar: false,
        title: Text(context.tr('groupBattleResult')!),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: context.height * .7,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: context.height * UiUtils.hzMarginPct,
                vertical: 10,
              ),
              child: BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
                listener: (context, state) {
                  if (state is SetCoinScoreSuccess) {
                    final currUserId = context
                        .read<UserDetailsCubit>()
                        .userId();

                    // Delete room
                    if (state.userRanks.first.userId == currUserId) {
                      context
                          .read<MultiUserBattleRoomCubit>()
                          .deleteMultiUserBattleRoom();
                    }
                  }
                },
                builder: (context, state) {
                  if (state is SetCoinScoreSuccess) {
                    final usersWithRank = state.userRanks;
                    final userDetails = usersWithRank
                        .map((e) => battleRoom.userById(e.userId))
                        .toList();
                    final topRank = usersWithRank.first;
                    final topRankDetails = userDetails.first!;

                    return Column(
                      children: [
                        const SizedBox(height: 36),

                        /// Top Rank
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                QImage.circular(
                                  width: 90,
                                  height: 90,
                                  imageUrl: topRankDetails.profileUrl,
                                ),
                                const QImage(
                                  imageUrl: Assets.hexagonFrame,
                                  width: 115,
                                  height: 115,
                                  fit: BoxFit.contain,
                                ),
                                PositionedDirectional(
                                  bottom: 10,
                                  end: 10,
                                  child: QImage(
                                    imageUrl: _rankImages[topRank.rank - 1],
                                    height: 36,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              topRankDetails.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeights.bold,
                                fontSize: 16,
                                color: context.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  QImage(
                                    imageUrl: Assets.correct,
                                    height: 16,
                                    color: context.primaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${topRankDetails.correctAnswers}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeights.bold,
                                      color: context.primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  QImage(
                                    imageUrl: Assets.wrong,
                                    height: 16,
                                    color: context.primaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${totalQuestions - topRankDetails.correctAnswers}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeights.bold,
                                      color: context.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(usersWithRank.length - 1, (i) {
                          final rank = usersWithRank[i + 1];
                          final user = userDetails[i + 1]!;

                          return _buildOtherRankItem(user, rank);
                        }),
                      ],
                    );
                  }

                  if (state is SetCoinScoreFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: true,
                        errorMessageColor: context.primaryColor,
                        errorMessage: convertErrorCodeToLanguageKey(
                          state.error,
                        ),
                        onTapRetry: () async {
                          await _updateResult();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }

                  return const Center(child: CircularProgressContainer());
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: usersWithRank.length == 4 ? 20 : 50.0,
              ),
              //if total 4 user than padding will be 20 else 50
              child: CustomRoundedButton(
                widthPercentage: 0.85,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('homeBtn'),
                radius: 5,
                showBorder: false,
                fontWeight: FontWeight.bold,
                height: 40,
                elevation: 5,
                titleColor: Theme.of(context).colorScheme.surface,
                onTap: () {
                  context.pushNamedAndRemoveUntil(
                    Routes.home,
                    predicate: (_) => false,
                  );
                },
                textSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherRankItem(UserBattleRoomDetails user, BattleUserRank rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              QImage.circular(
                width: 50,
                height: 50,
                imageUrl: user.profileUrl,
              ),
              const QImage(
                imageUrl: Assets.hexagonFrame,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: QImage(
                  imageUrl: _rankImages[rank.rank - 1],
                  height: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeights.bold,
                color: context.primaryTextColor,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                QImage(
                  imageUrl: Assets.correct,
                  height: 16,
                  color: context.primaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.correctAnswers}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.bold,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                QImage(
                  imageUrl: Assets.wrong,
                  height: 16,
                  color: context.primaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${totalQuestions - rank.correctAnswers}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.bold,
                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
