import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';

class FavoritesPanel extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const FavoritesPanel({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final pokemonAsync = ref.watch(pokemonProvider);

    final favoritePokemonList = pokemonAsync.maybeWhen(
      data: (list) => list.where((p) => favoriteIds.contains(p.id)).toList(),
      orElse: () => [],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isExpanded ? 250 : 0,
      color: Colors.grey[900],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favorite Pokémon (${favoriteIds.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: onToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 185,
              child: favoritePokemonList.isEmpty
                  ? const Center(
                      child: Text(
                        'No favorites added yet! Tap the heart icon on any Pokémon.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: favoritePokemonList.length,
                      itemBuilder: (context, index) {
                        final pokemon = favoritePokemonList[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedPokemonProvider.notifier).state = pokemon;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PokemonDetailScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: pokemon.primaryTypeColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: pokemon.primaryTypeColor, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      pokemon.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error, size: 32, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}