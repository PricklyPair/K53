import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

class SubcategoriesLevelChip extends StatefulWidget {
  const SubcategoriesLevelChip({
    required this.isLevelUnlocked,
    required this.currIndex,
    required this.isLevelPlayed,
    super.key,
    this.width = 100,
  });

  final bool isLevelUnlocked;
  final bool isLevelPlayed;
  final int currIndex;
  final double width;

  @override
  State<SubcategoriesLevelChip> createState() => _SubcategoriesLevelChipState();
}

class _SubcategoriesLevelChipState extends State<SubcategoriesLevelChip> {
  IconData? icon;
  Color? iconColor;
  Color? textColor;
  Color? backgroundColor;

  @override
  void didChangeDependencies() {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isLevelPlayed) {
      icon = Icons.check_circle_rounded;
      iconColor = Theme.of(context).primaryColor;
      textColor = colorScheme.onTertiary;
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: .2);
    } else {
      if (widget.isLevelUnlocked) {
        icon = Icons.lock_open_rounded;
        iconColor = colorScheme.onTertiary;
        textColor = colorScheme.onTertiary;
        backgroundColor = Theme.of(context).scaffoldBackgroundColor;
      } else {
        icon = Icons.lock_rounded;
        iconColor = colorScheme.onTertiary.withValues(alpha: .3);
        textColor = colorScheme.onTertiary.withValues(alpha: .3);
        backgroundColor = colorScheme.onTertiary.withValues(alpha: .1);
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${context.tr("levelLbl")!} ${widget.currIndex + 1}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeights.regular,
              ),
            ),
          ),
          Icon(icon, size: 15, color: iconColor),
        ],
      ),
    );
  }
}
