
import 'package:flutter/material.dart';

import '../../../../../../client/widgets/custom_button.dart';

class SupportContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String contactInfo;
  final VoidCallback onPressed;

  const SupportContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.contactInfo,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              contactInfo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              height: 40,
              backgroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 15,color: Colors.white),
              onPressed: onPressed, text: title, isLoading: false, tag: '',
            ),
          ],
        ),
      ),
    );
  }
}