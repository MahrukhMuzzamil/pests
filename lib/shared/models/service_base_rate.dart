class ServiceBaseRate {
  final String categoryName;
  final double minPrice;

  ServiceBaseRate({required this.categoryName, required this.minPrice});

  factory ServiceBaseRate.fromMap(Map<String, dynamic> data) {
    return ServiceBaseRate(
      categoryName: data['categoryName'] ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}