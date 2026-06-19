import 'db_helper.dart';

class ApiService {
  
  Future<List<Map<String, dynamic>>> getDados(String endpoint, {String? usuarioId}) async {
    final data = await DBHelper.query(endpoint);
    if (usuarioId != null) {
      // Garantir conversão segura para String antes de comparar
      return data.where((item) => item['usuarioId']?.toString() == usuarioId).toList();
    }
    return data;
  }

  Future<Map<String, dynamic>> postDados(String endpoint, Map<String, dynamic> dados) async {
    // O SQLite retorna o ID da linha inserida.
    int id = await DBHelper.insert(endpoint, dados);
    dados['id'] = id; 
    return dados;
  }

  Future<void> putDados(String endpoint, dynamic id, Map<String, dynamic> dados) async {
    // Garantir que o ID seja tratado como inteiro
    await DBHelper.update(endpoint, int.tryParse(id.toString()) ?? 0, dados);
  }

  Future<void> deleteDados(String endpoint, dynamic id) async {
    await DBHelper.delete(endpoint, int.tryParse(id.toString()) ?? 0);
  }

  Future<bool> emailJaExiste(String email) async {
    final usuarios = await DBHelper.query('usuarios');
    return usuarios.any((user) => user['email']?.toString().trim() == email.trim());
  }

  Future<Map<String, dynamic>> validarLogin(String email, String senha) async {
    final usuarios = await DBHelper.query('usuarios');
    
    try {
      var user = usuarios.firstWhere(
        (u) => u['email']?.toString().trim() == email.trim() && 
               u['senha']?.toString().trim() == senha.trim(),
      );

      // Verificação de bloqueio
      bool estaBloqueado = user['bloqueado']?.toString().toLowerCase() == 'true';
      
      if (estaBloqueado && user['email'] != 'admin@admin') {
        return {"status": "bloqueado"}; 
      }

      return {"status": "sucesso", "usuario": user}; 
      
    } catch (e) {
      return {"status": "incorreto"}; 
    }
  }
}