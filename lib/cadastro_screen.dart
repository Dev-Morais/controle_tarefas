import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart'; 

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> realizarCadastro() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool existe = await api.emailJaExiste(emailController.text);
      if (existe) {
        Navigator.pop(context); 
        AppAlertas.mostrar(context, "E-mail já cadastrado!", isErro: true);
      } else {
        await api.postDados('usuarios', {
          "nome": nomeController.text,
          "email": emailController.text,
          "senha": senhaController.text,
        });
        
        if (!mounted) return;
        Navigator.pop(context); 
        
        AppAlertas.mostrar(context, "Cadastro realizado com sucesso!", isErro: false);
        Navigator.pop(context); 
      }
    } catch (e) {
      Navigator.pop(context); 
      AppAlertas.mostrar(context, "Erro: $e", isErro: true);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100], 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Alterado para branco
      appBar: AppBar(
        title: const Text("Criar Conta", style: TextStyle(color: Colors.white)), 
        centerTitle: true,
        backgroundColor: Colors.blue, // Mantido azul
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: nomeController,
                      decoration: _buildInputDecoration("Nome", Icons.person_outline),
                      validator: (v) => (v == null || v.isEmpty) ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: emailController,
                      decoration: _buildInputDecoration("E-mail", Icons.email_outlined),
                      validator: (v) => (v == null || !v.contains("@")) ? "E-mail inválido" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: _buildInputDecoration("Senha", Icons.lock_outline),
                      validator: (v) => (v == null || v.length < 6) ? "Mínimo 6 caracteres" : null,
                    ),
                    
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            realizarCadastro();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Cadastrar", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}