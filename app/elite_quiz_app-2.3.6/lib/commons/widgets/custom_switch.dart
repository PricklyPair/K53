import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({required this.value, super.key, this.onChanged});

  final bool value;

  ///
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 36,
      child: Transform.scale(
        scale: .8,
        alignment: AlignmentDirectional.center,
        child: Switch(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeThumbColor: context.primaryColor,
          inactiveTrackColor: context.primaryTextColor.withValues(alpha: .3),
          inactiveThumbColor: context.primaryTextColor.withValues(alpha: .8),
          value: value,
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.primaryColor;
            }
            return context.primaryTextColor.withValues(alpha: .8);
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
