import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class PlaceOrderResult {
  final int orderId;
  final double total;
  final String status;

  const PlaceOrderResult({
    required this.orderId,
    required this.total,
    required this.status,
  });
}

class OrderService {
  final SupabaseClient _supabase;

  OrderService(this._supabase);

  Future<PlaceOrderResult> placeOrder(List<Map<String, dynamic>> items) async {
    final response = await _supabase.rpc(
      'place_order',
      params: {'p_items': items},
    );

    final map = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};

    return PlaceOrderResult(
      orderId: (map['order_id'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: (map['status'] as String?) ?? 'done',
    );
  }

  Future<List<OrderModel>> fetchMyOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('orders')
        .select(
          'id, created_at, user_id, status, total, '
          'order_items(id, order_id, product_id, unit_price, quantity, products(name))',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<List<OrderModel>> fetchAllOrdersForAdmin() async {
    final response = await _supabase
        .from('orders')
        .select(
          'id, created_at, user_id, status, total, '
          'order_items(id, order_id, product_id, unit_price, quantity, products(name))',
        )
        .order('created_at', ascending: false);

    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await _supabase
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }
}