import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'product_form_dialog.dart';
import 'product_list_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  Future<void> _openCreateProductDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final categories = await ref.read(categoriesProvider.future);
    if (!context.mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(categories: categories),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      body: const ProductListView(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openCreateProductDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
    );
  }
}