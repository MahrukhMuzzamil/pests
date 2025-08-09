import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  final double size;
  final EdgeInsetsGeometry? padding;

  const VerifiedBadge({
    super.key,
    required this.isVerified,
    this.size = 18,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Icon(Icons.verified, color: Colors.blue, size: size),
    );
  }
}


