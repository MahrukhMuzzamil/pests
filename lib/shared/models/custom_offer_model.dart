import 'package:cloud_firestore/cloud_firestore.dart';

class CustomOffer {
  final String id;
  final String providerId;
  final String clientId;
  final String name; // NEW: Separate field for offer name/title
  final String description;
  final double totalPrice;
  final String timeline; // Now stores "X days" format or delivery time description
  final String feeType; // e.g., 'per visit', 'one-time'
  final double commissionPercent;
  final String status; // 'pending', 'accepted', 'declined', 'paid'
  final DateTime createdAt;
  final DateTime? paymentDate;
  final double? commissionAmount;
  final double? providerAmount;
  final double? totalPaid;
  final String? paymentMethod;
  final List<String>? clearedFor;
  final DateTime? clearedAt;

  CustomOffer({
    required this.id,
    required this.providerId,
    required this.clientId,
    required this.name, // NEW: Required offer name
    required this.description,
    required this.totalPrice,
    required this.timeline,
    required this.feeType,
    required this.commissionPercent,
    required this.status,
    required this.createdAt,
    this.paymentDate,
    this.commissionAmount,
    this.providerAmount,
    this.totalPaid,
    this.paymentMethod,
    this.clearedFor,
    this.clearedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerId': providerId,
    'clientId': clientId,
    'name': name, // NEW: Include name in map
    'description': description,
    'totalPrice': totalPrice,
    'timeline': timeline,
    'feeType': feeType,
    'commissionPercent': commissionPercent,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'paymentDate': paymentDate?.toIso8601String(),
    'commissionAmount': commissionAmount,
    'providerAmount': providerAmount,
    'totalPaid': totalPaid,
    'paymentMethod': paymentMethod,
    'clearedFor': clearedFor,
    'clearedAt': clearedAt?.toIso8601String(),
  };

  factory CustomOffer.fromMap(Map<String, dynamic> map) => CustomOffer(
    id: map['id'],
    providerId: map['providerId'],
    clientId: map['clientId'],
    name: map['name'] ?? 'Custom Service', // NEW: With fallback for old data
    description: map['description'],
    totalPrice: (map['totalPrice'] as num).toDouble(),
    timeline: map['timeline'],
    feeType: map['feeType'],
    commissionPercent: (map['commissionPercent'] as num).toDouble(),
    status: map['status'],
    createdAt: DateTime.parse(map['createdAt']),
    paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate']) : null,
    commissionAmount: map['commissionAmount'] != null ? (map['commissionAmount'] as num).toDouble() : null,
    providerAmount: map['providerAmount'] != null ? (map['providerAmount'] as num).toDouble() : null,
    totalPaid: map['totalPaid'] != null ? (map['totalPaid'] as num).toDouble() : null,
    paymentMethod: map['paymentMethod'],
    clearedFor: map['clearedFor'] != null ? List<String>.from(map['clearedFor']) : null,
    clearedAt: map['clearedAt'] != null ? (map['clearedAt'] is Timestamp ? (map['clearedAt'] as Timestamp).toDate() : DateTime.parse(map['clearedAt'])) : null,
  );

  factory CustomOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomOffer.fromMap(data);
  }

  // Helper method to get delivery days as integer (if timeline is in "X days" format)
  int? get deliveryDays {
    if (timeline.toLowerCase().contains('days')) {
      final match = RegExp(r'(\d+)').firstMatch(timeline);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  // Helper method to get formatted delivery time
  String get formattedDeliveryTime {
    final days = deliveryDays;
    if (days != null) {
      if (days == 1) return '1 day';
      return '$days days';
    }
    return timeline; // Fallback to original timeline
  }
}