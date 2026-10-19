import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import 'package:flutter/material.dart';

class PokemonNotifier extends AsyncNotifier<List<Pokemon>> {
  final PokeApiService _apiService = PokeApiService();

  @override
  Future<List<Pokemon>> build() async {
    return _fetchPokemon();
  }

  Future<List<Pokemon>> _fetchPokemon() async {
    return await _apiService.fetchPokemonList(limit: 30, offset: 956);
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPokemon());
  }
}

final pokemonProvider = AsyncNotifierProvider<PokemonNotifier, List<Pokemon>>(() {
  return PokemonNotifier();
});

final selectedPokemonProvider = StateProvider<Pokemon?>((ref) => null);



class NicknameNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() {
    return {}; 
  }

  void setNickname(int pokemonId, String nickname) {
    state = {...state, pokemonId: nickname};
  }

  void removeNickname(int pokemonId) {
    final newState = {...state};
    newState.remove(pokemonId);
    state = newState;
  }
}

final nicknameProvider = NotifierProvider<NicknameNotifier, Map<int, String>>(() {
  return NicknameNotifier();
});

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return {};
  }

  void toggleFavorite(int pokemonId) {
    if (state.contains(pokemonId)) {
      state = {...state}..remove(pokemonId);
    } else {
      state = {...state, pokemonId};
    }
  }

  bool isFavorite(int pokemonId) => state.contains(pokemonId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(() {
  return FavoritesNotifier();
});

final selectedTypesProvider = StateProvider<Set<String>>((ref) => {});

final filteredPokemonProvider = Provider<AsyncValue<List<Pokemon>>>((ref) {
  final pokemonAsync = ref.watch(pokemonProvider);
  final selectedTypes = ref.watch(selectedTypesProvider);

  return pokemonAsync.whenData((pokemonList) {
    if (selectedTypes.isEmpty) {
      return pokemonList;
    }
    return pokemonList.where((p) {
      return p.types.any((t) => selectedTypes.contains(t.toLowerCase()));
    }).toList();
  });
});

final pokemonTypeColorProvider = Provider.family<Color, String>((ref, type) {
  switch (type.toLowerCase()) {
    case 'fire':
      return Colors.orange[700]!;
    case 'water':
      return Colors.blue[600]!;
    case 'grass':
      return Colors.green[600]!;
    case 'electric':
      return Colors.amber[700]!;
    case 'ice':
      return Colors.cyan[400]!;
    case 'fighting':
      return Colors.red[800]!;
    case 'poison':
      return Colors.purple[600]!;
    case 'ground':
      return Colors.brown[400]!;
    case 'flying':
      return Colors.indigo[300]!;
    case 'psychic':
      return Colors.pink[400]!;
    case 'bug':
      return Colors.lightGreen[600]!;
    case 'rock':
      return Colors.brown[600]!;
    case 'ghost':
      return Colors.deepPurple[700]!;
    case 'dragon':
      return Colors.indigo[800]!;
    case 'dark':
      return Colors.grey[850]!;
    case 'steel':
      return Colors.blueGrey[500]!; 
    case 'fairy':
      return Colors.pink[300]!;
    case 'normal':
    default:
      return Colors.grey[500]!;
  }
});