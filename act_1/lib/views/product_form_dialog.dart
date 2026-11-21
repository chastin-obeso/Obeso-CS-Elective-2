import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? existingProduct;
  final List<Category> categories;

  const ProductFormDialog({
    super.key,
    this.existingProduct,
    required this.categories,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  int? _selectedCategoryId;
  Uint8List? _pickedBytes;
  String? _pickedFileName;
  String _pickedExtension = '.jpg';
  bool _isSaving = false;
  bool _isPicking = false;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '10',
    );
    _selectedCategoryId = p?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String _normalizeExt(String? rawExt, String? fileName) {
    var ext = (rawExt ?? '').trim();
    if (ext.isEmpty && fileName != null && fileName.contains('.')) {
      ext = fileName.split('.').last.trim();
    }
    if (ext.isEmpty) return '.jpg';
    ext = ext.toLowerCase();
    return ext.startsWith('.') ? ext : '.$ext';
  }

  Future<void> _pickImage() async {
    setState(() => _isPicking = true);
    try {
      final fp.PlatformFile? file = await fp.FilePicker.pickFile(
        type: fp.FileType.image,
      );

      if (file == null) {
        return;
      }

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Selected file has no readable image data.');
      }

      final ext = _normalizeExt(file.extension, file.name);

      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedFileName = file.name;
        _pickedExtension = ext;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && (_pickedBytes == null || _pickedBytes!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image before creating.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());

    setState(() => _isSaving = true);
    try {
      final product = Product(
        id: widget.existingProduct?.id ?? 0,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        stock: stock,
        categoryId: _selectedCategoryId,
        imageUrl: widget.existingProduct?.imageUrl ?? '',
      );

      if (_isEditing) {
        await updateProductRecord(
          ref,
          product,
          imageBytes: _pickedBytes,
          imageExtension: _pickedExtension,
        );
      } else {
        await createProductRecord(
          ref,
          product,
          imageBytes: _pickedBytes,
          imageExtension: _pickedExtension,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImageSection(BuildContext context, double previewWidth) {
    final existingUrl = widget.existingProduct?.imageUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedBytes != null && _pickedBytes!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _pickedBytes!,
              height: 120,
              width: previewWidth,
              fit: BoxFit.cover,
            ),
          )
        else if (existingUrl != null &&
            (existingUrl.startsWith('http://') ||
                existingUrl.startsWith('https://')))
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              existingUrl,
              height: 120,
              width: previewWidth,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          _pickedFileName != null
              ? 'Selected: $_pickedFileName (${(_pickedBytes!.length / 1024).toStringAsFixed(1)} KB)'
              : (_isEditing
                  ? 'Keep current image or select a new file'
                  : 'No image selected'),
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: (_isPicking || _isSaving) ? null : _pickImage,
          icon: _isPicking
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.image_outlined, size: 18),
          label: Text(
            _isPicking
                ? 'Selecting...'
                : (_pickedBytes != null ? 'Change Image' : 'Select Image'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth - 48).clamp(260.0, 420.0);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name *'),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price (₱) *'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    final parsed = double.tryParse((val ?? '').trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid price (0 or more)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _stockController,
                  decoration:
                      const InputDecoration(labelText: 'Stock Quantity *'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final parsed = int.tryParse((val ?? '').trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a whole number (0 or more)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (widget.categories.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: widget.categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                  ),
                const SizedBox(height: 12),
                _buildImageSection(context, dialogWidth),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isSaving || _isPicking) ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save Changes' : 'Create'),
        ),
      ],
    );
  }
}