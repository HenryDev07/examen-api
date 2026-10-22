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
    final rawResults = json['results'];
    final charactersList = rawResults is List
        ? rawResults
              .whereType<Map<String, dynamic>>()
              .map(Character.fromJson)
              .toList()
        : <Character>[];

    return ApiResponse(
      count: _parseInt(json['count']),
      pages: _parseInt(json['pages']),
      next: _parseLink(json['next']),
      prev: _parseLink(json['prev']),
      results: charactersList,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _parseLink(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;
}
