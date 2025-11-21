import 'package:flutter/material.dart';
import 'package:flutterquiz/core/constants/assets_constants.dart';

class UserFoundMapContainer extends StatefulWidget {
  const UserFoundMapContainer({super.key});

  @override
  State<UserFoundMapContainer> createState() => _UserFoundMapContainerState();
}

class _UserFoundMapContainerState extends State<UserFoundMapContainer> {
  late double scale = 1.275;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        scale = 1.0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transformAlignment: Alignment.center,
      transform: Matrix4.identity()..scaleByDouble(scale, scale, scale, 1),
      duration: const Duration(milliseconds: 300),
      child: Image.asset(Assets.mapFinded, fit: BoxFit.cover),
    );
  }
}
