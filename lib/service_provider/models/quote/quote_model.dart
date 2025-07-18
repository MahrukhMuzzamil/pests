class Quote {
  final String id;
  final double price;
  final String additionalDetails;
  final String feeType;
  final DateTime timestamp;

  Quote({
    required this.id,
    required this.price,
    required this.additionalDetails,
    required this.feeType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'additionalDetails': additionalDetails,
      'feeType': feeType,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
