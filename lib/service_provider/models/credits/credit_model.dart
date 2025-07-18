class CreditModel {
  final String id;
  final int credits;
  final double price;
  final String? description;
  final bool isPopular;

  CreditModel({
    required this.id,
    required this.credits,
    required this.price,
    this.description,
    this.isPopular = false,
  });

  // Factory method for creating a CreditModel from Firestore data
  factory CreditModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CreditModel(
      id: documentId,
      credits: data['credits'] ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      isPopular: data['isPopular'] ?? false,
    );
  }

  // Converts the model to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'credits': credits,
      'price': price,
      'description': description,
      'isPopular': isPopular,
    };
  }
}
