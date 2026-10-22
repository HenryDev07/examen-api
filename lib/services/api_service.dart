import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/character_model.dart';

enum ApiErrorType { connection, server, response }

class ApiException implements Exception {
  const ApiException(this.type, this.message);

  final ApiErrorType type;
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://thesimpsonsapi.com/api/characters';

  Future<ApiResponse> getCharacters(int page) async {
    final response = await _get(Uri.parse('$baseUrl?page=$page'));
    return ApiResponse.fromJson(_decodeObject(response.body));
  }

  Future<Character> getCharacterDetail(int id) async {
    final response = await _get(Uri.parse('$baseUrl/$id'));
    return Character.fromJson(_decodeObject(response.body));
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw ApiException(
          ApiErrorType.server,
          'El servidor respondió con el código ${response.statusCode}.',
        );
      }
      return response;
    } on http.ClientException {
      throw const ApiException(
        ApiErrorType.connection,
        'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const ApiException(
        ApiErrorType.connection,
        'La conexión tardó demasiado. Inténtalo de nuevo.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw const ApiException(
        ApiErrorType.response,
        'La respuesta recibida no tiene un formato válido.',
      );
    }

    throw const ApiException(
      ApiErrorType.response,
      'La respuesta recibida no tiene la estructura esperada.',
    );
  }
}
