import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class PokemonGridScreen extends StatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  State<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends State<PokemonGridScreen> {
  final PokeApiService _apiService = PokeApiService();
  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  void _loadPokemon() {
    setState(() {
      _pokemonFuture = _apiService.fetchPokemonList(limit: 30);
    });
  }

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
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: snapshot.error.toString(),
              onRetry: _loadPokemon,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No Pokémon found.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadPokemon,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final pokemonList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadPokemon(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
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
    );
  }
}