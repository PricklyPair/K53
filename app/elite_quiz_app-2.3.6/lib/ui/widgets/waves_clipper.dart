import 'package:flutter/material.dart';

class WavesClipper extends CustomClipper<Path> {
  const WavesClipper({this.waveCount = 5});

  final int waveCount;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, size.height * 0.2);

    final waveWidth = size.width / waveCount;
    final waveHeight = size.height * 0.1;

    for (var i = 0; i < waveCount; i++) {
      final startX = i * waveWidth;
      final endX = (i + 1) * waveWidth;

      path.quadraticBezierTo(
        startX + waveWidth / 2,
        size.height * 0.2 - waveHeight,
        endX,
        size.height * 0.2,
      );
    }

    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
