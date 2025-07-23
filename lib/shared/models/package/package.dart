class Package {
  final String id;
  final int credits;
  final double price;
  final String description;
  final bool isPopular;

  Package({
    required this.id,
    required this.credits,
    required this.price,
    required this.description,
    required this.isPopular,
  });

  factory Package.fromMap(Map<String, dynamic> data, String documentId) {
    return Package(
      id: documentId,
      credits: data['credits'] ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      isPopular: data['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'credits': credits,
      'price': price,
      'description': description,
      'isPopular': isPopular,
    };
  }
} 