import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'controle_tarefas.db'),
      onCreate: (db, version) {
        // Criando as tabelas necessárias
        db.execute('CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, email TEXT, senha TEXT, bloqueado TEXT)');
        db.execute('CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, usuarioId INTEGER, titulo TEXT, descricao TEXT, status INTEGER)');
      },
      version: 1,
    );
  }

  // Método que insere o Admin inicial se o banco estiver vazio
  static Future<void> seedDatabase() async {
    final db = await DBHelper.database();
    final usuarios = await db.query('usuarios');
    
    if (usuarios.isEmpty) {
      await db.insert('usuarios', {
        'nome': 'Administrador',
        'email': 'admin@admin',
        'senha': '123',
        'bloqueado': 'false'
      });
    }
  }

  static Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> update(String table, int id, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(String table, int id) async {
    final db = await DBHelper.database();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}