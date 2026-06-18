import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
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
  String nomeUsuario = "";
  bool isAdmin = false; 
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeUsuario = prefs.getString('nomeUsuario') ?? "U";
      isAdmin = prefs.getBool('isAdmin') ?? false; 
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
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
                  ],
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
                    Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () => Navigator.pop(context), child: const Text("Cancelar"))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () async {
                      await api.deleteDados('tarefas', tarefa["id"].toString());
                      await buscarTarefas();
                      if (mounted) Navigator.pop(context);
                    }, child: const Text("Excluir"))),
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
    final List<Widget> _telas = [
      _buildHomeScreenContent(),
      const PerfilScreen(),
      const ConfigScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: _selectedIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Olá, $nomeUsuario", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Gerencie suas tarefas", style: TextStyle(fontSize: 12)),
                ],
              )
            : Text(_selectedIndex == 1 ? "Meu Perfil" : "Configurações", 
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedIndex == 0 && isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: "Painel Administrativo",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : "?",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: _telas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuração'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.blue, 
              foregroundColor: Colors.white, 
              shape: const CircleBorder(),
              onPressed: () => _showTarefaDialog(), 
              child: const Icon(Icons.add)
            )
          : null,
    );
  }

  Widget _buildHomeScreenContent() {
    double progresso = tarefas.isNotEmpty ? (concluidas / tarefas.length) : 0.0;
    return Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [Row(children: [_buildStatCard("Todas", tarefas.length.toString(), Colors.blue.shade50, Colors.blue), const SizedBox(width: 10), _buildStatCard("Pendentes", pendentes.toString(), Colors.orange.shade50, Colors.orange), const SizedBox(width: 10), _buildStatCard("Concluídas", concluidas.toString(), Colors.green.shade50, Colors.green)]), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Progresso geral", style: TextStyle(fontWeight: FontWeight.bold)), Text("$concluidas de ${tarefas.length} concluídas")]), const SizedBox(height: 12), LinearProgressIndicator(value: progresso, backgroundColor: Colors.grey.shade200, color: Colors.green, minHeight: 8), const SizedBox(height: 8), Text("${(progresso * 100).toInt()}% concluído", style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))]))])), Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)), child: Row(children: [_buildFilterButton("Todos", Colors.blue), _buildFilterButton("Pendentes", Colors.orange), _buildFilterButton("Concluídas", Colors.green)])), const SizedBox(height: 10), Expanded(child: ListView.builder(padding: const EdgeInsets.all(10), itemCount: tarefasFiltradas.length, itemBuilder: (context, index) { final tarefa = tarefasFiltradas[index]; return Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)), child: ListTile(leading: IconButton(icon: Icon(tarefa["concluida"] ? Icons.check_circle : Icons.radio_button_unchecked, color: tarefa["concluida"] ? Colors.green : Colors.grey), onPressed: () async { bool novoStatus = !tarefa["concluida"]; Map<String, dynamic> dadosAtualizados = {"titulo": tarefa["titulo"], "concluida": novoStatus, "usuarioId": tarefa["usuarioId"]}; await api.putDados('tarefas', tarefa["id"].toString(), dadosAtualizados); await buscarTarefas(); }), title: Text(tarefa["titulo"]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _showTarefaDialog(tarefa: tarefa)), IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () => excluirTarefa(tarefa))]))); }))]);
  }

  Widget _buildStatCard(String label, String count, Color bg, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)), Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)), Text("tarefas", style: TextStyle(color: color.withOpacity(0.7), fontSize: 12))])));
  }

  Widget _buildFilterButton(String label, Color color) {
    bool isSelected = filtro == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => filtro = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}