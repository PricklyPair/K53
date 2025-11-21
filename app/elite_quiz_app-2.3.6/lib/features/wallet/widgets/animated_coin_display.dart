import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';

/// Subtle animated coin display widget
/// Shows coin icon with smooth horizontal flip animation and counting number animation
final class AnimatedCoinDisplay extends StatefulWidget {
  const AnimatedCoinDisplay({
    required this.coins,
    super.key,
  });

  final String coins;

  @override
  State<AnimatedCoinDisplay> createState() => _AnimatedCoinDisplayState();
}

class _AnimatedCoinDisplayState extends State<AnimatedCoinDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  int _previousCoins = 0;

  @override
  void initState() {
    super.initState();
    _previousCoins = int.tryParse(widget.coins) ?? 0;

    // Looping animation: flip -> idle -> repeat
    // Total duration: 3.5 seconds for a complete cycle
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );
    unawaited(_controller.repeat()); // Loop continuously

    // Rotation animation (horizontal flip)
    _rotationAnimation = TweenSequence<double>([
      // Flip animation (0.0s to 0.6s)
      TweenSequenceItem(
        tween:
            Tween<double>(begin: 0, end: pi) // π radians = 180°
                .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 17, // ~17% of 3500ms = 600ms
      ),
      // Idle (0.6s to 3.5s)
      TweenSequenceItem(
        tween: ConstantTween<double>(pi),
        weight: 83, // ~83% of 3500ms = 2900ms
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedCoinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update previous coins for counter animation
    if (oldWidget.coins != widget.coins) {
      _previousCoins = int.tryParse(oldWidget.coins) ?? 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCoins = int.tryParse(widget.coins) ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated coin with smooth horizontal flip
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(_rotationAnimation.value),
              child: child,
            );
          },
          child: const QImage(
            imageUrl: Assets.coin,
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 10),

        // Animated number counter
        TweenAnimationBuilder<int>(
          tween: IntTween(
            begin: _previousCoins,
            end: currentCoins,
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              value.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
      ],
    );
  }
}
