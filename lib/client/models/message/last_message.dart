import 'package:cloud_firestore/cloud_firestore.dart';

class LastMessageData {
  final String message;
  final DateTime? timestamp;
  final String senderId;
  final int count;

  LastMessageData({
    required this.message,
    required this.timestamp,
    required this.senderId,
    required this.count,
  });

  factory LastMessageData.fromMap(Map<String, dynamic> data) {
    return LastMessageData(
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      senderId: data['senderId'] ?? '',
      count: data['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'senderId': senderId,
      'count': count,
    };
  }
}
