import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'services/favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritesStore = await FavoritesStore.load();
  runApp(MyApp(favoritesStore: favoritesStore));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.favoritesStore});

  final FavoritesStore favoritesStore;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FavoritesStore>.value(
      value: favoritesStore,
      child: MaterialApp(
        title: 'Personajes de Los Simpson',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFE8A3),
            primary: const Color(0xFFFFE082),
            onPrimary: const Color(0xFF4E3B00),
            surface: const Color(0xFFFFFDF5),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF9E6),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFF4CC)),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFE082),
              foregroundColor: const Color(0xFF4E3B00),
            ),
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
