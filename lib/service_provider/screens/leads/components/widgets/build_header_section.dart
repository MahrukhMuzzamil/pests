import 'package:flutter/material.dart';

Widget buildHeader(ThemeData theme, String name, String date, String status, bool isShown) {
  Color statusColor;
  Icon statusIcon;

  // Determine the status color and icon
  switch (status.toLowerCase()) {
    case 'completed':
      statusColor = Colors.green;
      statusIcon = const Icon(Icons.check_circle, color: Colors.white,size: 19,);
      break;
    case 'pending':
      statusColor = Colors.grey;
      statusIcon = const Icon(Icons.circle, color: Colors.red,size: 19,);
      break;
    case 'hired':
      statusColor = Colors.blue;
      statusIcon = const Icon(Icons.thumb_up, color: Colors.white,size: 19,);
      break;
    case 'rejected':
      statusColor = Colors.red;
      statusIcon = const Icon(Icons.cancel, color: Colors.white,size: 19,);
      break;
    default:
      statusColor = Colors.blue;
      statusIcon = const Icon(Icons.help, color: Colors.white,size: 19,);
  }

  return Row(
    children: [
      CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          (name.isNotEmpty ? name.substring(0, 1) : '?').toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      if (isShown)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: statusColor,
          ),
          child: Row(
            children: [
              statusIcon,
              const SizedBox(width: 5),
              Text(
                status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
