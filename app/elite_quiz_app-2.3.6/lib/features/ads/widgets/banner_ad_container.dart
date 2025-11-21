import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/blocs/banner_ad_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';

class BannerAdContainer extends StatefulWidget {
  const BannerAdContainer({super.key});

  @override
  State<BannerAdContainer> createState() => _BannerAdContainer();
}

class _BannerAdContainer extends State<BannerAdContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<BannerAdCubit>().initBannerAd(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<SystemConfigCubit>();
    return BlocBuilder<BannerAdCubit, BannerAdState>(
      builder: (context, state) {
        if (config.isAdsEnable && state == BannerAdState.loaded) {
          if (config.adsType == AdType.admob) {
            final bannerAd = context.read<BannerAdCubit>().googleBannerAd;
            if (bannerAd != null) {
              return SizedBox(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              );
            }
          } else if (config.adsType == AdType.unity) {
            final unityBannerAd = context.read<BannerAdCubit>().unityBannerAd;
            if (unityBannerAd != null) {
              return SizedBox(
                height: unityBannerAd.size.height.toDouble(),
                width: unityBannerAd.size.width.toDouble(),
                child: unityBannerAd,
              );
            }
          } else if (config.adsType == AdType.ironSource) {
            final adKey = GlobalKey<LevelPlayBannerAdViewState>();
            final adSize = LevelPlayAdSize.BANNER;

            return Padding(
              padding: EdgeInsets.only(bottom: context.padding.bottom),
              child: SizedBox(
                width: adSize.width.toDouble(),
                height: adSize.height.toDouble(),
                child: LevelPlayBannerAdView(
                  key: adKey,
                  adUnitId: config.ironSourceBannerId,
                  adSize: adSize,
                  listener: _IronSourceBannerAdListener(),
                  onPlatformViewCreated: () async {
                    // Load the ad once the platform view is created
                    await adKey.currentState?.loadAd();
                  },
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _IronSourceBannerAdListener extends LevelPlayBannerAdViewListener {
  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    log('onAdClicked $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {
    log('onAdCollapsed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    log('onAdDisplayFailed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    log('onAdDisplayed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {
    log('onAdExpanded $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {
    log('onAdLeftApplication $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    log('onAdLoadFailed $error', name: 'LevelPlay');
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    log('onAdLoaded $adInfo', name: 'LevelPlay');
  }
}
