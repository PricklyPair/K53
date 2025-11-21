import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

sealed class RewardedAdState {}

class RewardedAdInitial extends RewardedAdState {}

class RewardedAdLoaded extends RewardedAdState {}

class RewardedAdLoadInProgress extends RewardedAdState {}

class RewardedAdFailure extends RewardedAdState {}

class RewardedAdCubit extends Cubit<RewardedAdState>
    with LevelPlayRewardedAdListener {
  RewardedAdCubit() : super(RewardedAdInitial());

  RewardedAd? _rewardedAd;
  late LevelPlayRewardedAd _ironSourceAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  final unityPlacementName = Platform.isIOS
      ? 'Rewarded_iOS'
      : 'Rewarded_Android';

  Future<void> _createGoogleRewardedAd(BuildContext context) async {
    await _rewardedAd?.dispose();
    await RewardedAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdFailedToLoad: (error) {
          log(error.message, name: 'Create Google Ads');
          emit(RewardedAdFailure());
        },
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          emit(RewardedAdLoaded());
        },
      ),
    );
  }

  Future<void> createUnityRewardsAd() async {
    await UnityAds.load(
      placementId: unityPlacementName,
      onComplete: (placementId) => emit(RewardedAdLoaded()),
      onFailed: (p, e, m) => emit(RewardedAdFailure()),
    );
  }

  Future<void> _createIronSourceAd(String adUnitId) async {
    _ironSourceAd = LevelPlayRewardedAd(adUnitId: adUnitId);
    _ironSourceAd.setListener(this);
    await _ironSourceAd.loadAd();
  }

  Future<void> createRewardedAd(BuildContext context) async {
    if (state is RewardedAdLoadInProgress || state is RewardedAdLoaded) {
      return; // Prevent duplicate loads
    }
    emit(RewardedAdLoadInProgress());

    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfigCubit.adsType == AdType.admob) {
        await _createGoogleRewardedAd(context);
      } else if (sysConfigCubit.adsType == AdType.unity) {
        await createUnityRewardsAd();
      } else if (sysConfigCubit.adsType == AdType.ironSource) {
        final adUnitId = sysConfigCubit.ironSourceRewardedAdId;
        if (adUnitId.isNotEmpty) {
          await _createIronSourceAd(adUnitId);
        } else {
          emit(RewardedAdFailure());
        }
      }
    }
  }

  Future<void> createDailyRewardAd(BuildContext context) async {
    emit(RewardedAdLoadInProgress());

    final sysConfig = context.read<SystemConfigCubit>();
    if (sysConfig.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfig.adsType == AdType.admob) {
        await _createGoogleRewardedAd(context);
      } else if (sysConfig.adsType == AdType.unity) {
        await createUnityRewardsAd();
      } else if (sysConfig.adsType == AdType.ironSource) {
        final adUnitId = sysConfig.ironSourceRewardedAdId;
        if (adUnitId.isNotEmpty) {
          await _createIronSourceAd(adUnitId);
        } else {
          emit(RewardedAdFailure());
        }
      }
    }
  }

  Future<void> showDailyAd({required BuildContext context}) async {
    final sysConfigCubit = context.read<SystemConfigCubit>();
    final userDetails = context.read<UserDetailsCubit>();

    if (sysConfigCubit.isAdsEnable && state is RewardedAdLoaded) {
      ///
      if (sysConfigCubit.adsType == AdType.admob) {
        _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) async {
            await createDailyRewardAd(context);
          },
          onAdFailedToShowFullScreenContent: (ad, error) async {
            await ad.dispose();
            emit(RewardedAdFailure());
          },
        );
        await rewardedAd?.show(
          onUserEarnedReward: (_, _) {
            userDetails
                .watchedDailyAd()
                .then((_) async {
                  await context.read<UserDetailsCubit>().fetchUserDetails();

                  if (!context.mounted) return;

                  context.showSnack(
                    "${context.tr("earnedLbl")!} "
                    '${sysConfigCubit.coinsPerDailyAdView} '
                    "${context.tr("coinsLbl")!}",
                  );
                })
                .catchError((dynamic e) {
                  if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                    context.showSnack(
                      context.tr('dailyAdsLimitExceeded')!,
                    );
                  }
                });
          },
        );
      } else if (sysConfigCubit.adsType == AdType.unity) {
        await UnityAds.showVideoAd(
          placementId: unityPlacementName,
          onComplete: (_) async {
            await userDetails
                .watchedDailyAd()
                .then((_) async {
                  await context.read<UserDetailsCubit>().fetchUserDetails();

                  if (!context.mounted) return;

                  context.showSnack(
                    "${context.tr("earnedLbl")!} "
                    '${sysConfigCubit.coinsPerDailyAdView} '
                    "${context.tr("coinsLbl")!}",
                  );
                })
                .catchError((dynamic e) {
                  if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                    context.showSnack(
                      context.tr('dailyAdsLimitExceeded')!,
                    );
                  }
                });
            log('Watched Daily Ad', name: 'Admob Ads');

            return createDailyRewardAd(context);
          },
        );
      } else if (sysConfigCubit.adsType == AdType.ironSource) {
        if (await _ironSourceAd.isAdReady()) {
          await _ironSourceAd.showAd().then((_) async {
            await userDetails
                .watchedDailyAd()
                .then((_) async {
                  await context.read<UserDetailsCubit>().fetchUserDetails();

                  if (!context.mounted) return;

                  context.showSnack(
                    "${context.tr("earnedLbl")!} "
                    '${sysConfigCubit.coinsPerDailyAdView} '
                    "${context.tr("coinsLbl")!}",
                  );
                })
                .catchError((dynamic e) {
                  if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                    context.showSnack(
                      context.tr('dailyAdsLimitExceeded')!,
                    );
                  }
                });
            log('Watched Daily Ad', name: 'Admob Ads');

            await createDailyRewardAd(context);
          });
        }
      }
    } else if (state is RewardedAdFailure) {
      await createDailyRewardAd(context);
    } else if (state is RewardedAdInitial) {
      await createDailyRewardAd(context);
    }
  }

  Future<void> showAd({
    required VoidCallback onAdDismissedCallback,
    required BuildContext context,
  }) async {
    //if ads is enable
    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (state is RewardedAdLoaded) {
        //if google ad is enable
        if (sysConfigCubit.adsType == AdType.admob) {
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissedCallback();
              createRewardedAd(context);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              //need to show this reason to user
              emit(RewardedAdFailure());
              createRewardedAd(context);
            },
          );
          rewardedAd?.show(onUserEarnedReward: (_, _) => {});
        } else if (sysConfigCubit.adsType == AdType.unity) {
          UnityAds.showVideoAd(
            placementId: unityPlacementName,
            onComplete: (placementId) {
              onAdDismissedCallback();
              createRewardedAd(context);
            },
            onFailed: (placementId, error, message) =>
                log('Video Ad $placementId failed: $error $message'),
            onStart: (placementId) => log('Video Ad $placementId started'),
            onClick: (placementId) => log('Video Ad $placementId click'),
          );
        } else if (sysConfigCubit.adsType == AdType.ironSource) {
          if (await _ironSourceAd.isAdReady()) {
            await _ironSourceAd.showAd().then((_) async {
              onAdDismissedCallback();
              await createDailyRewardAd(context);
            });
          }
        }
      } else if (state is RewardedAdFailure) {
        //create reward ad if ad is not loaded successfully
        createRewardedAd(context);
      } else if (state is RewardedAdInitial) {
        //create ad if not initialized yet
        createRewardedAd(context);
      }
    }
  }

  @override
  Future<void> close() async {
    await _rewardedAd?.dispose();
    return super.close();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    log('onAdClicked $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    log('onAdClosed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    log('onAdDisplayFailed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    log('onAdDisplayed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    log('onAdInfoChanged $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    emit(RewardedAdFailure());
    log('onAdLoadFailed', name: 'LevelPlay', error: error);
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    emit(RewardedAdLoaded());
    log('onAdLoaded $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    log('onAdRewarded $adInfo', name: 'LevelPlay');
  }
}
