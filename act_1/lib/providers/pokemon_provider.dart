import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

enum LoadingStatus { initial, loading, success, error }

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();

  List<Pokemon> _pokemonList = [];
  LoadingStatus _status = LoadingStatus.initial;
  String _errorMessage = '';
  Pokemon? _selectedPokemon;

  List<Pokemon> get pokemonList => _pokemonList;
  LoadingStatus get status => _status;
  String get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;

  Future<void> fetchPokemonList() async {
    _status = LoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _pokemonList = await _apiService.fetchPokemonList(limit: 30);
      _status = LoadingStatus.success;
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }
}