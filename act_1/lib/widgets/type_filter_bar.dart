import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  final List<String> _pokemonTypes = const [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(selectedTypesProvider);

    return Container(
      height: 55,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (selectedTypes.isNotEmpty) ...[
            ActionChip(
              avatar: const Icon(Icons.close, size: 16, color: Colors.white),
              label: Text(
                'Clear (${selectedTypes.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.red[700],
              onPressed: () {
                ref.read(selectedTypesProvider.notifier).state = {};
              },
            ),
            const SizedBox(width: 8),
          ],
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: const Text(
                'All',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              selected: selectedTypes.isEmpty,
              selectedColor: Colors.red[700],
              labelStyle: TextStyle(
                color: selectedTypes.isEmpty ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.grey[200],
              checkmarkColor: Colors.white,
              onSelected: (bool selected) {
                if (selected) {
                  ref.read(selectedTypesProvider.notifier).state = {};
                }
              },
            ),
          ),
          ..._pokemonTypes.map((type) {
            final isSelected = selectedTypes.contains(type.toLowerCase());

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                selectedColor: ref.read(pokemonTypeColorProvider(type)),
                backgroundColor: Colors.grey[200],
                checkmarkColor: Colors.white,
                onSelected: (bool selected) {
                  final currentTypes = Set<String>.from(selectedTypes);
                  if (selected) {
                    currentTypes.add(type.toLowerCase());
                  } else {
                    currentTypes.remove(type.toLowerCase());
                  }
                  ref.read(selectedTypesProvider.notifier).state = currentTypes;
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}