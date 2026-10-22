import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../services/api_service.dart';
import '../services/favorites_store.dart';
import '../widgets/character_image.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Map<int, Future<Character>> _requests = {};

  Future<Character> _loadCharacter(int id) =>
      _requests.putIfAbsent(id, () => widget.apiService.getCharacterDetail(id));

  void _retry(int id) {
    setState(() {
      _requests[id] = widget.apiService.getCharacterDetail(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoritesStore>().favoriteIds.toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favoriteIds.isEmpty
          ? const Center(child: Text('Todavía no tienes favoritos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteIds.length,
              itemBuilder: (context, index) {
                final id = favoriteIds[index];
                return FutureBuilder<Character>(
                  future: _loadCharacter(id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'No se pudo cargar el personaje $id.';
                      return Card(
                        child: ListTile(
                          title: Text(message),
                          trailing: IconButton(
                            onPressed: () => _retry(id),
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reintentar',
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Card(
                        child: ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Cargando favorito...'),
                        ),
                      );
                    }

                    final character = snapshot.data!;
                    return Card(
                      child: ListTile(
                        leading: CharacterImage(
                          imageUrl: character.imageUrlForSize(200),
                          width: 56,
                          height: 64,
                        ),
                        title: Text(character.name),
                        trailing: IconButton(
                          onPressed: () async {
                            try {
                              await context.read<FavoritesStore>().toggle(
                                character.id,
                              );
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
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          tooltip: 'Quitar de favoritos',
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DetailScreen(character: character),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
