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
    var phrasesList = json['phrases'] as List?;
    List<String> parsedPhrases = [];
    if (phrasesList != null) {
      parsedPhrases = phrasesList.map((e) => e.toString()).toList();
    }

    return Character(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Desconocido',
      status: json['status'] ?? 'Desconocido',
      occupation: json['occupation'] ?? 'Desconocido',
      gender: json['gender'] ?? 'Desconocido',
      age: json['age']?.toString() ?? 'Desconocido',
      portraitPath: json['portrait_path'] ?? '',
      phrases: parsedPhrases,
    );
  }

  String get imageUrl {
    if (portraitPath.isEmpty) return '';
    return 'https://cdn.thesimpsonsapi.com/500$portraitPath';
  }
}