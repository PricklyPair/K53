import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final class FunAndLearnScreenArgs extends RouteArgs {
  const FunAndLearnScreenArgs({
    required this.categoryId,
    required this.comprehension,
    required this.isPremiumCategory,
    this.subcategoryId,
  });

  final String categoryId;
  final String? subcategoryId;
  final Comprehension comprehension;
  final bool isPremiumCategory;
}

class FunAndLearnScreen extends StatefulWidget {
  const FunAndLearnScreen({required this.args, super.key});

  final FunAndLearnScreenArgs args;

  @override
  State<FunAndLearnScreen> createState() => _FunAndLearnScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<FunAndLearnScreenArgs>();

    return CupertinoPageRoute(builder: (_) => FunAndLearnScreen(args: args));
  }
}

class _FunAndLearnScreen extends State<FunAndLearnScreen> {
  late final Comprehension _comprehension = widget.args.comprehension;

  late final _ytController = YoutubePlayerController(
    initialVideoId: _comprehension.contentData,
    flags: const YoutubePlayerFlags(autoPlay: false),
  );

  @override
  void dispose() {
    super.dispose();
    _ytController.dispose();
  }

  Future<void> navigateToQuestionScreen() async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.quiz,
      arguments: {
        'numberOfPlayer': 1,
        'quizType': QuizTypes.funAndLearn,
        'comprehension': _comprehension,
        'isPremiumCategory': widget.args.isPremiumCategory,
        'categoryId': widget.args.categoryId,
        'subcategoryId': widget.args.subcategoryId,
      },
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30,
        left: context.width * UiUtils.hzMarginPct,
        right: context.width * UiUtils.hzMarginPct,
      ),
      child: CustomRoundedButton(
        widthPercentage: context.width,
        backgroundColor: context.primaryColor,
        buttonTitle: context.tr(letsStart),
        radius: 8,
        onTap: navigateToQuestionScreen,
        titleColor: context.surfaceColor,
        showBorder: false,
        height: 58,
        elevation: 5,
        textSize: 18,
        fontWeight: FontWeights.semiBold,
      ),
    );
  }

  bool showFullPdf = false;
  bool ytFullScreen = false;

  Widget _buildParagraph(Widget player) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      height: context.height * .75,
      margin: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;

          return SingleChildScrollView(
            physics: showFullPdf
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                if (_comprehension.contentType == ContentType.yt &&
                    _comprehension.contentData.isNotEmpty)
                  player,
                if (_comprehension.contentType == ContentType.pdf &&
                    _comprehension.contentData.isNotEmpty) ...[
                  SizedBox(
                    height: maxHeight * (showFullPdf ? .92 : 0.3),
                    child: const PDF(
                      swipeHorizontal: true,
                      fitPolicy: FitPolicy.BOTH,
                    ).fromUrl(_comprehension.contentData),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: maxHeight * .08,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => showFullPdf = !showFullPdf),
                      child: Text(
                        context.tr(showFullPdf ? 'showLess' : 'showFull')!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.labelLarge?.copyWith(
                          color: context.primaryTextColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_comprehension.detail.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  HtmlWidget(
                    _comprehension.detail,
                    onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                    onLoadingBuilder: (_, _, _) =>
                        const CircularProgressContainer(),
                    textStyle: TextStyle(
                      color: context.primaryTextColor,
                      fontWeight: FontWeights.regular,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController,
        progressIndicatorColor: context.primaryColor,
        progressColors: ProgressBarColors(
          playedColor: context.primaryColor,
          bufferedColor: context.primaryTextColor.withValues(alpha: .5),
          backgroundColor: context.surfaceColor.withValues(alpha: .5),
          handleColor: context.primaryColor,
        ),
      ),
      onExitFullScreen: () {
        unawaited(
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
        );
      },
      builder: (_, player) {
        return Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            title: Text(_comprehension.title),
          ),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _buildParagraph(player),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildStartButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
