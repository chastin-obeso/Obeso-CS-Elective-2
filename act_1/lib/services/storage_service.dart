import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase;
  static const String bucketName = 'product-images';

  StorageService(this._supabase);

  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final cleanExt = fileExtension.replaceAll('.', '').toLowerCase();
    final safeExt = cleanExt.isEmpty ? 'jpg' : cleanExt;
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.$safeExt';

    await _supabase.storage.from(bucketName).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: _contentTypeForExtension(safeExt),
          ),
        );

    return _supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  String _contentTypeForExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}