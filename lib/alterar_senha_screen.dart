import 'package:flutter/material.dart';

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({super.key});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final TextEditingController _atualController = TextEditingController();
  final TextEditingController _novaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  @override
  void dispose() {
    _atualController.dispose();
    _novaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alterar Senha"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _campoSenha("Senha Atual", _atualController),
            _campoSenha("Nova Senha", _novaController),
            _campoSenha("Confirmar Nova Senha", _confirmarController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Aqui você coloca a lógica para salvar no banco/API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Senha alterada com sucesso!")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("SALVAR NOVA SENHA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoSenha(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: true, // Isso esconde a senha
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.lock_outline),
        ),
      ),
    );
  }
}