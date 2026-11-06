import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final int crossAxisCount = screenWidth >= 1024 ? 4 : (screenWidth >= 600 ? 3 : 2);
    final double horizontalPadding = screenWidth < 600 ? 16.0 : 32.0;

    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final productAsync = ref.watch(productQueryProvider);
    final currentPage = ref.watch(currentPageProvider);
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);

    return Scaffold(
      body: Column(
        children: [
          // Category Filter Chips
          categoriesAsync.when(
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedCatId == null,
                    onSelected: (_) {
                      ref.read(currentPageProvider.notifier).state = 0;
                      ref.read(selectedCategoryIdProvider.notifier).state = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: selectedCatId == cat.id,
                          onSelected: (selected) {
                            ref.read(currentPageProvider.notifier).state = 0;
                            ref.read(selectedCategoryIdProvider.notifier).state =
                                selected ? cat.id : null;
                          },
                        ),
                      )),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Price Range Slider Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Range: ₱${minPrice.toStringAsFixed(0)} - ₱${maxPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                RangeSlider(
                  values: RangeValues(minPrice, maxPrice),
                  min: 0,
                  max: 20000,
                  divisions: 40,
                  labels: RangeLabels(
                    '₱${minPrice.toStringAsFixed(0)}',
                    '₱${maxPrice.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    ref.read(minPriceProvider.notifier).state = values.start;
                    ref.read(maxPriceProvider.notifier).state = values.end;
                    ref.read(currentPageProvider.notifier).state = 0;
                  },
                ),
              ],
            ),
          ),

          // Product Grid View
          Expanded(
            child: productAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products match your filters.'));
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, colorScheme, product, ref);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),

          // Pagination Controls
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0
                      ? () => ref.read(currentPageProvider.notifier).state--
                      : null,
                  child: const Text('Previous'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Page ${currentPage + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => ref.read(currentPageProvider.notifier).state++,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ColorScheme colorScheme, Product product, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          context.goNamed('productDetail', pathParameters: {'id': product.id.toString()});
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => deleteProductRecord(ref, product.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}