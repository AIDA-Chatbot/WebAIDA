import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const _baseUrl = 'https://aida-server.onrender.com';

  Future<String?> install() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/instalar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'version': 'ios-1.0.0'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String?;
      }
    } catch (e) {
      debugPrint('Install error: $e');
    }
    return null;
  }

  Future<String?> chat(
    String token,
    List<Map<String, dynamic>> messages,
    String tipo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'messages': messages, 'tipo': tipo}),
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['respuesta'] as String?;
      }
      if (response.statusCode == 429) {
        return 'Ya usaste todas tus consultas de hoy. Mañana podés seguir preguntando.';
      }
      if (response.statusCode == 503) {
        return 'Hay mucha gente preguntando en este momento. Intentá de nuevo en unos minutos.';
      }
    } catch (e) {
      debugPrint('Chat error: $e');
    }
    return null;
  }

  Future<bool> report(
    String token,
    String motivo,
    String pregunta,
    String respuesta,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/reporte'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'motivo': motivo,
          'pregunta': pregunta,
          'respuesta': respuesta,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Report error: $e');
      return false;
    }
  }

  Future<bool> deleteInstallation(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/v1/instalacion'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }
}
