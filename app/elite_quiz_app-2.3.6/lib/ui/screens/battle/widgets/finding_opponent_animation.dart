import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_image.dart';
import 'package:flutterquiz/core/constants/assets_constants.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/utils/extensions.dart';

class FindingOpponentAnimation extends StatefulWidget {
  const FindingOpponentAnimation({
    required this.animationController,
    super.key,
  });

  final AnimationController animationController;

  @override
  State<FindingOpponentAnimation> createState() =>
      _FindingOpponentAnimationState();
}

class _FindingOpponentAnimationState extends State<FindingOpponentAnimation>
    with SingleTickerProviderStateMixin {
  late final List<String> _avatars = context
      .read<SystemConfigCubit>()
      .defaultAvatarImages;

  late final Animation<int> _animation = IntTween(
    begin: 0,
    end: _avatars.length - 1,
  ).animate(widget.animationController);

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).primaryColor,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        /// Circle Background
        Container(decoration: boxDecoration, height: context.height * .15),

        /// Default Avatars
        Container(
          decoration: boxDecoration,
          height: context.height * .14,
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: widget.animationController,
            builder: (_, _) => QImage(
              imageUrl: Assets.profile(_avatars[_animation.value]),
              fit: BoxFit.contain,
              height: context.height * .14,
              width: context.height * .14,
            ),
          ),
        ),
      ],
    );
  }
}
