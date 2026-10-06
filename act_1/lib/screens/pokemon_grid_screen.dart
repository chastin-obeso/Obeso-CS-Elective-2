import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class PokemonGridScreen extends StatelessWidget {
  const PokemonGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.asset(
            'assets/pokedex.png',
            height: 55,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Text('Pokédex'),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Pokémon',
            onPressed: () {
              context.read<PokemonProvider>().fetchPokemonList();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          switch (provider.status) {
            case LoadingStatus.loading:
            case LoadingStatus.initial:
              return const LoadingIndicator();

            case LoadingStatus.error:
              return ErrorDisplay(
                message: provider.errorMessage,
                onRetry: () => provider.fetchPokemonList(),
              );

            case LoadingStatus.success:
              if (provider.pokemonList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No Pokémon found.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => provider.fetchPokemonList(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchPokemonList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: provider.pokemonList.length,
                    itemBuilder: (context, index) {
                      return PokemonCard(pokemon: provider.pokemonList[index]);
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}