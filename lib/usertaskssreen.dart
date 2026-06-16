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
      tarefas = todas.where((t) => t['usuarioId'].toString() == widget.usuarioId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarefas de ${widget.nomeUsuario}")),
      body: ListView.builder(
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          final t = tarefas[index];
          return ListTile(
            leading: Icon(t['concluida'] ? Icons.check_circle : Icons.radio_button_unchecked, 
                          color: t['concluida'] ? Colors.green : Colors.grey),
            title: Text(t['titulo']),
          );
        },
      ),
    );
  }
}