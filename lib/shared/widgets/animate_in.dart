import 'package:flutter/material.dart';

class AnimateIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;
  final bool enableScale;

  const AnimateIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.beginOffset = const Offset(0, 0.06),
    this.beginScale = 0.98,
    this.enableScale = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final translated = Transform.translate(
          offset: Offset(
            beginOffset.dx * (1 - value) * 40,
            beginOffset.dy * (1 - value) * 40,
          ),
          child: child,
        );
        final scaled = enableScale
            ? Transform.scale(scale: beginScale + (1 - beginScale) * value, child: translated)
            : translated;
        return Opacity(opacity: value, child: scaled);
      },
    );
  }
}


