import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import 'supabase_provider.dart';

final catalogServiceProvider = Provider<CatalogService>((ref) {
  return CatalogService(ref.watch(supabaseClientProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(supabaseClientProvider));
});

final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);
final minPriceProvider = StateProvider<double>((ref) => 0.0);
final maxPriceProvider = StateProvider<double>((ref) => 100000.0);
final currentPageProvider = StateProvider<int>((ref) => 0);
const int itemsPerPage = 6;

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  return ref.watch(catalogServiceProvider).fetchCategories();
});

final productQueryProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  final catId = ref.watch(selectedCategoryIdProvider);
  final minPrice = ref.watch(minPriceProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  final page = ref.watch(currentPageProvider);

  final int from = page * itemsPerPage;
  final int to = from + itemsPerPage - 1;

  return service.fetchProducts(
    categoryId: catId,
    minPrice: minPrice,
    maxPrice: maxPrice,
    from: from,
    to: to,
  );
});

final allProductsForCartProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  return ref.watch(catalogServiceProvider).fetchProducts(
        minPrice: 0.0,
        maxPrice: 1000000.0,
        from: 0,
        to: 499,
      );
});

final productByIdProvider = FutureProvider.autoDispose.family<Product?, int>((ref, id) async {
  return ref.watch(catalogServiceProvider).fetchProductById(id);
});

Future<void> createProductRecord(
  WidgetRef ref,
  Product newProduct, {
  File? imageFile,
  Uint8List? imageBytes,
  String imageExtension = '.jpg',
}) async {
  await ref.read(catalogServiceProvider).createProduct(
        newProduct,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageExtension: imageExtension,
      );
  ref.invalidate(productQueryProvider);
  ref.invalidate(allProductsForCartProvider);
}

Future<void> updateProductRecord(
  WidgetRef ref,
  Product updatedProduct, {
  File? imageFile,
  Uint8List? imageBytes,
  String imageExtension = '.jpg',
}) async {
  await ref.read(catalogServiceProvider).updateProduct(
        updatedProduct,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageExtension: imageExtension,
      );
  ref.invalidate(productQueryProvider);
  ref.invalidate(allProductsForCartProvider);
  ref.invalidate(productByIdProvider(updatedProduct.id));
}

Future<void> deleteProductRecord(WidgetRef ref, int productId) async {
  await ref.read(catalogServiceProvider).deleteProduct(productId);
  ref.invalidate(productQueryProvider);
  ref.invalidate(allProductsForCartProvider);
  ref.invalidate(productByIdProvider(productId));
}