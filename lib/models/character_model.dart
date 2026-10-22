class Character {
  final int id;
  final String name;
  final String status;
  final String occupation;
  final String gender;
  final String age;
  final String portraitPath;
  final List<String> phrases;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.occupation,
    required this.gender,
    required this.age,
    required this.portraitPath,
    required this.phrases,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final rawPhrases = json['phrases'];
    final parsedPhrases = rawPhrases is List
        ? rawPhrases
              .where((phrase) => phrase != null)
              .map((phrase) => phrase.toString())
              .toList()
        : rawPhrases is String
        ? [rawPhrases]
        : <String>[];

    return Character(
      id: _parseId(json['id']),
      name: _parseText(json['name']),
      status: _parseText(json['status']),
      occupation: _parseText(json['occupation']),
      gender: _parseText(json['gender']),
      age: _parseText(json['age']),
      portraitPath: _parseText(json['portrait_path'], fallback: ''),
      phrases: parsedPhrases,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseText(dynamic value, {String fallback = 'Desconocido'}) {
    if (value == null) return fallback;
    if (value is String && value.trim().isEmpty) return fallback;
    return value.toString();
  }

  String get imageUrl {
    return imageUrlForSize(500);
  }

  String imageUrlForSize(int size) {
    final path = portraitPath.trim();
    if (path.isEmpty) return '';

    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return uri.replace(scheme: 'https').toString();
    }

    final imagePath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.https('cdn.thesimpsonsapi.com', '/$size/$imagePath').toString();
  }
}
