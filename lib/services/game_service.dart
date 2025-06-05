import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'auth_service.dart';

class GameService {
  final AuthService _auth = AuthService();

  Future<http.Response> fetchGames() async {
    final token = await _auth.getToken();
    return http.get(
      Uri.parse('$kApiBaseUrl/games'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchGame(int gameId) async {
    final token = await _auth.getToken();
    return http.get(
      Uri.parse('$kApiBaseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> shoot(int gameId, String coordinate) async {
    final token = await _auth.getToken();
    return http.put(
      Uri.parse('$kApiBaseUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'shot': coordinate}),
    );
  }

  Future<http.Response> createGame(
    List<String> shipCoords, [
    String? aiLevel,
  ]) async {
    final token = await _auth.getToken();
    return http.post(
      Uri.parse('$kApiBaseUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        aiLevel != null
            ? {'ships': shipCoords, 'ai': aiLevel}
            : {'ships': shipCoords},
      ),
    );
  }

  Future<http.Response> deleteGame(int gameId) async {
    final token = await _auth.getToken();
    return http.delete(
      Uri.parse('$kApiBaseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
