import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore({this.preferences, Set<int> initialFavorites = const {}})
    : _favoriteIds = {...initialFavorites};

  static const _storageKey = 'favorite_character_ids';

  final SharedPreferences? preferences;
  final Set<int> _favoriteIds;

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(int id) => _favoriteIds.contains(id);

  static Future<FavoritesStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    final ids = (preferences.getStringList(_storageKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    return FavoritesStore(preferences: preferences, initialFavorites: ids);
  }

  Future<void> toggle(int id) async {
    final wasFavorite = _favoriteIds.contains(id);
    if (wasFavorite) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final preferences = this.preferences;
      if (preferences != null) {
        final saved = await preferences.setStringList(
          _storageKey,
          _favoriteIds.map((favoriteId) => favoriteId.toString()).toList(),
        );
        if (!saved) throw StateError('No se pudieron guardar los favoritos.');
      }
    } catch (_) {
      if (wasFavorite) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
      notifyListeners();
      rethrow;
    }
  }
}
