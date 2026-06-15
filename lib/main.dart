import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Tarefas',
      
      // Tema definido conforme o Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      
      // Inicia diretamente na tela de Login
      home: const LoginScreen(),
    );
  }
}

// Classe de Utilitários para Alertas Padronizados
class AppAlertas {
  static void mostrar(BuildContext context, String mensagem, {bool isErro = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isErro ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}