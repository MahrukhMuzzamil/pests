import 'package:cloud_firestore/cloud_firestore.dart';

class CustomOffer {
  final String id;
  final String providerId;
  final String clientId;
  final String description;
  final double totalPrice;
  final String timeline;
  final String feeType; // e.g., 'per visit', 'one-time'
  final double commissionPercent;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  CustomOffer({
    required this.id,
    required this.providerId,
    required this.clientId,
    required this.description,
    required this.totalPrice,
    required this.timeline,
    required this.feeType,
    required this.commissionPercent,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerId': providerId,
    'clientId': clientId,
    'description': description,
    'totalPrice': totalPrice,
    'timeline': timeline,
    'feeType': feeType,
    'commissionPercent': commissionPercent,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomOffer.fromMap(Map<String, dynamic> map) => CustomOffer(
    id: map['id'],
    providerId: map['providerId'],
    clientId: map['clientId'],
    description: map['description'],
    totalPrice: (map['totalPrice'] as num).toDouble(),
    timeline: map['timeline'],
    feeType: map['feeType'],
    commissionPercent: (map['commissionPercent'] as num).toDouble(),
    status: map['status'],
    createdAt: DateTime.parse(map['createdAt']),
  );

  factory CustomOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomOffer.fromMap(data);
  }
}
