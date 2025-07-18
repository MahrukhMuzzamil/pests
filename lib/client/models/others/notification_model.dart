import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color backgroundColor;
  final String momentId;

  NotificationModel({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.backgroundColor,
    required this.momentId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      icon: _getIconFromString(data['icon']),
      backgroundColor: _getBackgroundColorFromIcon(data['icon']),
      momentId: data['momentId'] ?? '',
    );
  }

  static IconData _getIconFromString(String? iconString) {
    print(iconString);
    switch (iconString) {
      case 'notifications':
        return Icons.notifications;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'update':
        return Icons.update;
      case 'like':
        return Icons.thumb_up;
      case 'message':
        return Icons.message;
      case 'reply':
        return Icons.reply;
      case 'comment':
        return Icons.comment;
      case 'follower':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  static Color _getBackgroundColorFromIcon(String? iconString) {
    print(iconString);
    switch (iconString) {
      case 'notifications':
        return Colors.blueAccent;
      case 'info':
        return Colors.green;
      case 'warning':
        return Colors.red;
      case 'update':
        return Colors.orange;
      case 'like':
        return Colors.pink;
      case 'message':
        return Colors.lightBlue;
      case 'reply':
        return Colors.teal;
      case 'comment':
        return Colors.grey.shade300;
      case 'follower':
        return Colors.purple;
      default:
        return Colors.blueAccent;
    }
  }
}
