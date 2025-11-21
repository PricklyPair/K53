import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/extensions.dart';

class QuestionBackgroundCard extends StatelessWidget {
  const QuestionBackgroundCard({
    required this.opacity,
    required this.heightPercentage,
    required this.topMarginPercentage,
    required this.widthPercentage,
    super.key,
  });
  final double opacity;
  final double widthPercentage;
  final double topMarginPercentage;
  final double heightPercentage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: EdgeInsets.only(top: context.height * topMarginPercentage),
        width: context.width * widthPercentage,
        height: context.height * heightPercentage,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
