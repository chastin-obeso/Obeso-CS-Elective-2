import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider);
    final nicknamesMap = ref.watch(nicknameProvider);

    if (pokemon == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No Pokémon selected.')),
        
      );
    }

    final String? customNickname = nicknamesMap[pokemon.id];
    final String? formattedCustomNickname = customNickname != null
        ? customNickname[0].toUpperCase() + customNickname.substring(1)
        : null;
    final String formattedId = '#${pokemon.id.toString().padLeft(3, '0')}';
    final String originalName =
        pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    return Scaffold(
      backgroundColor: pokemon.primaryTypeColor,
      appBar: AppBar(
        title: Text(
          originalName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isFav = ref.watch(favoritesProvider).contains(pokemon.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                tooltip: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            left: 50,
            top: -50,
            child: Opacity(
              opacity: 0.18,
              child: pokemon.imageUrl.isNotEmpty
                  ? Image.network(
                      pokemon.imageUrl,
                      height: 720,
                      width: 720,
                      fit: BoxFit.contain,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: SlantedTopClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(48, 70, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedId,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            originalName,
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (customNickname == null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            tooltip: 'Add Nickname',
                            onPressed: () => _showNicknameDialog(context, ref, pokemon.id, customNickname),
                          ),
                        ],
                      ],
                    ),
                    if (customNickname != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'nickname: "$formattedCustomNickname"',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: pokemon.primaryTypeColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: pokemon.primaryTypeColor),
                            tooltip: 'Edit Nickname',
                            onPressed: () => _showNicknameDialog(context, ref, pokemon.id, customNickname),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: pokemon.types.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: ref.read(pokemonTypeColorProvider(type)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 0,
            child: pokemon.imageUrl.isNotEmpty
                ? Image.network(
                    pokemon.imageUrl,
                    height: 900,
                    width: 900,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.image_not_supported,
                    size: 140, color: Colors.white),
          ),
        ],
      ),
    );
  }
  void _showNicknameDialog(BuildContext context, WidgetRef ref, int pokemonId, String? currentNickname) {
    final TextEditingController controller = TextEditingController(text: currentNickname ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Pokémon Nickname'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter custom nickname',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            if (currentNickname != null)
              TextButton(
                onPressed: () {
                  ref.read(nicknameProvider.notifier).removeNickname(pokemonId);
                  Navigator.pop(context);
                },
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newNick = controller.text.trim();
                if (newNick.isNotEmpty) {
                  ref.read(nicknameProvider.notifier).setNickname(pokemonId, newNick);
                } else {
                  ref.read(nicknameProvider.notifier).removeNickname(pokemonId);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
class SlantedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 50);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}