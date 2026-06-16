import 'dart:convert';
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;


class ApiService {
  // A URL deve ser apenas uma string limpa:
  final String baseUrl = "http://10.0.2.2:3000";

  // ... restante do seu código permanece exatamente igual
  Future<List> getDados(String endpoint, {String? usuarioId}) async {
    String url = '$baseUrl/$endpoint';
    if (usuarioId != null) {
      url += '?usuarioId=$usuarioId';
    }
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> postDados(String endpoint, Map<String, dynamic> dados) async {
    await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(dados),
    );
  }

  Future<void> putDados(String endpoint, dynamic id, Map<String, dynamic> dados) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(dados),
    );
    debugPrint('PUT status: ${response.statusCode} | URL: $url');
  }

  Future<void> deleteDados(String endpoint, dynamic id) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.delete(url);
    debugPrint('DELETE status: ${response.statusCode} | URL: $url');
  }

  Future<bool> emailJaExiste(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));
    List usuarios = json.decode(response.body);
    return usuarios.any((user) => user['email'] == email);
  }

// No seu ApiService.dart
Future<Map<String, dynamic>> validarLogin(String email, String senha) async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios'));
  if (response.statusCode != 200) return {"status": "erro_conexao"};

  List usuarios = json.decode(response.body);
  
  try {
    var user = usuarios.firstWhere(
      (u) => u['email'].toString().trim() == email.trim() && 
            u['senha'].toString().trim() == senha.trim(),
    );

    bool estaBloqueado = user['bloqueado'].toString().toLowerCase() == 'true';
    
    if (estaBloqueado && user['email'] != 'admin@admin') {
      return {"status": "bloqueado"}; 
    }

    // Retorna o status e o objeto do usuário completo!
    return {"status": "sucesso", "usuario": user}; 
    
  } catch (e) {
    return {"status": "incorreto"}; 
  }
}
}