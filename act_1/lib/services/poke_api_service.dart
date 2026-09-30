import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<List<Pokemon>> fetchPokemonList({int limit = 30, int offset = 956}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?limit=$limit&offset=$offset'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];

        final List<Future<Pokemon>> detailFutures = results.map((item) async {
          final detailResponse = await http.get(Uri.parse(item['url']));
          if (detailResponse.statusCode == 200) {
            return Pokemon.fromJson(jsonDecode(detailResponse.body));
          } else {
            throw Exception('Failed to load details for ${item['name']}');
          }
        }).toList();

        return await Future.wait(detailFutures);
      } else {
        throw Exception('Failed to load Pokémon list (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network or parsing error: $e');
    }
  }
}