class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final int? categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? 'assets/default.jpg',
      description: json['description'] ?? '',
      categoryId: json['category_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'description': description,
        'category_id': categoryId,
      };
}