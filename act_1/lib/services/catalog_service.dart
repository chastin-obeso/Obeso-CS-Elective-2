import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';

class CatalogService {
  final SupabaseClient _supabase;

  CatalogService(this._supabase);

  static const String _bucketName = 'product-images';

  Future<List<Category>> fetchCategories() async {
    final response = await _supabase
        .from('categories')
        .select('id, name')
        .order('name', ascending: true);

    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  Future<List<Product>> fetchProducts({
    int? categoryId,
    required double minPrice,
    required double maxPrice,
    required int from,
    required int to,
  }) async {
    var query = _supabase
        .from('products')
        .select('id, name, price, image_url, description, category_id, stock')
        .gte('price', minPrice)
        .lte('price', maxPrice);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query
        .order('id', ascending: true)
        .range(from, to);

    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<Product?> fetchProductById(int productId) async {
    final data = await _supabase
        .from('products')
        .select('id, name, price, image_url, description, category_id, stock')
        .eq('id', productId)
        .maybeSingle();

    if (data == null) return null;
    return Product.fromJson(data);
  }

  Future<String> uploadProductImageFile(File imageFile) async {
    final ext = p.extension(imageFile.path).toLowerCase();
    final safeExt = ext.isEmpty ? '.jpg' : ext;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final storagePath = 'products/$fileName';

    await _supabase.storage.from(_bucketName).upload(
          storagePath,
          imageFile,
          fileOptions: FileOptions(
            cacheControl: '3600',
            contentType: _contentTypeForExtension(safeExt),
            upsert: false,
          ),
        );

    return _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
  }

  Future<String> uploadProductImageBytes({
    required Uint8List bytes,
    String fileExtension = '.jpg',
  }) async {
    final normalizedExt = fileExtension.startsWith('.')
        ? fileExtension.toLowerCase()
        : '.${fileExtension.toLowerCase()}';
    final safeExt = normalizedExt == '.' ? '.jpg' : normalizedExt;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final storagePath = 'products/$fileName';

    await _supabase.storage.from(_bucketName).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            contentType: _contentTypeForExtension(safeExt),
            upsert: false,
          ),
        );

    return _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
  }

  Future<void> createProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageExtension = '.jpg',
    bool requireImageUpload = true,
  }) async {
    final payload = Map<String, dynamic>.from(product.toJson());
    payload.remove('id');

    if (imageFile != null) {
      payload['image_url'] = await uploadProductImageFile(imageFile);
    } else if (imageBytes != null) {
      payload['image_url'] = await uploadProductImageBytes(
        bytes: imageBytes,
        fileExtension: imageExtension,
      );
    } else if (requireImageUpload) {
      throw StateError(
        'No imageFile or imageBytes passed to createProduct; refusing to insert without uploading to $_bucketName.',
      );
    }

    await _supabase.from('products').insert(payload);
  }

  Future<void> updateProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageExtension = '.jpg',
  }) async {
    final payload = Map<String, dynamic>.from(product.toJson());
    payload.remove('id');

    if (imageFile != null) {
      payload['image_url'] = await uploadProductImageFile(imageFile);
    } else if (imageBytes != null) {
      payload['image_url'] = await uploadProductImageBytes(
        bytes: imageBytes,
        fileExtension: imageExtension,
      );
    }

    await _supabase
        .from('products')
        .update(payload)
        .eq('id', product.id)
        .select()
        .single();
  }

  Future<void> deleteProduct(int productId) async {
    await _supabase.from('products').delete().eq('id', productId);
  }

  String _contentTypeForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.jpeg':
      case '.jpg':
      default:
        return 'image/jpeg';
    }
  }
}