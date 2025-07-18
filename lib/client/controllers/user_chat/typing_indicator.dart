import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildDot(_controller),
        const SizedBox(width: 4),
        _buildDot(_controller),
        const SizedBox(width: 4),
        _buildDot(_controller),
      ],
    );
  }

  Widget _buildDot(AnimationController controller) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
