import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'supabase_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(supabaseClientProvider));
});

final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return ref.watch(orderServiceProvider).fetchMyOrders();
});

final adminOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return ref.watch(orderServiceProvider).fetchAllOrdersForAdmin();
});