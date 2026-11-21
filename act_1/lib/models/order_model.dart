class OrderItemModel {
  final int id;
  final int orderId;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productObj = json['products'];
    String name = 'Product #${json['product_id'] ?? ''}';
    if (productObj is Map<String, dynamic> && productObj['name'] is String) {
      name = productObj['name'] as String;
    }

    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt(),
      productName: name,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final int id;
  final DateTime createdAt;
  final String? userId;
  final String status;
  final double total;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.createdAt,
    this.userId,
    required this.status,
    required this.total,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(OrderItemModel.fromJson)
            .toList()
        : <OrderItemModel>[];

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '')?.toLocal() ??
          DateTime.now(),
      userId: json['user_id'] as String?,
      status: (json['status'] as String?) ?? 'done',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: parsedItems,
    );
  }
}