import 'package:flutter/material.dart';
import 'api_service.dart';

class UserTasksScreen extends StatefulWidget {
  final String usuarioId;
  final String nomeUsuario;
  const UserTasksScreen({super.key, required this.usuarioId, required this.nomeUsuario});

  @override
  State<UserTasksScreen> createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends State<UserTasksScreen> {
  final ApiService api = ApiService();
  List tarefas = [];

  @override
  void initState() {
    super.initState();
    _buscarTarefasUsuario();
  }

  Future<void> _buscarTarefasUsuario() async {
    final todas = await api.getDados('tarefas');
    setState(() {
      // Filtra as tarefas pelo ID do usuário
      tarefas = todas.where((t) => t['usuarioId'].toString() == widget.usuarioId).toList();
    });
  }

  // Funcionalidade de Excluir (Obrigatória para o CRUD)
  Future<void> _excluirTarefa(dynamic id) async {
    await api.deleteDados('tarefas', id);
    _buscarTarefasUsuario(); // Recarrega a lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas de ${widget.nomeUsuario}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: tarefas.isEmpty 
        ? const Center(child: Text("Nenhuma tarefa encontrada para este usuário."))
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              final t = tarefas[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Icon(
                    t['concluida'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: t['concluida'] == true ? Colors.green : Colors.grey,
                  ),
                  title: Text(t['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t['concluida'] == true ? "Status: Concluída" : "Status: Pendente"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirmação de exclusão padronizada
                      bool? confirmar = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: const Text("Excluir Tarefa", style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text("Deseja realmente excluir esta tarefa?"),
                          actions: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancelar", style: TextStyle(color: Colors.blue)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Excluir"),
                            ),
                          ],
                        ),
                      );
                      if (confirmar == true) _excluirTarefa(t['id']);
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}