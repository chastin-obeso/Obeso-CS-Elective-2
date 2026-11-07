import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/herobanner.dart';

class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  void _showUpdateDialog(BuildContext context, WidgetRef ref, Product product) {
    final priceController = TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Price: ${product.name}'),
        content: TextField(
          controller: priceController,
          decoration: const InputDecoration(labelText: 'New Price (₱)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null) {
                await updateProductPrice(ref, product.id, newPrice);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 1200 ? 6 : (screenWidth >= 800 ? 3 : 2);
    final double horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;

    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final productAsync = ref.watch(productQueryProvider);
    final currentPage = ref.watch(currentPageProvider);
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: HeroBannerWidget(),
        ),

        SliverToBoxAdapter(
          child: categoriesAsync.when(
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
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
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range: ₱${minPrice.toStringAsFixed(0)} - ₱${maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
        ),

        productAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text('No products match your filters.')),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, colorScheme, product, ref);
                  },
                  childCount: products.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SliverFillRemaining(
            child: Center(child: Text('Error: $err')),
          ),
        ),

        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    child: Text(
                      'Page ${currentPage + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => ref.read(currentPageProvider.notifier).state++,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ColorScheme colorScheme, Product product, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          context.goNamed('productDetail', pathParameters: {'id': product.id.toString()});
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 30),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: colorScheme.primary),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _showUpdateDialog(context, ref, product),
                              child: const Icon(Icons.edit_outlined, size: 14, color: Colors.blue),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => deleteProductRecord(ref, product.id),
                              child: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                            ),
                          ],
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