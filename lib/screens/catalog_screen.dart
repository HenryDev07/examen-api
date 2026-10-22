import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../services/favorites_store.dart';
import '../widgets/character_image.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final ApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  List<Character> _characters = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ApiResponse response = await _apiService.getCharacters(1);
      if (!mounted) return;
      setState(() {
        _characters = response.results;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  List<Character> get _filteredCharacters {
    final query = _searchController.text.trim().toLowerCase();
    final favorites = context.read<FavoritesStore>();
    final characters = _showFavorites
        ? _characters.where((character) => favorites.isFavorite(character.id))
        : _characters;
    if (query.isEmpty) return characters.toList();

    return characters
        .where((character) => character.name.toLowerCase().contains(query))
        .toList();
  }

  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    context.watch<FavoritesStore>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showFavorites
              ? 'Favoritos de esta página'
              : 'Personajes de Los Simpson',
        ),
        actions: [
          IconButton(
            tooltip: 'Ver todos los favoritos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FavoritesScreen(apiService: _apiService),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: _showFavorites
                ? 'Ver catálogo'
                : 'Ver favoritos de esta página',
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
            icon: Icon(_showFavorites ? Icons.list : Icons.favorite),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Buscar personaje',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Limpiar búsqueda',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _showFavorites
                  ? 'Mostrando favoritos de la página actual.'
                  : 'La búsqueda solo revisa la página actual.',
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadCharacters,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final characters = _filteredCharacters;
    if (characters.isEmpty) {
      return Center(
        child: Text(
          _characters.isEmpty
              ? 'No hay personajes en esta página.'
              : _showFavorites &&
                    context.read<FavoritesStore>().favoriteIds.isEmpty
              ? 'Todavía no tienes favoritos.'
              : _showFavorites && characters.isEmpty
              ? 'No hay favoritos en esta página.'
              : 'No se encontraron personajes con ese nombre en esta página.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: CharacterImage(
              imageUrl: character.imageUrlForSize(200),
              width: 76,
              height: 88,
            ),
            title: Text(character.name),
            subtitle: Text(
              'Estado: ${character.status}\nOcupación: ${character.occupation}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip:
                      context.read<FavoritesStore>().isFavorite(character.id)
                      ? 'Quitar de favoritos'
                      : 'Agregar a favoritos',
                  onPressed: () async {
                    try {
                      await context.read<FavoritesStore>().toggle(character.id);
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
                    context.read<FavoritesStore>().isFavorite(character.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        context.read<FavoritesStore>().isFavorite(character.id)
                        ? Colors.red
                        : null,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailScreen(character: character),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
