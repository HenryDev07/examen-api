import 'character_model.dart';

class ApiResponse {
  final int count;
  final int pages;
  final String? next;
  final String? prev;
  final List<Character> results;

  ApiResponse({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
    required this.results,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<Character> charactersList = list.map((i) => Character.fromJson(i)).toList();

    return ApiResponse(
      count: json['count'] ?? 0,
      pages: json['pages'] ?? 0,
      next: json['next'],
      prev: json['prev'],
      results: charactersList,
    );
  }
}