import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nicknamesMap = ref.watch(nicknameProvider);
    final customNickname = nicknamesMap[pokemon.id];

    final String formattedId = '#${pokemon.id.toString().padLeft(3, '0')}';
    final String originalName =
        pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(selectedPokemonProvider.notifier).state = pokemon;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PokemonDetailScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final isFav = ref.watch(favoritesProvider).contains(pokemon.id);
                      return InkWell(
                        onTap: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
                        },
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      );
                    },
                  ),
                  Text(
                    formattedId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
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
              const SizedBox(height: 4),
              Text(
                originalName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (customNickname != null)
                Text(
                  '"$customNickname"',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: pokemon.primaryTypeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              if (pokemon.types.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  alignment: WrapAlignment.center,
                  children: pokemon.types.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ref.read(pokemonTypeColorProvider(type)), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}