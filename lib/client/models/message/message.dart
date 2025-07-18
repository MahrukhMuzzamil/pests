import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String? message;
  String receiverId;
  String senderEmail;
  String senderId;
  Timestamp timeStamp;
  bool isRead;
  String? mediaUrl;

  Message({
    this.message,
    required this.receiverId,
    required this.senderEmail,
    required this.senderId,
    required this.timeStamp,
    required this.isRead,
    this.mediaUrl,
    required this.id
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'receiverId': receiverId,
      'senderEmail': senderEmail,
      'senderId': senderId,
      'timeStamp': timeStamp,
      'isRead': isRead,
      'mediaUrl': mediaUrl,
      'id':id
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      message: map['message'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      senderId: map['senderId'] ?? '',
      timeStamp: map['timeStamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
      mediaUrl: map['mediaUrl'],
      id:map['id']
    );
  }
}
