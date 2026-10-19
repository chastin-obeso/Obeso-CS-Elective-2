import 'package:flutter/material.dart';
import 'screens/pokemon_grid_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: const PokemonGridScreen(),
    );
  }
}