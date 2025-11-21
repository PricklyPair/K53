import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/bottom_nav/models/nav_tab.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/core.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.navTabs,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<NavTab> navTabs;
  final int currentIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight + 26,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(blurRadius: 16, spreadRadius: 2, color: Colors.black12),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navTabs.length, (index) {
          final isSelected = currentIndex == index;
          final navTab = navTabs[index];
          final color = isSelected
              ? context.primaryColor
              : context.primaryTextColor.withValues(alpha: .8);

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onTap(index),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 60,
                  minHeight: 48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: QImage(
                          imageUrl: isSelected
                              ? navTab.activeIcon
                              : navTab.icon,
                          color: color,
                        ),
                      ),
                    ),
                    const Flexible(child: SizedBox(height: 4)),
                    Flexible(
                      child: Text(
                        context.tr(navTab.title)!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.15,
                          color: color,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
