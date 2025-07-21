class Gig {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;

  Gig({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Gig.fromMap(String id, Map<String, dynamic> data) {
    return Gig(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
} 