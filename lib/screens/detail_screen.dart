import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../services/api_service.dart';
import '../services/favorites_store.dart';
import '../widgets/character_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.character, this.apiService});

  final Character character;
  final ApiService? apiService;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final ApiService _apiService;
  late Character _character;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
    _apiService = widget.apiService ?? ApiService();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final character = await _apiService.getCharacterDetail(
        widget.character.id,
      );
      if (!mounted) return;
      setState(() {
        _character = character;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo cargar el detalle: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_character.name),
        actions: [
          Consumer<FavoritesStore>(
            builder: (context, favorites, _) => IconButton(
              tooltip: favorites.isFavorite(_character.id)
                  ? 'Quitar de favoritos'
                  : 'Agregar a favoritos',
              onPressed: () async {
                try {
                  await favorites.toggle(_character.id);
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
                favorites.isFavorite(_character.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favorites.isFavorite(_character.id) ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Card(
              child: ListTile(
                title: Text(_errorMessage!),
                trailing: IconButton(
                  tooltip: 'Reintentar',
                  onPressed: _loadCharacter,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          Center(
            child: CharacterImage(
              imageUrl: _character.imageUrl,
              width: 240,
              height: 280,
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Nombre', value: _character.name),
          _DetailRow(label: 'Estado', value: _character.status),
          _DetailRow(label: 'Ocupación', value: _character.occupation),
          _DetailRow(label: 'Género', value: _character.gender),
          _DetailRow(label: 'Edad', value: _character.age),
          const SizedBox(height: 12),
          Text('Frase', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          if (_character.phrases.isEmpty)
            const Text('Sin frase disponible.')
          else
            ..._character.phrases.map(
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
