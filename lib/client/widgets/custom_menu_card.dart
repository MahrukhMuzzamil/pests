import 'package:flutter/material.dart';
import 'animated_button.dart';

class CustomMenuCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final IconData icon;

  const CustomMenuCard({
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.15),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w200,fontSize: 14)),
        ],
      ),
    );
  }
}
