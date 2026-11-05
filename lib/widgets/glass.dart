import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Frosted glass panel used for chrome floating over paintings.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = EdgeInsets.zero,
    this.tint = 0.28,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: LumenColors.imageInk.withValues(alpha: tint),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}
