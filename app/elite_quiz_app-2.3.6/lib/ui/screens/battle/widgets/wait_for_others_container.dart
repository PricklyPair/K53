import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/question_background_card.dart';
import 'package:flutterquiz/utils/extensions.dart';

class WaitForOthersContainer extends StatelessWidget {
  const WaitForOthersContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.padding.top),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const QuestionBackgroundCard(
            heightPercentage: .74,
            opacity: 0.7,
            topMarginPercentage: 0.05,
            widthPercentage: 0.65,
          ),
          const QuestionBackgroundCard(
            heightPercentage: .74,
            opacity: 0.85,
            topMarginPercentage: 0.03,
            widthPercentage: 0.75,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: context.width * 0.85,
            height: context.height * .785,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(child: Text(context.tr('waitOtherComplete')!)),
          ),
        ],
      ),
    );
  }
}
