import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  List tarefas = [];
  String filtro = 'Todos';

  Future<String?> getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuarioId');
  }

  List get tarefasFiltradas {
    if (filtro == 'Pendentes') {
      return tarefas.where((t) => t["concluida"] == false).toList();
    } else if (filtro == 'Concluídas') {
      return tarefas.where((t) => t["concluida"] == true).toList();
    }
    return tarefas;
  }

  int get concluidas => tarefas.where((t) => t["concluida"] == true).length;
  int get pendentes => tarefas.where((t) => t["concluida"] == false).length;

  @override
  void initState() {
    super.initState();
    buscarTarefas();
  }

  Future<void> buscarTarefas() async {
    String? id = await getUsuarioId();
    if (id == null) return;

    try {
      final dados = await api.getDados('tarefas', usuarioId: id);
      setState(() { tarefas = dados; });
    } catch (e) {
      debugPrint("Erro ao buscar: $e");
    }
  }

  void _showTarefaDialog({Map<String, dynamic>? tarefa}) async {
    TextEditingController controller = TextEditingController(text: tarefa?["titulo"] ?? "");
    DateTime? dataSelecionada = tarefa != null && tarefa["dataVencimento"] != null 
        ? DateTime.parse(tarefa["dataVencimento"]) 
        : null;

    String? idUsuario = await getUsuarioId();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                  const SizedBox(height: 15),
                  ListTile(
                    title: Text(dataSelecionada == null ? "Definir data de vencimento" : "Vence em: ${dataSelecionada.toString().split(' ')[0]}"),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dataSelecionada ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => dataSelecionada = picked);
                      }
                    },
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
                            "dataVencimento": dataSelecionada?.toIso8601String(),
                            "usuarioId": idUsuario,
                          };
                          
                          if (tarefa == null) {
                            await api.postDados('tarefas', dados);
                          } else {
                            await api.putDados('tarefas', tarefa["id"].toString(), dados);
                          }
                          await buscarTarefas();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text("Salvar"),
                    ),
                  ),
                ],
              ),
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
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.blue)))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
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
                    onSelectionChanged: (newSelection) {
                      setState(() => filtro = newSelection.first);
                    },
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasFiltradas[index];
                    bool estaVencido = false;
                    if (tarefa["dataVencimento"] != null) {
                      DateTime dataVenc = DateTime.parse(tarefa["dataVencimento"]);
                      DateTime hoje = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                      if (dataVenc.isBefore(hoje)) {
                        estaVencido = true;
                      }
                    }

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            tarefa["concluida"] 
                                ? Icons.check_circle_rounded 
                                : Icons.radio_button_unchecked_rounded,
                            color: tarefa["concluida"] ? Colors.blue : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () async {
                            Map<String, dynamic> alt = Map.from(tarefa);
                            alt["concluida"] = !tarefa["concluida"];
                            await api.putDados('tarefas', tarefa["id"].toString(), alt);
                            await buscarTarefas();
                          },
                        ),
                        title: Text(
                          tarefa["titulo"], 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: tarefa["concluida"] ? TextDecoration.lineThrough : null,
                            color: tarefa["concluida"] ? Colors.grey : Colors.black,
                          )
                        ),
                        subtitle: tarefa["dataVencimento"] != null 
                            ? Text(
                                "Vence em: ${tarefa["dataVencimento"].split('T')[0]}",
                                style: TextStyle(
                                  color: estaVencido ? Colors.red : (tarefa["concluida"] ? Colors.grey : null), 
                                  fontWeight: estaVencido ? FontWeight.bold : null,
                                  decoration: tarefa["concluida"] ? TextDecoration.lineThrough : null,
                                ),
                              ) 
                            : null,
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