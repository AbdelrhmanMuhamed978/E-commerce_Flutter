class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final int stock;
  final double rating;
  final int numReviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.stock,
    required this.rating,
    required this.numReviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: json['image'] != null ? [json['image'].toString()] : [],
      category: json['category'] ?? '',
      stock: json['qunt'] ?? 0,
      rating: json['rating'] != null && json['rating']['rate'] != null
          ? (json['rating']['rate']).toDouble()
          : 0.0,
      numReviews: json['rating'] != null && json['rating']['count'] != null
          ? json['rating']['count']
          : 0,
    );
  }
}
