import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'supabase_provider.dart';

final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);
final minPriceProvider = StateProvider<double>((ref) => 0.0);
final maxPriceProvider = StateProvider<double>((ref) => 15000.0);
final currentPageProvider = StateProvider<int>((ref) => 0);
const int itemsPerPage = 6; 

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('categories').select();
  return (response as List).map((json) => Category.fromJson(json)).toList();
});

final productQueryProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final catId = ref.watch(selectedCategoryIdProvider);
  final minPrice = ref.watch(minPriceProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  final page = ref.watch(currentPageProvider);

  final int from = page * itemsPerPage;
  final int to = from + itemsPerPage - 1;

  var query = supabase
      .from('products')
      .select()
      .gte('price', minPrice)
      .lte('price', maxPrice);

  if (catId != null) {
    query = query.eq('category_id', catId);
  }

  final response = await query.range(from, to);
  return (response as List).map((json) => Product.fromJson(json)).toList();
});

Future<void> insertProduct(WidgetRef ref, Product newProduct) async {
  final supabase = ref.read(supabaseClientProvider);
  await supabase.from('products').insert(newProduct.toJson());
  ref.invalidate(productQueryProvider);
}

Future<void> updateProductPrice(WidgetRef ref, int productId, double newPrice) async {
  final supabase = ref.read(supabaseClientProvider);

  await supabase
      .from('products')
      .update({'price': newPrice})
      .eq('id', productId)
      .select()
      .single();

  ref.invalidate(productQueryProvider);
}

Future<void> deleteProductRecord(WidgetRef ref, int productId) async {
  final supabase = ref.read(supabaseClientProvider);

  await supabase
      .from('products')
      .delete()
      .eq('id', productId)
      .select();

  ref.invalidate(productQueryProvider);
}