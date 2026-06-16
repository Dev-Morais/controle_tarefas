import 'package:flutter/material.dart';
import 'api_service.dart';
import 'usertaskssreen.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService api = ApiService();
  List usuarios = [];
  List todasTarefas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);
    try {
      final listaUsers = await api.getDados('usuarios');
      final listaTarefas = await api.getDados('tarefas');
      setState(() {
        usuarios = listaUsers;
        todasTarefas = listaTarefas;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      debugPrint("Erro ao carregar dados: $e");
    }
  }

  Future<void> _bloquearUsuario(dynamic user) async {
    bool novoStatus = !(user['bloqueado'] ?? false);
    await api.putDados('usuarios', user['id'].toString(), {
      ...user,
      'bloqueado': novoStatus,
    });
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Administrador 👑"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      _cardInfo("Usuários", "${usuarios.length}", Colors.blue),
                      _cardInfo("Tarefas Totais", "${todasTarefas.length}", Colors.green),
                    ],
                  ),
                ),
                // Filtro que navega para a nova tela
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Ver tarefas de um usuário", 
                      border: OutlineInputBorder(),
                    ),
                    value: null,
                    items: [
                      const DropdownMenuItem(value: "0", child: Text("Selecione um usuário para ver tarefas")),
                      ...usuarios.map((u) => DropdownMenuItem(
                        value: u['id'].toString(), 
                        child: Text(u['nome'] ?? 'Sem nome')
                      )),
                    ],
                    onChanged: (val) {
                      if (val != null && val != "0") {
                        final user = usuarios.firstWhere((u) => u['id'].toString() == val);
                        // AQUI ESTÁ A MELHORIA: Navegação para a nova tela
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => UserTasksScreen(
                              usuarioId: val, 
                              nomeUsuario: user['nome'] ?? 'Usuário'
                            )
                          ),
                        );
                      }
                    },
                  ),
                ),
                
                // Lista de Usuários para Gestão (Bloqueio/Exclusão)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Gestão de Usuários:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final user = usuarios[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user['nome'] ?? 'Sem nome'),
                          subtitle: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(user['bloqueado'] == true ? "Bloqueado" : "Ativo"),
                            value: user['bloqueado'] ?? false,
                            onChanged: (_) => _bloquearUsuario(user),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () => _confirmarExclusao(user),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _cardInfo(String titulo, String valor, Color cor) {
    return Expanded(
      child: Card(
        color: cor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text("Deseja deletar ${user['nome']} e TODAS as suas tarefas?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await api.deleteDados('usuarios', user['id'].toString());
              final tarefasDoUser = todasTarefas.where((t) => t['usuarioId'].toString() == user['id'].toString());
              for (var t in tarefasDoUser) {
                await api.deleteDados('tarefas', t['id'].toString());
              }
              if (mounted) Navigator.pop(context);
              _carregarDados();
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}