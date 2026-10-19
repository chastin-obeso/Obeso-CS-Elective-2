import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/type_filter_bar.dart';

class PokemonGridScreen extends ConsumerStatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  ConsumerState<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends ConsumerState<PokemonGridScreen> {
  bool? _isFavoritesExpanded;
  bool? _isFilterBarExpanded;

  @override
  Widget build(BuildContext context) {
    final pokemonAsyncValue = ref.watch(filteredPokemonProvider);
    final selectedTypes = ref.watch(selectedTypesProvider);
    final bool isFilterOpen = _isFilterBarExpanded ?? false;
    final bool isFavOpen = _isFavoritesExpanded ?? false;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.asset(
            'assets/pokedex.png',
            height: 55,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Text('Pokédex', style: TextStyle(color: Colors.black87)),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              selectedTypes.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: selectedTypes.isNotEmpty ? Colors.red : Colors.black87,
            ),
            tooltip: 'Toggle Type Filter',
            onPressed: () {
              setState(() {
                _isFilterBarExpanded = !isFilterOpen;
              });
            },
          ),
          IconButton(
            icon: Icon(
              isFavOpen ? Icons.star : Icons.star_border,
              color: Colors.black87,
            ),
            tooltip: 'Toggle Favorites Panel',
            onPressed: () {
              setState(() {
                _isFavoritesExpanded = !isFavOpen;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Refresh Pokémon',
            onPressed: () {
              ref.read(pokemonProvider.notifier).fetch();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          FavoritesPanel(
            isExpanded: isFavOpen,
            onToggle: () {
              setState(() {
                _isFavoritesExpanded = false;
              });
            },
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isFilterOpen ? 55 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const TypeFilterBar(),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                ],
              ),
            ),
          ),

          Expanded(
            child: pokemonAsyncValue.when(
              loading: () => const LoadingIndicator(),
              error: (error, stackTrace) => ErrorDisplay(
                message: error.toString(),
                onRetry: () => ref.read(pokemonProvider.notifier).fetch(),
              ),
              data: (pokemonList) {
                if (pokemonList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No Pokémon found for this type.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.read(selectedTypesProvider.notifier).state = {},
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(pokemonProvider.notifier).fetch();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, 
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: pokemonList.length,
                      itemBuilder: (context, index) {
                        return PokemonCard(pokemon: pokemonList[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}