import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final ApiService _apiService = ApiService();
  bool _mostrarSenha = false;
  String _idiomaAtual = "Português (Brasil)";
  String _senhaDoUsuario = "";

  // 1. DICIONÁRIO DE TRADUÇÕES
  final Map<String, Map<String, String>> _traducoes = {
    "Português (Brasil)": {
      "config": "Configurações",
      "conta": "CONTA",
      "editar": "Editar Perfil",
      "senha_alt": "Alterar Senha",
      "privacidade": "Privacidade e Segurança",
      "sistema": "SISTEMA",
      "sair": "Sair da Conta",
      "deletar": "Deletar Conta",
      "msg_idioma": "Idioma alterado para"
    },
    "English (US)": {
      "config": "Settings",
      "conta": "ACCOUNT",
      "editar": "Edit Profile",
      "senha_alt": "Change Password",
      "privacidade": "Privacy and Security",
      "sistema": "SYSTEM",
      "sair": "Logout",
      "deletar": "Delete Account",
      "msg_idioma": "Language changed to"
    },
  };

  // 2. FUNÇÃO DE TRADUÇÃO
  String _traduzir(String chave) {
    return _traducoes[_idiomaAtual]?[chave] ?? chave;
  }

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _idiomaAtual = prefs.getString('idioma') ?? "Português (Brasil)";
      _senhaDoUsuario = prefs.getString('userSenha') ?? "Senha não encontrada";
    });
  }

  Future<void> _salvarIdioma(String novoIdioma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', novoIdioma);
    setState(() => _idiomaAtual = novoIdioma);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _deletarConta(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('usuarioId');
    if (userId != null) await _apiService.deleteDados('usuarios', userId);
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _mostrarSelecaoIdioma(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Selecione o Idioma", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            _opcaoIdioma(context, "Português (Brasil)"),
            _opcaoIdioma(context, "English (US)"),
          ],
        ),
      ),
    );
  }

  Widget _opcaoIdioma(BuildContext context, String idioma) {
    return ListTile(
      leading: const Icon(Icons.language, color: Colors.blue),
      title: Text(idioma, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: _idiomaAtual == idioma ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
  _salvarIdioma(idioma);
  Navigator.pop(context);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("${_traduzir("msg_idioma")} $idioma"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating, 
        )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_traduzir("config")),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _sectionTitle(_traduzir("conta")),
          _buildItem(Icons.person_outline, _traduzir("editar"), () => Navigator.pushNamed(context, '/perfil')),
          _buildItem(Icons.lock_outline, _traduzir("senha_alt"), () => Navigator.pushNamed(context, '/alterar_senha')),
          
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.visibility, color: Colors.black87),
              title: Text(
                _mostrarSenha ? _senhaDoUsuario : "********", 
                style: const TextStyle(fontWeight: FontWeight.w500)
              ),
              trailing: IconButton(
                icon: Icon(_mostrarSenha ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
              ),
            ),
          ),
          
          _buildItem(Icons.security, _traduzir("privacidade"), () => Navigator.pushNamed(context, '/privacidade')),
          
          _sectionTitle(_traduzir("sistema")),
          _buildItem(Icons.language, "Idioma ($_idiomaAtual)", () => _mostrarSelecaoIdioma(context)),
          
          const Divider(height: 30),
          
          _buildItem(Icons.logout, _traduzir("sair"), () => _logout(context), color: Colors.blue),
          _buildItem(Icons.delete_forever, _traduzir("deletar"), () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: const Text("Confirmar Exclusão", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                content: const Text("Deseja realmente apagar sua conta? Esta ação é irreversível."),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context), 
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => _deletarConta(context), 
                    child: const Text("DELETAR"),
                  ),
                ],
              ),
            );
          }, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
      child: Text(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}