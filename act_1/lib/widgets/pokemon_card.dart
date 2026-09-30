import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final String formattedId = '#${pokemon.id.toString().padLeft(3, '0')}';
    final String formattedName =
        pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                formattedId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),

            Expanded(
              child: pokemon.imageUrl.isNotEmpty
                  ? Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    )
                  : const Icon(Icons.image_not_supported, size: 40),
            ),
            const SizedBox(height: 6),
            Text(
              formattedName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (pokemon.types.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: pokemon.primaryTypeColor,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pokemon.types.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}