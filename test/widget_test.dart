import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpsonapi/models/api_response.dart';
import 'package:simpsonapi/models/character_model.dart';
import 'package:simpsonapi/screens/catalog_screen.dart';
import 'package:simpsonapi/screens/login_screen.dart';
import 'package:simpsonapi/services/api_service.dart';
import 'package:simpsonapi/services/favorites_store.dart';

void main() {
  test('restores and persists favorite IDs', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_character_ids': ['2'],
    });

    final store = await FavoritesStore.load();
    expect(store.favoriteIds, {2});

    await store.toggle(4);
    final restoredStore = await FavoritesStore.load();
    expect(restoredStore.favoriteIds, {2, 4});
  });

  test('parses missing and differently typed character fields', () {
    final character = Character.fromJson({
      'id': '12',
      'name': null,
      'age': 10,
      'phrases': 'Hello!',
    });

    expect(character.id, 12);
    expect(character.name, 'Desconocido');
    expect(character.age, '10');
    expect(character.phrases, ['Hello!']);
    expect(character.portraitPath, '');
    expect(character.imageUrl, '');
  });

  test('builds HTTPS CDN image URLs for character portraits', () {
    final character = Character.fromJson({
      'id': 1,
      'portrait_path': '/character/1.webp',
    });

    expect(
      character.imageUrlForSize(200),
      'https://cdn.thesimpsonsapi.com/200/character/1.webp',
    );
    expect(
      character.imageUrl,
      'https://cdn.thesimpsonsapi.com/500/character/1.webp',
    );
  });

  testWidgets('filters the current page without case sensitivity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'hOmEr');
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Homer Simpson'), findsOneWidget);
    expect(find.text('Bart Simpson'), findsNothing);
  });

  testWidgets('loads next and previous catalog pages', (
    WidgetTester tester,
  ) async {
    final pageOneCharacter = _character(1, 'Homer Simpson');
    final pageTwoCharacter = _character(2, 'Bart Simpson');
    final apiService = _FakeApiService(
      ApiResponse(
        count: 2,
        pages: 2,
        next: 'https://thesimpsonsapi.com/api/characters?page=2',
        results: [pageOneCharacter],
      ),
      pageResponses: {
        1: ApiResponse(
          count: 2,
          pages: 2,
          next: 'https://thesimpsonsapi.com/api/characters?page=2',
          results: [pageOneCharacter],
        ),
        2: ApiResponse(
          count: 2,
          pages: 2,
          prev: 'https://thesimpsonsapi.com/api/characters?page=1',
          results: [pageTwoCharacter],
        ),
      },
    );

    await tester.pumpWidget(_testApp(apiService: apiService));
    await tester.pumpAndSettle();
    expect(find.text('Página 1 de 2'), findsOneWidget);
    expect(find.text('Homer Simpson'), findsOneWidget);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pumpAndSettle();
    expect(apiService.requestedPages, [1, 2]);
    expect(find.text('Página 2 de 2'), findsOneWidget);
    expect(find.text('Bart Simpson'), findsOneWidget);

    await tester.tap(find.byTooltip('Página anterior'));
    await tester.pumpAndSettle();
    expect(apiService.requestedPages, [1, 2, 1]);
    expect(find.text('Página 1 de 2'), findsOneWidget);
    expect(find.text('Homer Simpson'), findsOneWidget);
  });

  testWidgets('opens character details and returns to the catalog', (
    WidgetTester tester,
  ) async {
    final apiService = _FakeApiService(
      ApiResponse(
        count: 2,
        pages: 1,
        results: [
          _character(1, 'Homer Simpson', phrases: ['D’oh!', 'Mmm...']),
          _character(2, 'Bart Simpson'),
        ],
      ),
    );
    await tester.pumpWidget(_testApp(apiService: apiService));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Homer Simpson'));
    await tester.pumpAndSettle();

    expect(apiService.requestedDetailIds, [1]);
    expect(find.text('Género'), findsOneWidget);
    expect(find.text('Edad'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mmm...'), 200);
    expect(find.text('D’oh!'), findsOneWidget);
    expect(find.text('Mmm...'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('accepts the demo login credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesStore(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'RaulCooking');
    await tester.enterText(find.byType(TextFormField).at(1), 'Prueba12345');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Personajes de Los Simpson'), findsOneWidget);
  });

  testWidgets('keeps favorites after logging out and back in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = FavoritesStore(preferences: preferences);
    final character = Character(
      id: 1,
      name: 'Homer Simpson',
      status: 'Alive',
      occupation: 'Safety inspector',
      gender: 'Male',
      age: '39',
      portraitPath: '',
      phrases: [],
    );
    final apiService = _FakeApiService(
      ApiResponse(count: 1, pages: 1, results: [character]),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => store,
        child: MaterialApp(home: LoginScreen(apiService: apiService)),
      ),
    );

    Future<void> logIn() async {
      await tester.enterText(find.byType(TextFormField).at(0), 'RaulCooking');
      await tester.enterText(find.byType(TextFormField).at(1), 'Prueba12345');
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();
    }

    await logIn();
    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);

    await tester.tap(find.byTooltip('Cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await logIn();
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
    expect(store.favoriteIds, {1});
  });

  testWidgets('shows an error for incorrect demo login credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesStore(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'incorrecto');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });
}

Widget _testApp({ApiService? apiService}) {
  final characters = [
    Character(
      id: 1,
      name: 'Homer Simpson',
      status: 'Alive',
      occupation: 'Safety inspector',
      gender: 'Male',
      age: '39',
      portraitPath: '',
      phrases: ['D’oh!', 'Mmm...'],
    ),
    Character(
      id: 2,
      name: 'Bart Simpson',
      status: 'Alive',
      occupation: 'Student',
      gender: 'Male',
      age: '10',
      portraitPath: '',
      phrases: [],
    ),
  ];

  return ChangeNotifierProvider(
    create: (_) => FavoritesStore(),
    child: MaterialApp(
      home: CatalogScreen(
        apiService:
            apiService ??
            _FakeApiService(
              ApiResponse(
                count: characters.length,
                pages: 1,
                results: characters,
              ),
            ),
      ),
    ),
  );
}

class _FakeApiService extends ApiService {
  _FakeApiService(this.response, {Map<int, ApiResponse>? pageResponses})
    : _pageResponses = pageResponses ?? {};

  final ApiResponse response;
  final Map<int, ApiResponse> _pageResponses;
  final requestedPages = <int>[];
  final requestedDetailIds = <int>[];

  @override
  Future<ApiResponse> getCharacters(int page) async {
    requestedPages.add(page);
    return _pageResponses[page] ?? response;
  }

  @override
  Future<Character> getCharacterDetail(int id) async {
    requestedDetailIds.add(id);
    return response.results.firstWhere((character) => character.id == id);
  }
}

Character _character(int id, String name, {List<String> phrases = const []}) =>
    Character(
      id: id,
      name: name,
      status: 'Alive',
      occupation: 'Safety inspector',
      gender: 'Male',
      age: '39',
      portraitPath: '',
      phrases: phrases,
    );
