import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/waves_clipper.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class BattleInviteCard extends StatelessWidget {
  const BattleInviteCard({
    required this.categoryImage,
    required this.categoryName,
    required this.entryFee,
    required this.roomCode,
    required this.shareText,
    this.categoryEnabled = true,
    super.key,
  });

  final String categoryImage;
  final String categoryName;
  final int entryFee;
  final String roomCode;
  final String shareText;
  final bool categoryEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      height: 316,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),

          /// Share Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              shareText,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.5,
                color: colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(height: 14),

          /// RoomCode
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: context.primaryColor,
                strokeWidth: 2,
                dashPattern: const [3, 4],
                radius: const Radius.circular(8),
              ),
              child: Text(
                roomCode,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          /// Room Entry Fee
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              '${context.tr(entryFeesLbl)} : ${NumberFormat.compact().format(entryFee)} ${context.tr(coinsLbl)}',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),

          /// Room Category
          const Spacer(),
          ClipPath(
            clipper: const WavesClipper(waveCount: 9),
            child: Container(
              padding: const EdgeInsets.only(
                top: 42,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: categoryEnabled
                  ? Row(
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1),
                            child: QImage(
                              imageUrl: categoryImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(
                                categoryName,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 18,
                                  height: 1.2,
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                            ),
                            Text(
                              context.tr('quizCategory')!,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                color: colorScheme.onTertiary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(height: 54, width: double.maxFinite),
            ),
          ),
        ],
      ),
    );
  }
}
