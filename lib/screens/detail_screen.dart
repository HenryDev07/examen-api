import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../services/favorites_store.dart';
import '../widgets/character_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          Consumer<FavoritesStore>(
            builder: (context, favorites, _) => IconButton(
              tooltip: favorites.isFavorite(character.id)
                  ? 'Quitar de favoritos'
                  : 'Agregar a favoritos',
              onPressed: () async {
                try {
                  await favorites.toggle(character.id);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudo guardar el cambio de favorito.',
                      ),
                    ),
                  );
                }
              },
              icon: Icon(
                favorites.isFavorite(character.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favorites.isFavorite(character.id) ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CharacterImage(
              imageUrl: character.imageUrl,
              width: 240,
              height: 280,
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Nombre', value: character.name),
          _DetailRow(label: 'Estado', value: character.status),
          _DetailRow(label: 'Ocupación', value: character.occupation),
          _DetailRow(label: 'Género', value: character.gender),
          _DetailRow(label: 'Edad', value: character.age),
          const SizedBox(height: 12),
          Text('Frase', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          if (character.phrases.isEmpty)
            const Text('Sin frase disponible.')
          else
            ...character.phrases.map(
              (phrase) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(phrase),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
