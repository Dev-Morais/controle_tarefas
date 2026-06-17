import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
// Imports adicionados para as novas telas
import 'perfil_screen.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  List tarefas = [];
  String filtro = 'Todos';
  String nomeUsuario = ""; // Começa vazio

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Pega o nome, se for nulo usa "U"
      nomeUsuario = prefs.getString('nomeUsuario') ?? "U"; 
      buscarTarefas();
    });
  }

  Future<String?> getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuarioId');
  }

  List get tarefasFiltradas {
    if (filtro == 'Pendentes') return tarefas.where((t) => t["concluida"] == false).toList();
    if (filtro == 'Concluídas') return tarefas.where((t) => t["concluida"] == true).toList();
    return tarefas;
  }

  int get concluidas => tarefas.where((t) => t["concluida"] == true).length;
  int get pendentes => tarefas.where((t) => t["concluida"] == false).length;

  Future<void> buscarTarefas() async {
    String? id = await getUsuarioId();
    if (id == null) return;
    try {
      final dados = await api.getDados('tarefas', usuarioId: id);
      setState(() { tarefas = dados; });
    } catch (e) { debugPrint("Erro ao buscar: $e"); }
  }

  void _showTarefaDialog({Map<String, dynamic>? tarefa}) async {
    TextEditingController controller = TextEditingController(text: tarefa?["titulo"] ?? "");
    String? idUsuario = await getUsuarioId();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tarefa == null ? "Nova Tarefa" : "Editar Tarefa", 
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: "Descrição", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () async {
                      if (controller.text.isNotEmpty && idUsuario != null) {
                        Map<String, dynamic> dados = {
                          "titulo": controller.text,
                          "concluida": tarefa?["concluida"] ?? false,
                          "usuarioId": idUsuario
                        };
                        if (tarefa == null) await api.postDados('tarefas', dados);
                        else await api.putDados('tarefas', tarefa["id"].toString(), dados);
                        await buscarTarefas();
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text("Salvar"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void excluirTarefa(Map<String, dynamic> tarefa) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Confirmar exclusão", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text("Deseja realmente excluir a tarefa: '${tarefa["titulo"]}'?"),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          minimumSize: const Size(100, 50),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          minimumSize: const Size(100, 50),
                        ),
                        onPressed: () async {
                          await api.deleteDados('tarefas', tarefa["id"].toString());
                          await buscarTarefas();
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text("Excluir"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<bool>(
            future: SharedPreferences.getInstance().then((p) => p.getBool('isAdmin') ?? false),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.yellow),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Menu de Perfil customizado
          PopupMenuButton<String>(
            offset: const Offset(0, 55), // Deslocamento para não cobrir o gráfico
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : "?", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'perfil') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
              } else if (value == 'config') {
                // Ao voltar da tela de configuração, recarregamos os dados
                final alterou = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen()));
                if (alterou == true) {
                  _carregarDadosIniciais();
                }
              } else if (value == 'sair') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'perfil', child: Text("Ver Perfil", style: TextStyle(color: Colors.black87))),
              const PopupMenuItem(value: 'config', child: Text("Configurar Conta", style: TextStyle(color: Colors.black87))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sair', child: Text("Sair", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              if (tarefas.isNotEmpty) ...[
                SizedBox(height: 180, child: PieChart(PieChartData(sections: [
                  PieChartSectionData(value: concluidas.toDouble(), title: "OK", color: Colors.green, radius: 50),
                  PieChartSectionData(value: pendentes.toDouble(), title: "Pendente", color: Colors.red, radius: 50),
                ]))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Todos', label: Text('Todos')),
                      ButtonSegment(value: 'Pendentes', label: Text('Pendentes')),
                      ButtonSegment(value: 'Concluídas', label: Text('Concluídas')),
                    ],
                    selected: {filtro},
                    onSelectionChanged: (newSelection) => setState(() => filtro = newSelection.first),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasFiltradas[index];
                    return Card(
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            tarefa["concluida"] ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: tarefa["concluida"] ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () async {
                            Map<String, dynamic> alt = Map.from(tarefa);
                            alt["concluida"] = !tarefa["concluida"];
                            await api.putDados('tarefas', tarefa["id"].toString(), alt);
                            await buscarTarefas();
                          },
                        ),
                        title: Text(tarefa["titulo"]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showTarefaDialog(tarefa: tarefa)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => excluirTarefa(tarefa)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => _showTarefaDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}