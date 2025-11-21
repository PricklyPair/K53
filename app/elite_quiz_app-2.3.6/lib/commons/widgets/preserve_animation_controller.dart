import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A custom TickerProvider that ensures animations run at normal speed
/// even when the device has "Reduce animations" or "Disable animations" enabled.
///
/// This is particularly useful for timers and critical animations that need
/// to maintain their timing regardless of system accessibility settings.
final class _PreserveAnimationsTickerProvider extends TickerProvider {
  const _PreserveAnimationsTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// An AnimationController that preserves its timing even when the device
/// has animations disabled or reduced through accessibility settings.
///
/// This controller is designed to solve the common issue where timers
/// run super fast when users have "Reduce animations" enabled, which
/// can break quiz timers, countdown widgets, and other time-critical animations.
///
/// **When to use:**
/// - Quiz timers that must maintain accurate timing
/// - Countdown widgets
/// - Progress indicators with specific durations
/// - Any animation where timing accuracy is more important than respecting accessibility settings
///
/// **When NOT to use:**
/// - Decorative animations (use regular AnimationController)
/// - UI transitions that should respect accessibility settings
/// - Animations that are purely for visual enhancement
///
/// **Example usage:**
/// ```dart
/// late final timerController = PreserveAnimationController(
///   duration: Duration(seconds: 60),
///   reverseDuration: Duration(seconds: 5),
/// );
/// ```
class PreserveAnimationController extends AnimationController {
  /// Creates an AnimationController that preserves its timing regardless
  /// of system animation settings.
  ///
  /// All parameters work the same as [AnimationController] except
  /// [animationBehavior] which is automatically configured to preserve timing.
  PreserveAnimationController({
    super.value,
    super.duration,
    super.reverseDuration,
    super.debugLabel,
    super.lowerBound,
    super.upperBound,
  }) : super(
         vsync: const _PreserveAnimationsTickerProvider(),
         animationBehavior: AnimationBehavior.preserve,
       );
}
