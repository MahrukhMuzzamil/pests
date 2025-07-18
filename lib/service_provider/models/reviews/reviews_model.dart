import 'package:cloud_firestore/cloud_firestore.dart';

class Reviews {
  final String reviewUserId;
  final String reviewUserText;
  final double reviewUserRating;
  final String reviewUserName;
  String? serviceProviderReply;
  final DateTime reviewDate;
  final String leadId;
  final String reviewId;
  final String serviceProviderId;

  Reviews({
    required this.reviewUserId,
    required this.reviewUserText,
    required this.reviewUserRating,
    required this.reviewUserName,
    this.serviceProviderReply,
    required this.serviceProviderId,
    required this.reviewDate,
    required this.leadId,
    required this.reviewId,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewUserId': reviewUserId,
      'reviewUserText': reviewUserText,
      'reviewUserRating': reviewUserRating,
      'reviewUserName': reviewUserName,
      'serviceProviderReply': serviceProviderReply,
      'serviceProviderId': serviceProviderId,
      'reviewDate': reviewDate.toIso8601String(),
      'leadId': leadId,
      'reviewId': reviewId,
    };
  }

  // Create a Review object from Firestore data
  factory Reviews.fromMap(Map<String, dynamic> map) {
    return Reviews(
      reviewUserId: map['reviewUserId'] as String,
      serviceProviderId: map['serviceProviderId'] as String,
      reviewUserText: map['reviewUserText'] as String,
      reviewUserRating: (map['reviewUserRating'] as num).toDouble(),
      reviewUserName: map['reviewUserName'] as String,
      serviceProviderReply: map['serviceProviderReply'] as String?,
      reviewDate: map['reviewDate'] != null
          ? (map['reviewDate'] is String
          ? DateTime.parse(map['reviewDate'] as String)
          : (map['reviewDate'] as Timestamp).toDate())
          : DateTime.now(),
      leadId: map['leadId'] as String,
      reviewId: map['reviewId'] as String,
    );
  }
}
