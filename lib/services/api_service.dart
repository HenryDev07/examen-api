import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/character_model.dart';

class ApiService {
  static const String baseUrl = 'https://thesimpsonsapi.com/api/characters';

  Future<ApiResponse> getCharacters(int page) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?page=$page'));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return ApiResponse.fromJson(decodedData);
      } else {
        throw Exception('Error al cargar el catalogo');
      }
    } catch (e) {
      throw Exception('Fallo de conexion de red');
    }
  }

  Future<Character> getCharacterDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return Character.fromJson(decodedData);
      } else {
        throw Exception('Error al cargar el detalle');
      }
    } catch (e) {
      throw Exception('Fallo de conexion de red');
    }
  }
}