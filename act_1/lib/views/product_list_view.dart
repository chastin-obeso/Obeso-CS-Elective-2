import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/herobanner.dart';
import 'product_form_dialog.dart';

class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  Widget _buildProductImage(String imageUrl, ColorScheme colorScheme) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image, size: 30),
        ),
      );
    }

    final safeAsset =
        imageUrl.startsWith('assets/') ? imageUrl : 'assets/photo1.jpg';
    return Image.asset(
      safeAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image, size: 30),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    List<Category> categories,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(
        existingProduct: product,
        categories: categories,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated "${product.name}".')),
      );
    }
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await deleteProductRecord(ref, product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${product.name}".')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount =
        screenWidth >= 1200 ? 6 : (screenWidth >= 800 ? 3 : 2);
    final double horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;

    final isAdmin = ref.watch(isAdminProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final productAsync = ref.watch(productQueryProvider);
    final currentPage = ref.watch(currentPageProvider);
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);
    final categories = categoriesAsync.value ?? const <Category>[];

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: HeroBannerWidget(),
        ),
        SliverToBoxAdapter(
          child: categoriesAsync.when(
            data: (cats) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
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
                  ...cats.map(
                    (cat) => Padding(
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
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: LinearProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range: ₱${minPrice.toStringAsFixed(0)} - ₱${maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                RangeSlider(
                  values: RangeValues(minPrice, maxPrice),
                  min: 0,
                  max: 100000,
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
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8.0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _buildProductCard(
                      context: context,
                      colorScheme: colorScheme,
                      product: product,
                      ref: ref,
                      isAdmin: isAdmin,
                      categories: categories,
                    );
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
            child: Center(child: Text('Error loading products: $err')),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
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
                    onPressed: (productAsync.value?.length ?? 0) >= itemsPerPage
                        ? () => ref.read(currentPageProvider.notifier).state++
                        : null,
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

  Widget _buildProductCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required Product product,
    required WidgetRef ref,
    required bool isAdmin,
    required List<Category> categories,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          context.goNamed(
            'productDetail',
            pathParameters: {'id': product.id.toString()},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  child: _buildProductImage(product.imageUrl, colorScheme),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.isOutOfStock
                          ? 'Out of stock'
                          : 'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 10,
                        color: product.isOutOfStock
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (isAdmin)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _showEditDialog(
                                  context,
                                  ref,
                                  product,
                                  categories,
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _confirmDeleteProduct(
                                  context,
                                  ref,
                                  product,
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 15,
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          )
                        else
                          InkWell(
                            onTap: product.isOutOfStock
                                ? null
                                : () {
                                    final res = ref
                                        .read(cartProvider)
                                        .addProduct(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res.success
                                              ? 'Added ${product.name} to cart!'
                                              : (res.message ??
                                                  'Cannot add item'),
                                        ),
                                        backgroundColor: res.success
                                            ? null
                                            : colorScheme.error,
                                      ),
                                    );
                                  },
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 16,
                              color: product.isOutOfStock
                                  ? colorScheme.outline
                                  : colorScheme.primary,
                            ),
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