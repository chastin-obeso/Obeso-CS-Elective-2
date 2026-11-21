class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final int? categoryId;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.categoryId,
    this.stock = 0,
  });

  bool get isOutOfStock => stock <= 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['image_url'] as String?)?.isNotEmpty == true
          ? json['image_url'] as String
          : 'assets/default.jpg',
      description: (json['description'] as String?) ?? '',
      categoryId: (json['category_id'] as num?)?.toInt(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'price': price,
        'image_url': imageUrl.trim(),
        'description': description.trim(),
        'category_id': categoryId,
        'stock': stock,
      };
}