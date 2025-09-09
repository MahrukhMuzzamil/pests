import 'package:cloud_firestore/cloud_firestore.dart';

class CustomOrder {
  final String id;
  final String offerId;
  final String providerId;
  final String clientId;
  final String name;
  final String description;
  final double grossPrice; // Total amount paid by client
  final double commissionAmount; // Platform commission
  final double providerEarnings; // Amount provider will receive
  final double commissionPercent; // Commission percentage used
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? paymentDate;
  final DateTime? startedDate;
  final DateTime? completedDate;
  final String? paymentMethod;
  final String? providerStripeAccountId;
  final String? transferStatus; // 'pending', 'completed', 'failed'
  final String? transferId;
  final DateTime? transferDate;
  final String? transferError;

  CustomOrder({
    required this.id,
    required this.offerId,
    required this.providerId,
    required this.clientId,
    required this.name,
    required this.description,
    required this.grossPrice,
    required this.commissionAmount,
    required this.providerEarnings,
    required this.commissionPercent,
    required this.status,
    required this.createdAt,
    this.paymentDate,
    this.startedDate,
    this.completedDate,
    this.paymentMethod,
    this.providerStripeAccountId,
    this.transferStatus,
    this.transferId,
    this.transferDate,
    this.transferError,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'offerId': offerId,
    'providerId': providerId,
    'clientId': clientId,
    'name' : name,
    'description': description,
    'grossPrice': grossPrice,
    'commissionAmount': commissionAmount,
    'providerEarnings': providerEarnings,
    'commissionPercent': commissionPercent,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'paymentDate': paymentDate?.toIso8601String(),
    'startedDate': startedDate?.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'paymentMethod': paymentMethod,
    'providerStripeAccountId': providerStripeAccountId,
    'transferStatus': transferStatus,
    'transferId': transferId,
    'transferDate': transferDate?.toIso8601String(),
    'transferError': transferError,
  };

  factory CustomOrder.fromMap(Map<String, dynamic> map) => CustomOrder(
    id: map['id'],
    offerId: map['offerId'],
    providerId: map['providerId'],
    clientId: map['clientId'],
    name: map['name'] ?? 'Custom Service', //fallback name
    description: map['description'],
    grossPrice: (map['grossPrice'] as num).toDouble(),
    commissionAmount: (map['commissionAmount'] as num).toDouble(),
    providerEarnings: (map['providerEarnings'] as num).toDouble(),
    commissionPercent: (map['commissionPercent'] as num).toDouble(),
    status: map['status'],
    createdAt: DateTime.parse(map['createdAt']),
    paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate']) : null,
    startedDate: map['startedDate'] != null ? DateTime.parse(map['startedDate']) : null,
    completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate']) : null,
    paymentMethod: map['paymentMethod'],
    providerStripeAccountId: map['providerStripeAccountId'],
    transferStatus: map['transferStatus'],
    transferId: map['transferId'],
    transferDate: map['transferDate'] != null ? DateTime.parse(map['transferDate']) : null,
    transferError: map['transferError'],
  );

  factory CustomOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomOrder.fromMap(data);
  }
} 