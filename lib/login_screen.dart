import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';
import 'api_service.dart';
import 'main.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final ApiService api = ApiService();
  
  // 1. Variável para controlar a visibilidade da senha
  bool _senhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Controle de Tarefas"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.task_alt, size: 100, color: Colors.blue),
                  const SizedBox(height: 20),

                  // CAMPO E-MAIL
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? "Digite o e-mail" : null,
                  ),
                  
                  const SizedBox(height: 15),

                  // CAMPO SENHA COM O "OLHO"
                  TextFormField(
                    controller: senhaController,
                    obscureText: !_senhaVisivel, // 2. Oculta ou mostra o texto
                    decoration: InputDecoration(
                      labelText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      // 3. Adiciona o botão do olho
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaVisivel = !_senhaVisivel;
                          });
                        },
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? "Digite a senha" : null,
                  ),
                  
                  const SizedBox(height: 20),

                  // BOTÃO ENTRAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final usuario = await api.validarLogin(emailController.text, senhaController.text);
                          
                          if (usuario != null) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('usuarioId', usuario['id'].toString());

                            AppAlertas.mostrar(context, "Bem-vindo!", isErro: false);
                            if (mounted) {
                              Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (context) => const HomeScreen())
                              );
                            }
                          } else {
                            AppAlertas.mostrar(context, "E-mail ou senha incorretos!", isErro: true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Entrar", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // BOTÃO CRIAR CONTA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: const BorderSide(color: Colors.blue, width: 2),
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text("Criar Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}