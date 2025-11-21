import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/custom_back_button.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const ReferAndEarnScreen());
  }

  @override
  Widget build(BuildContext context) {
    final referCode = context
        .read<UserDetailsCubit>()
        .getUserProfile()
        .referCode!;
    final sysConfig = context.read<SystemConfigCubit>();

    final referText =
        '${context.tr('referText1')} ${sysConfig.refereeEarnCoin} ${context.tr('referText2')} $referCode\n ${context.tr('referText3')} ${sysConfig.appUrl}';

    final size = context;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primaryColor,
        leading: QBackButton(color: context.surfaceColor),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: size.height * .8,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size.height * .65,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  width: size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr(referAndEarn)!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.surfaceColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * .01),
                      SizedBox(
                        height: size.height * 0.2,
                        child: SvgPicture.asset(Assets.referFriends),
                      ),

                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                Assets.coin,
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                sysConfig.referrerEarnCoin,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 32,
                                  color: context.surfaceColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            context.tr('getFreeCoins')!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeights.bold,
                              color: context.surfaceColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * .01),

                      ///
                      SizedBox(
                        width: size.width * .8,
                        child: Text(
                          "${context.tr("referFrdLbl")!} ${context.tr(youWillGetKey)!}"
                          ' ${sysConfig.referrerEarnCoin} ${context.tr(coinsLbl)!.toLowerCase()}.'
                          '\n${context.tr(theyWillGetKey)!} ${sysConfig.refereeEarnCoin} '
                          '${context.tr(coinsLbl)!.toLowerCase()}.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: context.surfaceColor,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .04),

                      /// your referral code
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          strokeWidth: 3,
                          padding: EdgeInsets.zero,
                          dashPattern: const [6, 4],
                          color: context.surfaceColor.withValues(alpha: .5),
                          radius: const Radius.circular(8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: context.primaryTextColor.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 25),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr('yourRefCOdeLbl')!,
                                    style: TextStyle(
                                      color: context.surfaceColor.withValues(
                                        alpha: .8,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeights.semiBold,
                                    ),
                                  ),
                                  Text(
                                    referCode,
                                    style: TextStyle(
                                      color: context.surfaceColor,
                                      fontSize: 18,
                                      fontWeight: FontWeights.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              VerticalDivider(
                                color: context.surfaceColor.withValues(
                                  alpha: .4,
                                ),
                                indent: 10,
                                endIndent: 10,
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: referCode),
                                  );
                                  context.showSnack(
                                    context.tr('referCodeCopyMsg')!,
                                  );
                                },
                                child: Text(
                                  context.tr('copyCodeLbl')!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeights.semiBold,
                                    color: context.surfaceColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .03),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: context.surfaceColor.withValues(alpha: .8),
                          ),
                          children: [
                            TextSpan(text: '${context.tr("howWorksLbl")!} '),
                            TextSpan(
                              text: context.tr('steps'),
                              style: TextStyle(
                                color: context.surfaceColor,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          UiUtils.bottomSheetTopRadius,
                                    ),
                                    builder: (_) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color:
                                              context.scaffoldBackgroundColor,
                                          borderRadius:
                                              UiUtils.bottomSheetTopRadius,
                                        ),
                                        height: size.height * .7,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              size.width * UiUtils.hzMarginPct +
                                              10,
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(height: 75),
                                                  _buildStep(
                                                    context,
                                                    'step_1',
                                                    'step_1_title',
                                                    'step_1_desc',
                                                  ),
                                                  _vtDivider,
                                                  _buildStep(
                                                    context,
                                                    'step_2',
                                                    'step_2_title',
                                                    'step_2_desc',
                                                  ),
                                                  _vtDivider,
                                                  _buildStep(
                                                    context,
                                                    'step_3',
                                                    'step_3_title',
                                                    'step_3_desc',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 32,
                                                ),
                                                child: Builder(
                                                  builder: (context) {
                                                    return CustomRoundedButton(
                                                      onTap: () =>
                                                          UiUtils.share(
                                                            referCode,
                                                            context: context,
                                                          ),
                                                      widthPercentage: 1,
                                                      backgroundColor:
                                                          context.primaryColor,
                                                      buttonTitle: context.tr(
                                                        'inviteFriendsLbl',
                                                      ),
                                                      radius: 8,
                                                      showBorder: false,
                                                      height: 58,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Share Now
              Align(
                alignment: Alignment.bottomCenter,
                child: Builder(
                  builder: (context) {
                    return CustomRoundedButton(
                      onTap: () => UiUtils.share(referText, context: context),
                      widthPercentage: .9,
                      backgroundColor: context.primaryColor,
                      titleColor: context.surfaceColor,
                      buttonTitle: context.tr('shareNowLbl'),
                      radius: 8,
                      textSize: 18,
                      showBorder: false,
                      fontWeight: FontWeights.semiBold,
                      height: 60,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _vtDivider = Row(
    children: [
      SizedBox(width: 22),
      SizedBox(
        width: 2,
        height: 68,
        child: ColoredBox(color: Color(0xFF22C274)),
      ),
      Spacer(),
    ],
  );

  Row _buildStep(BuildContext context, String step, String title, String desc) {
    final step0 = context.tr(step)!;
    final title0 = context.tr(title)!;
    final desc0 = context.tr(desc)!;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surfaceColor,
            border: Border.all(color: const Color(0xff22C274), width: 2),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step0,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeights.bold,
                color: context.primaryTextColor,
              ),
            ),
            Text(
              title0,
              style: TextStyle(
                fontWeight: FontWeights.bold,
                fontSize: 22,
                color: context.primaryTextColor,
              ),
            ),
            Text(
              desc0,
              style: TextStyle(
                fontWeight: FontWeights.regular,
                fontSize: 16,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
